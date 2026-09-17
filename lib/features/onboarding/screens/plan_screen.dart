import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/bible/books.dart';
import '../../../domain/plan/plan_definition.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/onboarding_controller.dart';
import '../widgets/book_picker.dart';

/// Scope × duration. The preview under the pickers shows the real daily load
/// before the person commits, so "the whole Bible in a month" reads as
/// "40 chapters · ~2 h a day" and not as a surprise on day one.
class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key, this.onboarding = true});

  /// True during first launch (continues to the reminder step). False from
  /// Settings, where confirming replaces the active plan and returns.
  final bool onboarding;

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  bool _saving = false;

  /// Owned by the screen, not the dialog: a controller disposed the moment
  /// `showDialog` returns is still bound to a TextField that is animating
  /// out, and Flutter asserts on exactly that (`_dependents.isEmpty`).
  final _customDays = TextEditingController();

  @override
  void dispose() {
    _customDays.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!widget.onboarding) {
      final plan = ref.read(activePlanProvider).value;
      if (plan != null) {
        Future.microtask(
          () => ref.read(onboardingControllerProvider.notifier).seedFrom(plan),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final state = ref.watch(onboardingControllerProvider);
    final ctl = ref.read(onboardingControllerProvider.notifier);
    final preview = _preview(state);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.onboarding ? 'Your reading plan' : 'Change plan'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            if (widget.onboarding) ...[
              Text('Welcome, ${state.name} 👋', style: text.headlineSmall),
              const SizedBox(height: 24),
            ] else ...[
              Text(
                'Chapters you have already read stay read. Your streak and '
                'badges are kept. The new plan starts today.',
                style: text.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 20),
            ],
            Text('What will you read?', style: text.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _scopeChip(state, ctl, const WholeBible()),
                _scopeChip(state, ctl, const TestamentScope(Testament.old)),
                _scopeChip(state, ctl, const TestamentScope(Testament.newT)),
                ChoiceChip(
                  label: Text(
                    state.scope is BookScope
                        ? state.scope.title
                        : 'A single book…',
                  ),
                  selected: state.scope is BookScope,
                  onSelected: (_) => _pickBook(ctl, state),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text('Over how long?', style: text.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in PlanDuration.presets)
                  ChoiceChip(
                    label: Text(d.title),
                    selected: state.targetDays == d.days,
                    onSelected: (_) => ctl.setTargetDays(d.days),
                  ),
                // Anything not a preset is "custom", and the chip says how many.
                ChoiceChip(
                  label: Text(
                    _isPreset(state.targetDays)
                        ? 'Custom…'
                        : '${state.targetDays} days',
                  ),
                  selected: !_isPreset(state.targetDays),
                  onSelected: (_) => _pickCustomDays(ctl, state),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Each day', style: text.labelLarge),
                    const SizedBox(height: 6),
                    Text(preview.$1, style: text.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      preview.$2,
                      style: text.bodyMedium?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : () => _finish(ctl, state),
              child: Text(
                _saving
                    ? 'Setting up…'
                    : widget.onboarding
                    ? 'Continue'
                    : 'Switch to this plan',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scopeChip(
    OnboardingState state,
    OnboardingController ctl,
    PlanScope scope,
  ) => ChoiceChip(
    label: Text(scope.title),
    selected: state.scope.code == scope.code,
    onSelected: (_) => ctl.setScope(scope),
  );

  /// ("3–4 chapters", "about 16 minutes · 365 reading days")
  (String, String) _preview(OnboardingState s) {
    final plan = PlanDefinition(
      id: -1,
      scope: s.scope,
      targetDays: s.targetDays,
      startDate: ref.read(clockProvider).today(),
    );
    final pace = ref.read(settingsProvider).pace;
    final days = ref.read(planGeneratorProvider).generate(plan, pace);
    if (days.isEmpty) return ('—', '');
    final counts = days.map((d) => d.chapterCount).toSet().toList()..sort();
    final chapters = counts.length == 1
        ? '${counts.single} ${counts.single == 1 ? 'chapter' : 'chapters'}'
        : '${counts.first}–${counts.last} chapters';
    final avgSec =
        days.fold<int>(0, (a, d) => a + d.requiredDuration.inSeconds) /
        days.length;
    final mins = (avgSec / 60).round();
    final time = mins >= 60
        ? 'about ${(mins / 60).toStringAsFixed(1)} hours'
        : 'about $mins minutes';
    return (chapters, '$time · ${days.length} reading days');
  }

  static bool _isPreset(int days) =>
      PlanDuration.presets.any((p) => p.days == days);

  /// A number, typed. Bounded to 1..3650: below one is not a plan and beyond
  /// ten years is a typo. The chapter cap (never more days than chapters) is
  /// applied by the generator, so 400 days over Jude still yields one day.
  Future<void> _pickCustomDays(
    OnboardingController ctl,
    OnboardingState state,
  ) async {
    final controller = _customDays
      ..text = _isPreset(state.targetDays) ? '' : '${state.targetDays}';
    final chapters = state.scope.chapters.length;
    final days = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final n = int.tryParse(controller.text.trim());
            final valid = n != null && n >= 1 && n <= 3650;
            final perDay = valid
                ? (chapters / n.clamp(1, chapters)).ceil()
                : null;
            return AlertDialog(
              title: const Text('How many days?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 100',
                      suffixText: 'days',
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) {
                      if (valid) Navigator.of(ctx).pop(n);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    perDay == null
                        ? 'Between 1 and 3650 days.'
                        : 'About $perDay ${perDay == 1 ? 'chapter' : 'chapters'} a day '
                              'for ${state.scope.title.toLowerCase()}.',
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: valid ? () => Navigator.of(ctx).pop(n) : null,
                  child: const Text('Use'),
                ),
              ],
            );
          },
        );
      },
    );
    if (days != null) ctl.setTargetDays(days);
  }

  Future<void> _pickBook(
    OnboardingController ctl,
    OnboardingState state,
  ) async {
    final picked = await showBookPicker(
      context,
      initialTestament: state.scope is BookScope
          ? (state.scope as BookScope).testament
          : Testament.old,
    );
    if (picked != null) {
      ctl.setScope(BookScope(picked.id));
      if (state.targetDays > 30) ctl.setTargetDays(7);
    }
  }

  Future<void> _finish(OnboardingController ctl, OnboardingState state) async {
    if (widget.onboarding) {
      context.go('/onboarding/reminder');
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Switch plan?'),
        content: const Text(
          'Your current schedule is replaced and any reading in progress is '
          'closed. Chapters you have read, your streak and your badges are '
          'kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(settingsActionsProvider)
          .startNewPlan(scope: state.scope, targetDays: state.targetDays);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

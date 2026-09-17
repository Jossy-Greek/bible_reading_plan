import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/sanctuary.dart';
import '../../../domain/achievements/badges.dart';
import '../providers/reading_providers.dart';

class CompletionArgs {
  const CompletionArgs({
    required this.label,
    required this.streak,
    required this.badgeIds,
    required this.sessionId,
    this.isPassage = false,
    this.catchUpDate,
    this.graceUsedDate,
  });
  final String label;
  final int streak;
  final List<String> badgeIds;

  /// The sitting just finished — what a reflection attaches to.
  final int sessionId;

  /// A one-time reading: no streak line, different headline.
  final bool isPassage;

  /// Set when the reading just finished belongs to an earlier day. The
  /// headline then names that day instead of claiming it was today's.
  final String? catchUpDate;

  /// Set when this completion spent the month's grace day.
  final String? graceUsedDate;
}

class CompletionScreen extends ConsumerStatefulWidget {
  const CompletionScreen({super.key, required this.args});

  final CompletionArgs args;

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen> {
  // Owned by the State, not created inline: a controller disposed while its
  // route is still animating out throws '_dependents.isEmpty'.
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    setState(() => _saving = true);
    // A reflection is optional, and never blocks leaving: if the write
    // fails the reading is still complete.
    try {
      if (_note.text.trim().isNotEmpty) {
        await ref
            .read(progressRepositoryProvider)
            .setNote(widget.args.sessionId, _note.text);
      }
    } finally {
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final text = Theme.of(context).textTheme;
    final c = context.colors;
    final badges = [for (final id in args.badgeIds) badgeById(id)];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            ExcludeSemantics(
              child: Text(
                '🎉',
                textAlign: TextAlign.center,
                style: text.displayLarge,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              args.isPassage
                  ? 'Reading complete!'
                  : args.catchUpDate != null
                  ? 'Caught up!'
                  : "Today's reading is complete!",
              textAlign: TextAlign.center,
              style: text.headlineMedium,
            ),
            if (args.catchUpDate != null) ...[
              const SizedBox(height: 8),
              Text(
                "You finished ${args.catchUpDate}'s reading.",
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: c.inkSoft),
              ),
            ],
            const SizedBox(height: 20),
            if (!args.isPassage)
              Text(
                '🔥 ${args.streak} day streak',
                textAlign: TextAlign.center,
                style: text.titleLarge,
                semanticsLabel: '${args.streak} day reading streak',
              ),
            if (args.graceUsedDate != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: c.parchmentDeep.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 20, color: c.gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'A grace day covered ${args.graceUsedDate}, so your '
                        'streak held. One a month, and it is already yours.',
                        style: text.bodySmall?.copyWith(color: c.inkSoft),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              '${args.label} ✓',
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(color: c.success),
            ),
            if (badges.isNotEmpty) ...[
              const SizedBox(height: 28),
              Text(
                badges.length == 1 ? 'New badge' : 'New badges',
                textAlign: TextAlign.center,
                style: text.labelLarge?.copyWith(color: c.inkSoft),
              ),
              const SizedBox(height: 12),
              for (final b in badges)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      leading: Text(b.emoji, style: text.headlineSmall),
                      title: Text(b.title),
                      subtitle: Text(b.description),
                    ),
                  ),
                ),
            ],

            const SizedBox(height: 28),
            // The one place the app asks for something back. Optional, and
            // never in the way of leaving.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note_rounded, size: 20, color: c.teal),
                        const SizedBox(width: 8),
                        const Overline('What stood out?'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _note,
                      minLines: 3,
                      maxLines: 8,
                      maxLength: 2000,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText:
                            'A verse, a question, a prayer — or nothing at '
                            'all. This stays on your device.',
                        fillColor: c.parchmentDeep.withValues(alpha: 0.5),
                        counterText: '',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _done,
              child: Text(_saving ? 'Saving…' : 'Done'),
            ),
          ],
        ),
      ),
    );
  }
}

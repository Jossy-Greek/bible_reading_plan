import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/time/format.dart';
import '../../../domain/session/reading_session_service.dart';
import '../../../notifications/reminder_coordinator.dart';
import '../providers/reading_providers.dart';
import 'completion_screen.dart';

const _verses = [
  ('Be still, and know that I am God.', 'Psalm 46:10'),
  (
    'Thy word is a lamp unto my feet, and a light unto my path.',
    'Psalm 119:105',
  ),
  (
    'The grass withereth, the flower fadeth: but the word of our God shall stand for ever.',
    'Isaiah 40:8',
  ),
  ('Let the word of Christ dwell in you richly.', 'Colossians 3:16'),
  ('Blessed are they that hear the word of God, and keep it.', 'Luke 11:28'),
  (
    'Open thou mine eyes, that I may behold wondrous things out of thy law.',
    'Psalm 119:18',
  ),
  (
    'Man shall not live by bread alone, but by every word that proceedeth out of the mouth of God.',
    'Matthew 4:4',
  ),
];

/// The focused reading screen. Nothing here decides anything: the remaining
/// time comes from `sessionTimingProvider`, which reads timestamps. Leaving
/// and returning restores the same countdown.
class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({super.key});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen>
    with WidgetsBindingObserver {
  final _foreground = Stopwatch()..start();
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flushForeground();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _foreground.start();
    } else {
      _flushForeground();
    }
  }

  /// Records time spent with the app in front. Not used to gate anything
  /// today — reading a paper Bible with the phone face down is the point —
  /// but stored so a future text-in-app rule can use it.
  void _flushForeground() {
    if (!_foreground.isRunning) return;
    _foreground.stop();
    final ms = _foreground.elapsedMilliseconds;
    _foreground.reset();
    final session = ref.read(openSessionProvider).value;
    if (session != null && ms > 0) {
      unawaited(
        ref.read(progressRepositoryProvider).addForegroundMs(session.id, ms),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final day = ref.watch(sessionDayProvider);
    final session = ref.watch(openSessionProvider).value;
    final timing = ref.watch(sessionTimingProvider);

    if (day == null || session == null || timing == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No reading in progress.')),
      );
    }

    if (timing.clockMovedBack) {
      return _ClockMovedBack(sessionId: session.id);
    }

    final verse = _verses[day.dayIndex % _verses.length];
    final done = timing.isComplete;

    return Scaffold(
      appBar: AppBar(title: const Text('Reading')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                day.date == ref.watch(clockProvider).today()
                    ? "Today's Reading"
                    : 'Reading for ${formatLongDate(day.date)}',
                style: text.labelLarge,
              ),
              const SizedBox(height: 6),
              Text(day.label, style: text.headlineMedium),
              const SizedBox(height: 6),
              Text(
                'Required time ${formatCountdown(timing.required)}',
                style: text.bodyMedium?.copyWith(color: AppColors.inkSoft),
              ),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Text(
                      done ? '✓' : formatCountdown(timing.remaining),
                      style: text.displayLarge?.copyWith(
                        fontWeight: FontWeight.w300,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: done ? AppColors.success : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      done ? 'Reading time completed' : 'remaining',
                      style: text.bodyLarge?.copyWith(color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: timing.progress,
                  minHeight: 6,
                  backgroundColor: AppColors.parchmentDeep,
                  color: done ? AppColors.success : AppColors.teal,
                ),
              ),
              const Spacer(),
              Text(
                '“${verse.$1}”',
                textAlign: TextAlign.center,
                style: text.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                verse.$2,
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: AppColors.inkSoft),
              ),
              const Spacer(),
              FilledButton(
                onPressed: done && !_completing ? _complete : null,
                child: Text(
                  done
                      ? (_completing ? 'Saving…' : 'Mark as Done ✓')
                      : 'Keep reading — ${formatCountdown(timing.remaining)}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _complete() async {
    final plan = ref.read(activePlanProvider).value;
    final day = ref.read(sessionDayProvider);
    final session = ref.read(openSessionProvider).value;
    if (plan == null || day == null || session == null) return;
    setState(() => _completing = true);
    final clock = ref.read(clockProvider);
    try {
      final result = await ref
          .read(progressRepositoryProvider)
          .completeDay(
            plan: plan,
            day: day,
            sessionId: session.id,
            nowUtc: clock.nowUtc(),
            today: clock.today(),
            totalDays: ref.read(scheduleProvider).value?.length ?? 0,
          );
      // Today is done: the evening nudge must not fire tonight.
      unawaited(ref.read(reminderCoordinatorProvider).refresh());
      if (mounted) {
        context.go(
          '/reading/complete',
          extra: CompletionArgs(
            label: day.label,
            streak: result.streak.current,
            badgeIds: [for (final b in result.newBadges) b.id],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }
}

class _ClockMovedBack extends ConsumerWidget {
  const _ClockMovedBack({required this.sessionId});
  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Your device clock changed', style: text.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'The time is now earlier than when this reading started, so the '
              'timer cannot be trusted. Start the reading again.',
              style: text.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                await ref
                    .read(progressRepositoryProvider)
                    .invalidateSession(sessionId, 'clock_moved_back');
                if (context.mounted) context.go('/');
              },
              child: const Text('Back to today'),
            ),
          ],
        ),
      ),
    );
  }
}

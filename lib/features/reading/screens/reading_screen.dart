import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/sanctuary.dart';
import '../../../core/time/format.dart';
import '../../../domain/session/reading_session_service.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../notifications/reminder_coordinator.dart';
import '../providers/reading_providers.dart';
import '../widgets/passage_view.dart';
import 'completion_screen.dart';

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
    final c = context.colors;
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

    final passage = ref.watch(sessionPassageProvider);
    final done = timing.isComplete;
    final isToday = day.date == ref.watch(clockProvider).today();

    return Scaffold(
      appBar: SanctuaryAppBar(
        title: day.label,
        overline: passage != null
            ? 'One-time reading'
            : isToday
            ? "Today's reading"
            : formatLongDate(day.date),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            backgroundColor: c.parchmentDeep,
            foregroundColor: c.ink,
          ),
        ),
        showStreak: false,
        showProfile: false,
        // The timer follows the reader down the page. It used to be a 72 px
        // number above the text, which pushed scripture below the fold.
        trailing: [
          Semantics(
            liveRegion: true,
            label: done
                ? 'Reading time complete'
                : '${formatCountdown(timing.remaining)} remaining',
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: done
                    ? c.success.withValues(alpha: 0.16)
                    : c.parchmentDeep,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    done ? Icons.check_rounded : Icons.schedule,
                    size: 15,
                    color: done ? c.success : c.inkSoft,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    done ? 'Done' : formatCountdown(timing.remaining),
                    style: text.titleSmall?.copyWith(
                      color: done ? c.success : c.ink,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          ThinBar(timing.progress, height: 3, color: done ? c.success : c.teal),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              children: [
                Text(passage?.title ?? day.label, style: text.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  '${day.verseCount} verses · '
                  '${formatCountdown(timing.required)} of reading',
                  style: text.bodyMedium?.copyWith(color: c.inkSoft),
                ),
                const SizedBox(height: 24),

                // The passage itself.
                PassageView(assignments: day.assignments),

                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: c.parchmentDeep.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconWell(Icons.menu_book_outlined, color: c.card),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prefer your own Bible?',
                              style: text.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Set the phone down. The timer keeps counting '
                              'while the screen is off, and picks up exactly '
                              'where it was when you return.',
                              style: text.bodyMedium?.copyWith(
                                color: c.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'King James Version · public domain',
                    style: text.bodySmall?.copyWith(color: c.inkSoft),
                  ),
                ),
              ],
            ),
          ),
          // Pinned action.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              children: [
                FilledButton.icon(
                  style: timerButtonStyle(c),
                  onPressed: done && !_completing ? _complete : null,
                  icon: Icon(
                    done ? Icons.check_rounded : Icons.hourglass_top_rounded,
                  ),
                  label: Text(
                    done
                        ? (_completing ? 'Saving…' : 'Mark as Done ✓')
                        : 'Keep reading — ${formatCountdown(timing.remaining)}',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  done
                      ? 'Well done. Mark it and the day is yours.'
                      : '✦ Mark as Done unlocks at 0:00',
                  style: text.bodySmall?.copyWith(color: c.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _complete() async {
    final plan = ref.read(activePlanProvider).value;
    final day = ref.read(sessionDayProvider);
    final session = ref.read(openSessionProvider).value;
    final passage = ref.read(sessionPassageProvider);
    if (day == null || session == null) return;
    if (passage == null && plan == null) return;
    setState(() => _completing = true);
    final clock = ref.read(clockProvider);
    final schedule = ref.read(scheduleProvider).value ?? const [];
    try {
      final repo = ref.read(progressRepositoryProvider);
      final CompletionResult result;
      if (passage != null) {
        result = await repo.completePassage(
          sessionId: session.id,
          passage: passage,
          plan: plan,
          schedule: schedule,
          nowUtc: clock.nowUtc(),
          nowLocal: clock.nowLocal(),
          today: clock.today(),
        );
      } else {
        result = await repo.completeDay(
          plan: plan!,
          day: day,
          sessionId: session.id,
          nowUtc: clock.nowUtc(),
          nowLocal: clock.nowLocal(),
          today: clock.today(),
          schedule: schedule,
        );
        // Today is done: the evening nudge must not fire tonight.
        unawaited(ref.read(reminderCoordinatorProvider).refresh());
      }
      if (mounted) {
        context.go(
          '/reading/complete',
          extra: CompletionArgs(
            sessionId: session.id,
            label: passage != null
                ? '${passage.title} · ${passage.reference}'
                : day.label,
            streak: result.streak.current,
            badgeIds: [for (final b in result.newBadges) b.id],
            isPassage: passage != null,
            catchUpDate: passage == null && day.date != clock.today()
                ? formatLongDate(day.date)
                : null,
            graceUsedDate: result.graceUsedOn == null
                ? null
                : formatLongDate(result.graceUsedOn!),
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

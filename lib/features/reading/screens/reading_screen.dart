import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/sanctuary.dart';
import '../../../core/time/format.dart';
import '../../../core/verses.dart';
import '../../../domain/session/reading_session_service.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../notifications/reminder_coordinator.dart';
import '../providers/reading_providers.dart';
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
    final verse = passage == null
        ? verseFor(day.dayIndex)
        : verseForKey('${passage.bookId}${passage.fromChapter}');
    final done = timing.isComplete;
    final isToday = day.date == ref.watch(clockProvider).today();

    return Scaffold(
      appBar: SanctuaryAppBar(
        title: 'Reading Session',
        overline: passage != null
            ? 'One-time reading'
            : isToday
            ? 'Today'
            : formatLongDate(day.date),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            backgroundColor: context.colors.parchmentDeep,
            foregroundColor: context.colors.ink,
          ),
        ),
        showStreak: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              children: [
                // What is being read.
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: done
                                ? context.colors.success.withValues(alpha: 0.15)
                                : context.colors.parchmentDeep,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: done
                                      ? context.colors.success
                                      : context.colors.teal,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Overline(
                                done
                                    ? 'Reading time completed'
                                    : 'Session in progress',
                                color: done
                                    ? context.colors.success
                                    : context.colors.ink,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Overline(
                          passage != null
                              ? passage.title
                              : isToday
                              ? "Today's Reading"
                              : 'Reading for ${formatLongDate(day.date)}',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          day.label,
                          textAlign: TextAlign.center,
                          style: text.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 18,
                              color: context.colors.inkSoft,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Required time ${formatCountdown(timing.required)}',
                              style: text.bodyLarge?.copyWith(
                                color: context.colors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // The countdown.
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
                    child: Column(
                      children: [
                        Semantics(
                          liveRegion: true,
                          label: done
                              ? 'Reading time complete'
                              : '${formatCountdown(timing.remaining)} remaining',
                          excludeSemantics: true,
                          child: Text(
                            done ? '✓' : formatCountdown(timing.remaining),
                            style: text.displayLarge?.copyWith(
                              fontSize: 72,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              color: done
                                  ? context.colors.success
                                  : context.colors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Overline(done ? 'Complete' : 'Remaining'),
                        const SizedBox(height: 28),
                        ThinBar(
                          timing.progress,
                          color: done
                              ? context.colors.success
                              : context.colors.teal,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '${formatCountdown(timing.elapsed)} elapsed',
                              style: text.bodyMedium?.copyWith(
                                color: context.colors.inkSoft,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(timing.progress * 100).round()}% read',
                              style: text.bodyMedium?.copyWith(
                                color: context.colors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ExcludeSemantics(
                          child: Text(
                            '❝',
                            style: text.titleLarge?.copyWith(
                              color: context.colors.gold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          verse.text,
                          textAlign: TextAlign.center,
                          style: text.titleLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Overline('— ${verse.ref}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Why the phone can be put down.
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.colors.parchmentDeep.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconWell(
                        Icons.menu_book_outlined,
                        color: context.colors.card,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reading a paper Bible?',
                              style: text.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Set the phone down. The timer keeps counting '
                              'while the screen is off, and picks up exactly '
                              'where it was when you return.',
                              style: text.bodyMedium?.copyWith(
                                color: context.colors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  style: timerButtonStyle(context.colors),
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
                  style: text.bodySmall?.copyWith(
                    color: context.colors.inkSoft,
                  ),
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
            label: passage != null
                ? '${passage.title} · ${passage.reference}'
                : day.label,
            streak: result.streak.current,
            badgeIds: [for (final b in result.newBadges) b.id],
            isPassage: passage != null,
            catchUpDate: passage == null && day.date != clock.today()
                ? formatLongDate(day.date)
                : null,
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

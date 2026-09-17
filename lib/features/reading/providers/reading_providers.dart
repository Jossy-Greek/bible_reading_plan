import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/bible/bible_text.dart';
import '../../../core/bible/chapter_reference.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../domain/passages/passage.dart';
import '../../../domain/plan/reading_day.dart';
import '../../../domain/plan/reading_plan_generator.dart';
import '../../../domain/session/reading_session_service.dart';
import '../../../domain/streak/streak_service.dart';

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(ref.watch(databaseProvider)),
);

final sessionServiceProvider = Provider<ReadingSessionService>(
  (_) => const ReadingSessionService(),
);

final streakServiceProvider = Provider<StreakService>(
  (_) => const StreakService(),
);

/// A one-second heartbeat. Widgets that show a countdown watch this so they
/// repaint; the number they paint is computed from timestamps, not from the
/// count of ticks.
final tickProvider = StreamProvider<int>(
  (_) => Stream.periodic(const Duration(seconds: 1), (i) => i),
);

/// Today's scheduled reading, or null outside the plan.
final todayReadingProvider = Provider<ReadingDay?>((ref) {
  final plan = ref.watch(activePlanProvider).value;
  final days = ref.watch(scheduleProvider).value;
  if (plan == null || days == null) return null;
  return ReadingPlanGenerator.dayFor(
    days,
    plan,
    ref.watch(clockProvider).today(),
  );
});

/// The scheduled day the open session belongs to. Today's for a normal
/// reading, an earlier one for a catch-up started from the calendar.
final sessionDayProvider = Provider<ReadingDay?>((ref) {
  final session = ref.watch(openSessionProvider).value;
  if (session == null) return null;

  // A one-time reading: synthesize its day from the passage on the row. It
  // is dated today and indexed -1 so nothing treats it as a plan day.
  final passage = ProgressRepository.passageOf(session);
  if (passage != null) {
    return ReadingDay(
      dayIndex: -1,
      date: ref.watch(clockProvider).today(),
      assignments: [passage.assignment],
      requiredDuration: Duration(milliseconds: session.requiredMs),
    );
  }

  final plan = ref.watch(activePlanProvider).value;
  final days = ref.watch(scheduleProvider).value;
  if (plan == null || days == null) return null;
  if (session.planId != plan.id) return null;
  if (session.dayIndex < 0 || session.dayIndex >= days.length) return null;
  return days[session.dayIndex];
});

/// The passage of the open session, when it is a one-time reading.
final sessionPassageProvider = Provider<Passage?>((ref) {
  final session = ref.watch(openSessionProvider).value;
  return session == null ? null : ProgressRepository.passageOf(session);
});

final completedPassagesProvider = StreamProvider<List<Passage>>(
  (ref) => ref.watch(progressRepositoryProvider).watchCompletedPassages(),
);

/// The text of a reading, keyed by [assignmentsKey] so the cache survives
/// rebuilds. Kept alive across the session: re-reading a chapter the user
/// just scrolled past must not re-decode the book.
final passageTextProvider = FutureProvider.family<List<ChapterText>, String>((
  ref,
  key,
) {
  return ref.watch(bibleTextProvider).forAssignments(assignmentsFromKey(key));
});

/// Every reflection the reader has written, newest first.
final reflectionsProvider = StreamProvider<List<ReadingSession>>(
  (ref) => ref.watch(progressRepositoryProvider).watchReflections(),
);

final completedDayIndexesProvider = StreamProvider<Set<int>>((ref) {
  final plan = ref.watch(activePlanProvider).value;
  if (plan == null) return Stream.value(const <int>{});
  return ref
      .watch(progressRepositoryProvider)
      .watchCompletedDayIndexes(plan.id);
});

final completedByBookProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(progressRepositoryProvider).watchCompletedChaptersByBook(),
);

final openSessionProvider = StreamProvider<ReadingSession?>(
  (ref) => ref.watch(progressRepositoryProvider).watchOpenSession(),
);

/// Whether a (planId, dayIndex) is done.
final dayCompletedProvider = StreamProvider.family<bool, (int, int)>(
  (ref, key) =>
      ref.watch(progressRepositoryProvider).watchDayCompleted(key.$1, key.$2),
);

final streakProvider = StreamProvider<StreakState>(
  (ref) => ref.watch(progressRepositoryProvider).watchStreak(),
);

final completedChapterCountProvider = StreamProvider<int>(
  (ref) => ref.watch(progressRepositoryProvider).watchCompletedChapterCount(),
);

/// Timing for the open session, recomputed every tick from the clock.
final sessionTimingProvider = Provider<SessionTiming?>((ref) {
  ref.watch(tickProvider);
  final session = ref.watch(openSessionProvider).value;
  if (session == null) return null;
  return ref
      .watch(sessionServiceProvider)
      .timing(
        startedAtUtc: session.startedAt.toUtc(),
        required: Duration(milliseconds: session.requiredMs),
        nowUtc: ref.watch(clockProvider).nowUtc(),
      );
});

import '../../core/bible/books.dart';
import '../../core/time/local_date.dart';
import '../passages/passage.dart';
import '../plan/reading_day.dart';
import '../progress/bible_progress.dart';
import '../streak/streak_service.dart';
import 'badges.dart';

/// Everything a badge rule may look at, gathered once per completion.
class AchievementFacts {
  const AchievementFacts({
    required this.progress,
    required this.streakBefore,
    required this.streakAfter,
    required this.totalDaysCompleted,
    required this.planDaysCompleted,
    required this.planSchedule,
    required this.completedDayIndexes,
    required this.completedDay,
    required this.today,
    required this.completedAtLocal,
    this.completedPassages = const [],
  });

  /// Every completed one-time reading, as the range actually read.
  final List<Passage> completedPassages;

  final BibleProgress progress;

  /// The streak as it stood before this completion and after it. The pair
  /// is what makes "came back" decidable.
  final StreakState streakBefore;
  final StreakState streakAfter;

  /// Day completions across every plan ever, and within the active one.
  final int totalDaysCompleted;
  final int planDaysCompleted;

  final List<ReadingDay> planSchedule;
  final Set<int> completedDayIndexes;

  /// The day just completed. For a one-time reading this is a synthetic day
  /// (`dayIndex == -1`) and catch-up / comeback do not apply.
  final ReadingDay completedDay;
  final LocalDate today;
  final DateTime completedAtLocal;

  bool get isPlanDay => completedDay.dayIndex >= 0;

  bool get isCatchUp => isPlanDay && today.isAfter(completedDay.date);

  bool get isComeback {
    if (!isPlanDay) return false;
    final last = streakBefore.lastCompletedOn;
    if (last == null) return false;
    final gap = last.daysUntil(today) - 1; // missed days between
    return gap >= 2 && streakBefore.longest >= 3;
  }

  bool get planCompleted =>
      planSchedule.isNotEmpty && planDaysCompleted >= planSchedule.length;

  /// Any calendar month with ≥10 scheduled days, all of them completed.
  bool get hasPerfectMonth {
    final byMonth = <(int, int), List<ReadingDay>>{};
    for (final d in planSchedule) {
      byMonth.putIfAbsent((d.date.year, d.date.month), () => []).add(d);
    }
    for (final days in byMonth.values) {
      if (days.length < 10) continue;
      if (days.every((d) => completedDayIndexes.contains(d.dayIndex))) {
        return true;
      }
    }
    return false;
  }
}

/// Decides which badges a completion has just earned.
///
/// Pure. The repository stores the result in the same transaction as the
/// completion, so a badge can never be earned by a reading that was then
/// rolled back.
class AchievementService {
  const AchievementService();

  List<BadgeDefinition> evaluate({
    required AchievementFacts facts,
    required Set<String> unlocked,
  }) => [
    for (final b in kBadges)
      if (!unlocked.contains(b.id) && _satisfied(b.rule, facts)) b,
  ];

  bool _satisfied(BadgeRule rule, AchievementFacts f) {
    final p = f.progress;
    return switch (rule) {
      FirstReading() => p.completedChapters > 0,
      StreakReached(:final days) => f.streakAfter.longest >= days,
      DaysCompleted(:final days) => f.totalDaysCompleted >= days,
      ChaptersReached(:final chapters) => p.completedChapters >= chapters,
      FractionReached(:final fraction) => p.fraction >= fraction,
      BooksCompleted(:final books) =>
        p.books.where((b) => b.isDone).length >= books,
      BookCompleted(:final bookId) => p.books.any(
        (b) => b.book.id == bookId && b.isDone,
      ),
      SectionCompleted(:final section) => section.bookIds.every(
        (id) => p.books.any((b) => b.book.id == id && b.isDone),
      ),
      TestamentCompleted(:final testament) => switch (testament) {
        Testament.old => p.oldTestamentDone,
        Testament.newT => p.newTestamentDone,
      },
      BibleCompleted() => p.bibleDone,
      PlanCompleted() => f.planCompleted,
      CaughtUp() => f.isCatchUp,
      CameBack() => f.isComeback,
      // Before 04:00 is still "last night" (the reading day rolls at 04:00),
      // so an early bird is 04:00 up to the hour, never 01:30.
      CompletedBefore(:final hour) =>
        f.completedAtLocal.hour >= 4 && f.completedAtLocal.hour < hour,
      CompletedAfter(:final hour) =>
        f.completedAtLocal.hour >= hour || f.completedAtLocal.hour < 4,
      PerfectMonth() => f.hasPerfectMonth,
      PassagesRead(:final count) => f.completedPassages.length >= count,
      PassageCovered(:final passageId) => f.completedPassages.any(
        (p) => p.covers(passageById(passageId)),
      ),
    };
  }
}

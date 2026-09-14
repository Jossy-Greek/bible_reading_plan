import '../../core/time/local_date.dart';
import '../plan/plan_definition.dart';
import '../plan/reading_day.dart';

/// What a calendar cell should say about one date.
enum DayStatus {
  /// Not a scheduled day of this plan.
  outsidePlan,

  /// Scheduled, still ahead. Cannot be read yet.
  future,

  /// Today, not done yet.
  todayPending,

  /// Scheduled and completed (on time or caught up later).
  completed,

  /// Scheduled, in the past, not completed. Can be caught up.
  missed,
}

/// Answers "what is the state of this date" for one plan. Pure: give it the
/// schedule, the set of completed day indexes and today's date.
class PlanCalendar {
  PlanCalendar({
    required this.plan,
    required this.days,
    required this.completed,
    required this.today,
  });

  final PlanDefinition plan;
  final List<ReadingDay> days;
  final Set<int> completed;
  final LocalDate today;

  LocalDate get start => plan.startDate;
  LocalDate get end => days.isEmpty ? start : days.last.date;

  ReadingDay? dayOn(LocalDate date) {
    final idx = start.daysUntil(date);
    if (idx < 0 || idx >= days.length) return null;
    return days[idx];
  }

  bool isCompleted(ReadingDay d) => completed.contains(d.dayIndex);

  DayStatus statusOn(LocalDate date) {
    final d = dayOn(date);
    if (d == null) return DayStatus.outsidePlan;
    if (isCompleted(d)) return DayStatus.completed;
    if (date.isAfter(today)) return DayStatus.future;
    if (date == today) return DayStatus.todayPending;
    return DayStatus.missed;
  }

  /// Whether a session may be started for this date: scheduled, not done,
  /// and not in the future.
  bool canRead(LocalDate date) {
    final s = statusOn(date);
    return s == DayStatus.todayPending || s == DayStatus.missed;
  }

  /// Completed / missed / still-ahead within one calendar month, and the
  /// share of elapsed scheduled days that were completed (null before any
  /// have elapsed). "Elapsed" includes today only once it is completed.
  ({int completed, int missed, int remaining, double? pace}) monthStats(
    int year,
    int month,
  ) {
    var done = 0, missed = 0, remaining = 0;
    for (final d in days) {
      if (d.date.year != year || d.date.month != month) continue;
      if (isCompleted(d)) {
        done++;
      } else if (d.date.isBefore(today)) {
        missed++;
      } else {
        remaining++;
      }
    }
    final elapsed = done + missed;
    return (
      completed: done,
      missed: missed,
      remaining: remaining,
      pace: elapsed == 0 ? null : done / elapsed,
    );
  }

  int get completedCount => completed.length;
  int get missedCount {
    var n = 0;
    for (final d in days) {
      if (d.date.isBefore(today) && !isCompleted(d)) n++;
    }
    return n;
  }
}

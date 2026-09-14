import '../../core/bible/chapter_reference.dart';
import '../../core/time/local_date.dart';
import '../reading_time/reading_time_service.dart';
import 'plan_definition.dart';
import 'reading_day.dart';

/// Turns a [PlanDefinition] into its schedule.
///
/// Deterministic and cheap (1,189 items at most), so the plan is regenerated
/// on demand and never persisted. Changing the start date or the pace is a
/// re-run, not a migration.
class ReadingPlanGenerator {
  const ReadingPlanGenerator(this.timeService);

  final ReadingTimeService timeService;

  List<ReadingDay> generate(PlanDefinition plan, ReadingPace pace) {
    final chapters = plan.scope.chapters;
    final total = chapters.length;
    if (total == 0) return const [];

    // Never more days than chapters: a 4-chapter book over a week is four
    // reading days, not four readings and three empty ones.
    final days = plan.targetDays.clamp(1, total);
    final base = total ~/ days;
    final extra = total % days; // the first `extra` days carry one more

    final out = <ReadingDay>[];
    var cursor = 0;
    for (var i = 0; i < days; i++) {
      final take = base + (i < extra ? 1 : 0);
      final slice = chapters.sublist(cursor, cursor + take);
      out.add(
        ReadingDay(
          dayIndex: i,
          date: plan.startDate.plusDays(i),
          assignments: coalesce(slice),
          requiredDuration: timeService.estimate(slice, pace),
        ),
      );
      cursor += take;
    }
    assert(cursor == total);
    return out;
  }

  /// The day whose date is [today], or null when today is outside the plan.
  static ReadingDay? dayFor(
    List<ReadingDay> days,
    PlanDefinition plan,
    LocalDate today,
  ) {
    final idx = plan.startDate.daysUntil(today);
    if (idx < 0 || idx >= days.length) return null;
    return days[idx];
  }
}

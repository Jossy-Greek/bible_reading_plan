import 'package:bible_reading_plan/core/time/local_date.dart';
import 'package:bible_reading_plan/domain/calendar/plan_calendar.dart';
import 'package:bible_reading_plan/domain/plan/plan_definition.dart';
import 'package:bible_reading_plan/domain/plan/reading_plan_generator.dart';
import 'package:bible_reading_plan/domain/reading_time/reading_time_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const start = LocalDate(2026, 9, 1);
  final plan = PlanDefinition(
    id: 1,
    scope: const WholeBible(),
    targetDays: 365,
    startDate: start,
  );
  final days = const ReadingPlanGenerator(
    ReadingTimeService(),
  ).generate(plan, ReadingPace.normal);

  PlanCalendar cal(Set<int> done, LocalDate today) =>
      PlanCalendar(plan: plan, days: days, completed: done, today: today);

  test('the five statuses', () {
    final c = cal({0, 1, 3}, start.plusDays(4));
    expect(c.statusOn(start.plusDays(-1)), DayStatus.outsidePlan);
    expect(c.statusOn(start), DayStatus.completed);
    expect(c.statusOn(start.plusDays(2)), DayStatus.missed);
    expect(c.statusOn(start.plusDays(3)), DayStatus.completed);
    expect(c.statusOn(start.plusDays(4)), DayStatus.todayPending);
    expect(c.statusOn(start.plusDays(5)), DayStatus.future);
    expect(c.statusOn(start.plusDays(365)), DayStatus.outsidePlan);
  });

  test('today completed reads completed, not pending', () {
    final c = cal({0}, start);
    expect(c.statusOn(start), DayStatus.completed);
  });

  test('missed and today can be read; future and done cannot', () {
    final c = cal({0}, start.plusDays(2));
    expect(c.canRead(start), isFalse);
    expect(c.canRead(start.plusDays(1)), isTrue);
    expect(c.canRead(start.plusDays(2)), isTrue);
    expect(c.canRead(start.plusDays(3)), isFalse);
  });

  test('counts', () {
    final c = cal({0, 2}, start.plusDays(5));
    expect(c.completedCount, 2);
    expect(c.missedCount, 3); // days 1, 3, 4
    expect(c.end, start.plusDays(364));
  });
}

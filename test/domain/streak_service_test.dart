import 'package:bible_reading_plan/core/time/local_date.dart';
import 'package:bible_reading_plan/domain/streak/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const svc = StreakService();
  const d1 = LocalDate(2026, 9, 14);

  test('consecutive days grow the streak and the record', () {
    var s = const StreakState();
    for (var i = 0; i < 7; i++) {
      s = svc.record(s, d1.plusDays(i));
    }
    expect(s.current, 7);
    expect(s.longest, 7);
    expect(s.lastCompletedOn, d1.plusDays(6));
  });

  test('a second completion on the same day changes nothing', () {
    final s = svc.record(svc.record(const StreakState(), d1), d1);
    expect(s.current, 1);
  });

  test('a gap of two or more days starts over but keeps the record', () {
    var s = const StreakState();
    for (var i = 0; i < 5; i++) {
      s = svc.record(s, d1.plusDays(i));
    }
    s = svc.record(s, d1.plusDays(7)); // skipped days 5 and 6
    expect(s.current, 1);
    expect(s.longest, 5);
  });

  test('a gap of exactly one day is covered by the month grace day', () {
    var s = const StreakState();
    for (var i = 0; i < 5; i++) {
      s = svc.record(s, d1.plusDays(i));
    }
    s = svc.record(s, d1.plusDays(6)); // skipped day 5 only
    expect(s.current, 6, reason: 'see grace_day_test.dart for the full rules');
    expect(s.graceUsedOn, d1.plusDays(5));
  });

  test('catching up an earlier day never moves the streak', () {
    var s = svc.record(const StreakState(), d1.plusDays(3));
    s = svc.record(s, d1); // reading day 1's chapters on day 4
    expect(s.current, 1);
    expect(s.lastCompletedOn, d1.plusDays(3));
  });

  test('displayed streak dies lazily once grace cannot reach it', () {
    final s = svc.record(const StreakState(), d1);
    expect(svc.displayed(s, d1), 1);
    expect(svc.displayed(s, d1.plusDays(1)), 1, reason: 'still alive today');
    expect(
      svc.displayed(s, d1.plusDays(2)),
      1,
      reason: 'yesterday was missed, but this month grace can still cover it',
    );
    expect(svc.heldByGrace(s, d1.plusDays(2)), isTrue);
    expect(
      svc.displayed(s, d1.plusDays(3)),
      0,
      reason: 'two days missed is beyond any grace',
    );
  });

  test('month and year ends are consecutive days', () {
    var s = svc.record(const StreakState(), const LocalDate(2026, 12, 31));
    s = svc.record(s, const LocalDate(2027, 1, 1));
    expect(s.current, 2);
  });
}

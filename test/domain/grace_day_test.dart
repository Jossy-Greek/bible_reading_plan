import 'package:bible_reading_plan/core/time/local_date.dart';
import 'package:bible_reading_plan/domain/streak/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const s = StreakService();
  const d1 = LocalDate(2026, 9, 10);
  LocalDate day(int n) => d1.plusDays(n - 1);

  StreakState runOf(int n, {LocalDate? from}) {
    var st = const StreakState();
    for (var i = 0; i < n; i++) {
      st = s.record(st, (from ?? d1).plusDays(i));
    }
    return st;
  }

  test('an unbroken run still just counts up', () {
    final st = runOf(5);
    expect(st.current, 5);
    expect(st.longest, 5);
    expect(st.graceUsedOn, isNull);
  });

  test('one missed day is covered, and the run continues', () {
    final before = runOf(5); // days 1..5
    expect(s.wouldUseGrace(before, day(7)), isTrue);

    final after = s.record(before, day(7)); // day 6 missed
    expect(after.current, 6, reason: 'the run continues through the gap');
    expect(after.graceUsedOn, day(6), reason: 'the covered day is recorded');
  });

  test('two missed days are not covered', () {
    final before = runOf(5);
    expect(s.wouldUseGrace(before, day(8)), isFalse);
    final after = s.record(before, day(8));
    expect(after.current, 1);
    expect(after.graceUsedOn, isNull);
  });

  test('only one grace per calendar month', () {
    var st = runOf(5); // days 1..5 of September
    st = s.record(st, day(7)); // grace covers 6 Sep
    expect(st.current, 6);

    st = s.record(st, day(9)); // 8 Sep missed, same month
    expect(st.current, 1, reason: 'September has already spent its grace');
  });

  test('a new month brings a new grace day', () {
    // Run through to 29 September, grace spent on 21 September.
    var st = StreakState(
      current: 9,
      longest: 9,
      lastCompletedOn: const LocalDate(2026, 9, 29),
      graceUsedOn: const LocalDate(2026, 9, 21),
    );
    // Miss 30 September, read on 1 October: the missed day is September's,
    // and September is spent.
    final sameMonth = s.record(st, const LocalDate(2026, 10, 1));
    expect(sameMonth.current, 1);

    // But miss 2 October and read on 3 October: October's own grace.
    st = s.record(st, const LocalDate(2026, 10, 1));
    st = s.record(st, const LocalDate(2026, 10, 3));
    expect(st.current, 2);
    expect(st.graceUsedOn, const LocalDate(2026, 10, 2));
  });

  test('the grace is attributed to the day it covers, not the day read', () {
    // Last read 31 August; miss 1 September; read 2 September. The covered
    // day is in September, so September's grace is the one spent.
    final st = StreakState(
      current: 4,
      longest: 4,
      lastCompletedOn: const LocalDate(2026, 8, 31),
    );
    final after = s.record(st, const LocalDate(2026, 9, 2));
    expect(after.current, 5);
    expect(after.graceUsedOn, const LocalDate(2026, 9, 1));
  });

  test('a held streak still shows, and says it is held', () {
    final st = runOf(5); // last read day 5
    // Today is day 7: day 6 was missed but grace can still cover it.
    expect(s.heldByGrace(st, day(7)), isTrue);
    expect(s.displayed(st, day(7)), 5);

    // Today is day 8: two days missed, nothing left to hold.
    expect(s.heldByGrace(st, day(8)), isFalse);
    expect(s.displayed(st, day(8)), 0);
  });

  test('a streak is not held when the month grace is already spent', () {
    var st = runOf(5);
    st = s.record(st, day(7)); // spends September's grace on day 6
    // Last read day 7; today day 9, so day 8 was missed.
    expect(s.heldByGrace(st, day(9)), isFalse);
    expect(s.displayed(st, day(9)), 0);
  });

  test('reading today or yesterday is alive without touching grace', () {
    final st = runOf(3);
    expect(s.displayed(st, day(3)), 3);
    expect(s.displayed(st, day(4)), 3);
    expect(s.heldByGrace(st, day(3)), isFalse);
    expect(s.heldByGrace(st, day(4)), isFalse);
  });

  test('catching up an old day still never moves the streak', () {
    final st = runOf(5);
    final after = s.record(st, day(2));
    expect(after.current, 5);
    expect(after.lastCompletedOn, day(5));
    expect(after.graceUsedOn, isNull);
  });

  test('a second reading the same day changes nothing', () {
    final st = runOf(5);
    expect(s.record(st, day(5)), same(st));
  });

  test('grace never inflates the longest run beyond the current one', () {
    final st = s.record(runOf(5), day(7));
    expect(st.longest, 6);
    expect(st.longest, st.current);
  });

  test('a first ever reading needs no grace', () {
    const empty = StreakState();
    expect(s.wouldUseGrace(empty, d1), isFalse);
    expect(s.heldByGrace(empty, d1), isFalse);
    expect(s.displayed(empty, d1), 0);
    expect(s.record(empty, d1).current, 1);
  });
}

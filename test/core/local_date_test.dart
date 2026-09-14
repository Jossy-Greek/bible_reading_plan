import 'package:bible_reading_plan/core/time/clock.dart';
import 'package:bible_reading_plan/core/time/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('arithmetic crosses month ends and leap days', () {
    expect(
      const LocalDate(2026, 1, 31).plusDays(1),
      const LocalDate(2026, 2, 1),
    );
    expect(
      const LocalDate(2028, 2, 28).plusDays(1),
      const LocalDate(2028, 2, 29),
    );
    expect(
      const LocalDate(2027, 2, 28).plusDays(1),
      const LocalDate(2027, 3, 1),
    );
    expect(
      const LocalDate(2026, 12, 31).plusDays(1),
      const LocalDate(2027, 1, 1),
    );
    expect(
      const LocalDate(2026, 3, 1).plusDays(-1),
      const LocalDate(2026, 2, 28),
    );
  });

  test('epochDay round-trips and subtracts', () {
    const d = LocalDate(2026, 9, 14);
    expect(LocalDate.fromEpochDay(d.epochDay), d);
    expect(
      const LocalDate(2026, 9, 14).daysUntil(const LocalDate(2027, 9, 14)),
      365,
    );
    expect(const LocalDate(1970, 1, 1).epochDay, 0);
  });

  test('a 365-day plan started 2028-01-01 ends 2028-12-30 (leap year)', () {
    expect(
      const LocalDate(2028, 1, 1).plusDays(364),
      const LocalDate(2028, 12, 30),
    );
  });

  test('the reading day rolls over at 04:00, not midnight', () {
    final c = FixedClock(DateTime(2026, 9, 15, 3, 59));
    expect(c.today(), const LocalDate(2026, 9, 14));
    c.set(DateTime(2026, 9, 15, 4, 0));
    expect(c.today(), const LocalDate(2026, 9, 15));
    c.set(DateTime(2026, 9, 14, 23, 59));
    expect(c.today(), const LocalDate(2026, 9, 14));
  });
}

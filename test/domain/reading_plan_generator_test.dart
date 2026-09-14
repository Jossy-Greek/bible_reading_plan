import 'package:bible_reading_plan/core/bible/books.dart';
import 'package:bible_reading_plan/core/bible/chapter_reference.dart';
import 'package:bible_reading_plan/core/time/local_date.dart';
import 'package:bible_reading_plan/domain/plan/plan_definition.dart';
import 'package:bible_reading_plan/domain/plan/reading_plan_generator.dart';
import 'package:bible_reading_plan/domain/reading_time/reading_time_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const gen = ReadingPlanGenerator(ReadingTimeService());
  const start = LocalDate(2026, 9, 14);

  PlanDefinition plan(PlanScope scope, int days) =>
      PlanDefinition(id: 1, scope: scope, targetDays: days, startDate: start);

  test('whole Bible in 365 days: 94 days of 4 and 271 days of 3', () {
    final days = gen.generate(
      plan(const WholeBible(), 365),
      ReadingPace.normal,
    );
    expect(days.length, 365);
    expect(days.where((d) => d.chapterCount == 4).length, 94);
    expect(days.where((d) => d.chapterCount == 3).length, 271);
    expect(days.first.chapterCount, 4, reason: 'remainder goes first');
    expect(days.last.chapterCount, 3);
    expect(days.first.date, start);
    expect(days.last.date, start.plusDays(364));
  });

  test('every chapter appears exactly once, in canonical order', () {
    final days = gen.generate(
      plan(const WholeBible(), 365),
      ReadingPace.normal,
    );
    final all = days.expand((d) => d.chapters).toList();
    expect(all.length, kTotalChapters);
    expect(all, kAllChapters);
    expect(all.toSet().length, kTotalChapters);
  });

  test('a day may span a book boundary', () {
    final days = gen.generate(
      plan(const WholeBible(), 238),
      ReadingPace.normal,
    );
    // 1189 = 238*4 + 237 → first 237 days carry 5, last day 4.
    expect(days.where((d) => d.chapterCount == 5).length, 237);
    expect(days.last.chapterCount, 4, reason: 'final day is shorter');
    // Genesis is exactly 10 days of 5 and Exodus exactly 8, so the first
    // crossing is Leviticus (27 chapters) into Numbers on day 24.
    final crossing = days.firstWhere((d) => d.assignments.length > 1);
    expect(crossing.label, 'Leviticus 26–27 · Numbers 1–3');
    expect(crossing.dayIndex, 23);
  });

  test('the brief\'s example: Genesis 49–50 + Exodus on one day', () {
    // 365 days → the first 94 days carry 4 chapters, so day 13 (index 12)
    // holds Genesis 49–50 and Exodus 1–2.
    final days = gen.generate(
      plan(const WholeBible(), 365),
      ReadingPace.normal,
    );
    expect(days[12].label, 'Genesis 49–50 · Exodus 1–2');
    expect(days[12].assignments.length, 2);
    expect(days[12].chapterCount, 4);
  });

  test('a book in a week', () {
    final days = gen.generate(
      plan(const BookScope('genesis'), 7),
      ReadingPace.normal,
    );
    expect(days.length, 7);
    expect(days.fold<int>(0, (s, d) => s + d.chapterCount), 50);
    expect(days.first.label, 'Genesis 1–8'); // 50 = 7*7 + 1
    expect(days.last.label, 'Genesis 44–50');
  });

  test('never more days than chapters', () {
    final days = gen.generate(
      plan(const BookScope('jude'), 7),
      ReadingPace.normal,
    );
    expect(days.length, 1);
    expect(days.single.label, 'Jude 1');
    final ruth = gen.generate(
      plan(const BookScope('ruth'), 7),
      ReadingPace.normal,
    );
    expect(ruth.length, 4);
  });

  test('testament scopes', () {
    final nt = gen.generate(
      plan(const TestamentScope(Testament.newT), 90),
      ReadingPace.normal,
    );
    expect(nt.fold<int>(0, (s, d) => s + d.chapterCount), 260);
    expect(nt.first.assignments.first.bookId, 'matthew');
    final last = nt.last.assignments.last;
    expect(last.bookId, 'revelation');
    expect(last.toChapter, 22);
  });

  test('dayFor maps today to the schedule and null outside it', () {
    final p = plan(const WholeBible(), 365);
    final days = gen.generate(p, ReadingPace.normal);
    expect(ReadingPlanGenerator.dayFor(days, p, start)!.dayIndex, 0);
    expect(
      ReadingPlanGenerator.dayFor(days, p, start.plusDays(100))!.dayIndex,
      100,
    );
    expect(ReadingPlanGenerator.dayFor(days, p, start.plusDays(-1)), isNull);
    expect(ReadingPlanGenerator.dayFor(days, p, start.plusDays(365)), isNull);
  });

  test('scope codes round-trip', () {
    for (final s in [
      const WholeBible(),
      const TestamentScope(Testament.old),
      const TestamentScope(Testament.newT),
      const BookScope('psalms'),
    ]) {
      expect(PlanScope.fromCode(s.code).code, s.code);
    }
  });
}

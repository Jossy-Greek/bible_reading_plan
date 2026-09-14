import 'package:bible_reading_plan/core/time/local_date.dart';
import 'package:bible_reading_plan/domain/progress/bible_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const start = LocalDate(2026, 9, 1);

  test('totals, testaments, percent', () {
    final p = BibleProgress.compute(
      completedByBook: {'genesis': 50, 'matthew': 28, 'psalms': 49},
      daysCompleted: 30,
      totalDays: 365,
      planStart: start,
      today: start.plusDays(29),
    );
    expect(p.completedChapters, 127);
    expect(p.remainingChapters, 1062);
    expect(p.percentLabel, '10.7%');
    expect(p.oldTestamentCompleted, 99);
    expect(p.newTestamentCompleted, 28);
    expect(p.books.firstWhere((b) => b.book.id == 'genesis').isDone, isTrue);
    expect(p.books.firstWhere((b) => b.book.id == 'psalms').isDone, isFalse);
  });

  test('estimate: on schedule → the plan\'s own end date', () {
    // 30 completions in 30 days → rate 1 → 335 more days from today.
    final e = BibleProgress.estimateCompletion(
      daysCompleted: 30,
      totalDays: 365,
      planStart: start,
      today: start.plusDays(29),
    );
    expect(e, start.plusDays(29 + 335));
    expect(e, start.plusDays(364));
  });

  test('estimate: half pace doubles the remaining time', () {
    final e = BibleProgress.estimateCompletion(
      daysCompleted: 15,
      totalDays: 365,
      planStart: start,
      today: start.plusDays(29),
    );
    expect(e, start.plusDays(29 + 700));
  });

  test('estimate: nothing read yet → nominal end; finished → null', () {
    expect(
      BibleProgress.estimateCompletion(
        daysCompleted: 0,
        totalDays: 365,
        planStart: start,
        today: start,
      ),
      start.plusDays(364),
    );
    expect(
      BibleProgress.estimateCompletion(
        daysCompleted: 365,
        totalDays: 365,
        planStart: start,
        today: start.plusDays(400),
      ),
      isNull,
    );
  });
}

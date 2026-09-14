import '../../core/bible/books.dart';
import '../../core/time/local_date.dart';

class BookProgress {
  const BookProgress(this.book, this.completed);
  final BibleBook book;
  final int completed;
  bool get isDone => completed >= book.chapters;
  double get fraction => completed / book.chapters;
}

/// Everything the Progress screen shows, computed from the per-book
/// completion counts (which are plan-independent) plus the active plan's
/// pace so far.
class BibleProgress {
  BibleProgress._({
    required this.books,
    required this.completedChapters,
    required this.oldTestamentCompleted,
    required this.newTestamentCompleted,
    required this.daysCompleted,
    required this.totalDays,
    required this.estimatedCompletion,
  });

  factory BibleProgress.compute({
    required Map<String, int> completedByBook,
    required int daysCompleted,
    required int totalDays,
    required LocalDate planStart,
    required LocalDate today,
  }) {
    final books = [
      for (final b in kBibleBooks) BookProgress(b, completedByBook[b.id] ?? 0),
    ];
    int sum(Testament t) => books
        .where((p) => p.book.testament == t)
        .fold(0, (s, p) => s + p.completed);
    final ot = sum(Testament.old);
    final nt = sum(Testament.newT);
    return BibleProgress._(
      books: books,
      completedChapters: ot + nt,
      oldTestamentCompleted: ot,
      newTestamentCompleted: nt,
      daysCompleted: daysCompleted,
      totalDays: totalDays,
      estimatedCompletion: estimateCompletion(
        daysCompleted: daysCompleted,
        totalDays: totalDays,
        planStart: planStart,
        today: today,
      ),
    );
  }

  final List<BookProgress> books;
  final int completedChapters;
  final int oldTestamentCompleted;
  final int newTestamentCompleted;
  final int daysCompleted;
  final int totalDays;

  /// Null when the plan is finished.
  final LocalDate? estimatedCompletion;

  int get totalChapters => kTotalChapters;
  int get remainingChapters => totalChapters - completedChapters;
  double get fraction => completedChapters / totalChapters;
  String get percentLabel => '${(fraction * 100).toStringAsFixed(1)}%';
  bool get oldTestamentDone => oldTestamentCompleted >= 929;
  bool get newTestamentDone => newTestamentCompleted >= 260;
  bool get bibleDone => completedChapters >= totalChapters;

  /// When the plan will end at the pace actually kept so far.
  ///
  /// Pace = completed days per calendar day since the start. Someone reading
  /// every day finishes on the plan's own end date; someone reading every
  /// other day sees a date twice as far out. Before any completion the plan's
  /// nominal end is the only honest answer.
  static LocalDate? estimateCompletion({
    required int daysCompleted,
    required int totalDays,
    required LocalDate planStart,
    required LocalDate today,
  }) {
    final remaining = totalDays - daysCompleted;
    if (remaining <= 0) return null;
    if (daysCompleted == 0) return planStart.plusDays(totalDays - 1);
    final elapsed = planStart.daysUntil(today) + 1;
    final rate = (daysCompleted / (elapsed < 1 ? 1 : elapsed)).clamp(0.0, 1.0);
    final daysNeeded = (remaining / rate).ceil();
    return today.plusDays(daysNeeded);
  }
}

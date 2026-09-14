import '../../core/bible/chapter_reference.dart';
import '../../core/time/local_date.dart';

/// One scheduled day of a plan. Generated, never stored.
class ReadingDay {
  const ReadingDay({
    required this.dayIndex,
    required this.date,
    required this.assignments,
    required this.requiredDuration,
  });

  /// 0-based position in the plan.
  final int dayIndex;
  final LocalDate date;
  final List<ReadingAssignment> assignments;
  final Duration requiredDuration;

  int get chapterCount => assignments.fold(0, (s, a) => s + a.chapterCount);
  int get verseCount => assignments.fold(0, (s, a) => s + a.verses);
  Iterable<ChapterReference> get chapters =>
      assignments.expand((a) => a.chapters);

  /// "Genesis 49–50 · Exodus 1–3"
  String get label => assignmentsLabel(assignments);
}

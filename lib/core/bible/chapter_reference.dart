import 'books.dart';
import 'verse_counts.dart';

/// One chapter of one book: the unit of reading progress.
class ChapterReference implements Comparable<ChapterReference> {
  const ChapterReference(this.bookId, this.chapter);

  final String bookId;

  /// 1-based.
  final int chapter;

  BibleBook get book => bookById(bookId);
  int get verses => kVerseCounts[bookId]![chapter - 1];

  /// Position in the canonical flat order, Genesis 1 = 0.
  int get ordinal => _ordinalOf(this);

  @override
  int compareTo(ChapterReference other) => ordinal.compareTo(other.ordinal);

  @override
  bool operator ==(Object other) =>
      other is ChapterReference &&
      other.bookId == bookId &&
      other.chapter == chapter;

  @override
  int get hashCode => Object.hash(bookId, chapter);

  @override
  String toString() => '${book.name} $chapter';
}

/// A contiguous run of chapters within ONE book: "Genesis 49–50".
///
/// A reading day is a list of these, so a day that crosses a book boundary is
/// simply two assignments. The generator produces them; nothing else builds
/// them by hand.
class ReadingAssignment {
  const ReadingAssignment({
    required this.bookId,
    required this.fromChapter,
    required this.toChapter,
  }) : assert(fromChapter <= toChapter);

  final String bookId;
  final int fromChapter;
  final int toChapter;

  BibleBook get book => bookById(bookId);
  int get chapterCount => toChapter - fromChapter + 1;

  Iterable<ChapterReference> get chapters => Iterable.generate(
    chapterCount,
    (i) => ChapterReference(bookId, fromChapter + i),
  );

  int get verses => chapters.fold(0, (s, c) => s + c.verses);

  /// "Genesis 1–5", or "Obadiah 1" for a single chapter.
  String get label => fromChapter == toChapter
      ? '${book.name} $fromChapter'
      : '${book.name} $fromChapter–$toChapter';

  @override
  String toString() => label;
}

/// Every chapter in canonical order. 1,189 entries.
final List<ChapterReference> kAllChapters = [
  for (final b in kBibleBooks)
    for (var c = 1; c <= b.chapters; c++) ChapterReference(b.id, c),
];

final Map<ChapterReference, int> _ordinals = {
  for (var i = 0; i < kAllChapters.length; i++) kAllChapters[i]: i,
};

int _ordinalOf(ChapterReference c) => _ordinals[c]!;

/// Collapse a run of chapters into the fewest assignments, closing a range
/// whenever the book changes. This is the only place a book boundary is
/// noticed; the plan generator hands it flat slices and never special-cases
/// Genesis 50 → Exodus 1 itself.
List<ReadingAssignment> coalesce(List<ChapterReference> chapters) {
  if (chapters.isEmpty) return const [];
  final out = <ReadingAssignment>[];
  var start = chapters.first;
  var prev = chapters.first;
  for (final c in chapters.skip(1)) {
    final contiguous = c.bookId == prev.bookId && c.chapter == prev.chapter + 1;
    if (!contiguous) {
      out.add(
        ReadingAssignment(
          bookId: start.bookId,
          fromChapter: start.chapter,
          toChapter: prev.chapter,
        ),
      );
      start = c;
    }
    prev = c;
  }
  out.add(
    ReadingAssignment(
      bookId: start.bookId,
      fromChapter: start.chapter,
      toChapter: prev.chapter,
    ),
  );
  return out;
}

/// "Genesis 49–50 · Exodus 1–3".
String assignmentsLabel(List<ReadingAssignment> a) =>
    a.map((x) => x.label).join(' · ');

/// "genesis:49-50,exodus:1-1" — a stable, comparable key for a day's
/// reading. A `FutureProvider.family` keyed on the list itself would miss
/// its cache on every rebuild, because Lists compare by identity.
String assignmentsKey(List<ReadingAssignment> a) =>
    a.map((x) => '${x.bookId}:${x.fromChapter}-${x.toChapter}').join(',');

List<ReadingAssignment> assignmentsFromKey(String key) => [
  for (final part in key.split(','))
    if (part.isNotEmpty)
      ReadingAssignment(
        bookId: part.split(':').first,
        fromChapter: int.parse(part.split(':').last.split('-').first),
        toChapter: int.parse(part.split(':').last.split('-').last),
      ),
];

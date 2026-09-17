import '../../core/bible/books.dart';
import '../../core/bible/chapter_reference.dart';

/// A reading outside the plan: one contiguous range in one book, read in one
/// timed sitting. "Sermon on the Mount" is Matthew 5–7.
class Passage {
  const Passage({
    required this.title,
    required this.bookId,
    required this.fromChapter,
    required this.toChapter,
    this.id,
  }) : assert(fromChapter <= toChapter);

  /// Stable key for curated passages; null for a custom range.
  final String? id;
  final String title;
  final String bookId;
  final int fromChapter;
  final int toChapter;

  ReadingAssignment get assignment => ReadingAssignment(
    bookId: bookId,
    fromChapter: fromChapter,
    toChapter: toChapter,
  );

  /// "Matthew 5–7"
  String get reference => assignment.label;
  int get chapterCount => assignment.chapterCount;
  int get verses => assignment.verses;

  /// Whether a completed reading of [this] also covers [other]: same book,
  /// [other]'s range inside ours. Reading Matthew 4–8 covers the Sermon.
  bool covers(Passage other) =>
      other.bookId == bookId &&
      other.fromChapter >= fromChapter &&
      other.toChapter <= toChapter;

  static Passage custom(String bookId, int from, int to) => Passage(
    title: bookById(bookId).name,
    bookId: bookId,
    fromChapter: from,
    toChapter: to,
  );
}

/// Well-known passages offered on the picker. Order is display order.
const List<Passage> kPassages = [
  Passage(
    id: 'creation',
    title: 'Creation',
    bookId: 'genesis',
    fromChapter: 1,
    toChapter: 2,
  ),
  Passage(
    id: 'ten_commandments',
    title: 'The Ten Commandments',
    bookId: 'exodus',
    fromChapter: 20,
    toChapter: 20,
  ),
  Passage(
    id: 'psalm_23',
    title: 'The Shepherd Psalm',
    bookId: 'psalms',
    fromChapter: 23,
    toChapter: 23,
  ),
  Passage(
    id: 'psalm_51',
    title: 'A Psalm of Repentance',
    bookId: 'psalms',
    fromChapter: 51,
    toChapter: 51,
  ),
  Passage(
    id: 'psalm_119',
    title: 'The Longest Psalm',
    bookId: 'psalms',
    fromChapter: 119,
    toChapter: 119,
  ),
  Passage(
    id: 'suffering_servant',
    title: 'The Suffering Servant',
    bookId: 'isaiah',
    fromChapter: 52,
    toChapter: 53,
  ),
  Passage(
    id: 'sermon_on_the_mount',
    title: 'Sermon on the Mount',
    bookId: 'matthew',
    fromChapter: 5,
    toChapter: 7,
  ),
  Passage(
    id: 'passion',
    title: 'The Passion and Resurrection',
    bookId: 'matthew',
    fromChapter: 26,
    toChapter: 28,
  ),
  Passage(
    id: 'prodigal',
    title: 'The Prodigal Son and Other Parables',
    bookId: 'luke',
    fromChapter: 15,
    toChapter: 15,
  ),
  Passage(
    id: 'word_became_flesh',
    title: 'The Word Became Flesh',
    bookId: 'john',
    fromChapter: 1,
    toChapter: 1,
  ),
  Passage(
    id: 'upper_room',
    title: 'The Upper Room Discourse',
    bookId: 'john',
    fromChapter: 13,
    toChapter: 17,
  ),
  Passage(
    id: 'romans_8',
    title: 'Life in the Spirit',
    bookId: 'romans',
    fromChapter: 8,
    toChapter: 8,
  ),
  Passage(
    id: 'love_chapter',
    title: 'The Love Chapter',
    bookId: '1_corinthians',
    fromChapter: 13,
    toChapter: 13,
  ),
  Passage(
    id: 'faith_hall',
    title: 'The Hall of Faith',
    bookId: 'hebrews',
    fromChapter: 11,
    toChapter: 11,
  ),
  Passage(
    id: 'new_creation',
    title: 'The New Heaven and Earth',
    bookId: 'revelation',
    fromChapter: 21,
    toChapter: 22,
  ),
];

Passage passageById(String id) => kPassages.firstWhere((p) => p.id == id);

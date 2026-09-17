import 'package:bible_reading_plan/core/bible/bible_text.dart';
import 'package:bible_reading_plan/core/bible/books.dart';
import 'package:bible_reading_plan/core/bible/chapter_reference.dart';
import 'package:bible_reading_plan/core/bible/verse_counts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bible = BibleText();

  test('every book ships, and its shape matches the verse table', () async {
    var chapters = 0, verses = 0;
    for (final book in kBibleBooks) {
      final expected = kVerseCounts[book.id]!;
      expect(
        expected.length,
        book.chapters,
        reason: '${book.name}: books.dart and verse_counts.dart disagree',
      );
      for (var c = 1; c <= book.chapters; c++) {
        final text = await bible.chapter(ChapterReference(book.id, c));
        expect(
          text.verseCount,
          expected[c - 1],
          reason:
              '${book.name} $c: text has ${text.verseCount} verses, '
              'the table used for reading times says ${expected[c - 1]}',
        );
        expect(
          text.verses.every((v) => v.trim().isNotEmpty),
          isTrue,
          reason: '${book.name} $c has an empty verse',
        );
        chapters++;
        verses += text.verseCount;
      }
    }
    expect(chapters, 1189);
    expect(verses, 31102);
  });

  test('spot checks against the KJV', () async {
    expect(
      await bible.verse('genesis', 1, 1),
      'In the beginning God created the heaven and the earth.',
    );
    expect(await bible.verse('john', 11, 35), 'Jesus wept.');
    // The shortest and longest chapters in the Bible.
    expect(
      (await bible.chapter(const ChapterReference('psalms', 117))).verseCount,
      2,
    );
    expect(
      (await bible.chapter(const ChapterReference('psalms', 119))).verseCount,
      176,
    );
    expect(
      (await bible.chapter(const ChapterReference('3_john', 1))).verseCount,
      14,
    );
    expect(
      (await bible.chapter(
        const ChapterReference('revelation', 22),
      )).verseCount,
      21,
    );
  });

  test('an assignment resolves to its chapters in reading order', () async {
    final texts = await bible.forAssignments([
      const ReadingAssignment(
        bookId: 'genesis',
        fromChapter: 49,
        toChapter: 50,
      ),
      const ReadingAssignment(bookId: 'exodus', fromChapter: 1, toChapter: 1),
    ]);
    expect(texts.map((t) => t.reference.toString()), [
      'Genesis 49',
      'Genesis 50',
      'Exodus 1',
    ]);
    expect(
      texts.first.verses.first,
      startsWith('And Jacob called unto his sons'),
    );
  });

  test('a book is decoded once, however many chapters are asked for', () async {
    final fresh = BibleText();
    expect(fresh.isLoaded('mark'), isFalse);
    await Future.wait([
      fresh.chapter(const ChapterReference('mark', 1)),
      fresh.chapter(const ChapterReference('mark', 9)),
      fresh.chapter(const ChapterReference('mark', 16)),
    ]);
    expect(fresh.isLoaded('mark'), isTrue);
  });
}

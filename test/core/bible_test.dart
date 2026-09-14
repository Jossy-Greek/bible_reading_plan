import 'package:bible_reading_plan/core/bible/books.dart';
import 'package:bible_reading_plan/core/bible/chapter_reference.dart';
import 'package:bible_reading_plan/core/bible/verse_counts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('66 books, 1,189 chapters, 31,102 verses', () {
    expect(kBibleBooks.length, 66);
    expect(kBibleBooks.fold<int>(0, (s, b) => s + b.chapters), kTotalChapters);
    expect(kAllChapters.length, kTotalChapters);
    final verses = kVerseCounts.values.fold<int>(
      0,
      (s, l) => s + l.fold(0, (a, b) => a + b),
    );
    expect(verses, kTotalVerses);
    expect(booksIn(Testament.old).fold<int>(0, (s, b) => s + b.chapters), 929);
    expect(booksIn(Testament.newT).fold<int>(0, (s, b) => s + b.chapters), 260);
  });

  test('every book has one verse-count entry per chapter', () {
    for (final b in kBibleBooks) {
      expect(kVerseCounts[b.id]!.length, b.chapters, reason: b.name);
    }
  });

  test('KJV spot checks', () {
    expect(const ChapterReference('genesis', 1).verses, 31);
    expect(const ChapterReference('psalms', 119).verses, 176);
    expect(const ChapterReference('psalms', 117).verses, 2);
    expect(const ChapterReference('john', 3).verses, 36);
    expect(const ChapterReference('3_john', 1).verses, 14);
    expect(const ChapterReference('revelation', 22).verses, 21);
  });

  test('coalesce closes a range at a book boundary', () {
    final slice = kAllChapters.sublist(48, 53); // Genesis 49 … Exodus 3
    final a = coalesce(slice);
    expect(a.length, 2);
    expect(a[0].label, 'Genesis 49–50');
    expect(a[1].label, 'Exodus 1–3');
    expect(assignmentsLabel(a), 'Genesis 49–50 · Exodus 1–3');
  });

  test('single-chapter assignment has a single-number label', () {
    expect(
      coalesce([const ChapterReference('obadiah', 1)]).single.label,
      'Obadiah 1',
    );
  });
}

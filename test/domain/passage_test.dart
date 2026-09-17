import 'package:bible_reading_plan/core/bible/books.dart';
import 'package:bible_reading_plan/domain/passages/passage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every curated passage names a real book and a valid range', () {
    final ids = <String>{};
    for (final p in kPassages) {
      final book = bookById(p.bookId);
      expect(
        p.fromChapter >= 1 && p.toChapter <= book.chapters,
        isTrue,
        reason: p.title,
      );
      expect(ids.add(p.id!), isTrue, reason: 'duplicate id ${p.id}');
    }
  });

  test('the Sermon on the Mount is Matthew 5–7, 111 verses', () {
    final p = passageById('sermon_on_the_mount');
    expect(p.reference, 'Matthew 5–7');
    expect(p.verses, 48 + 34 + 29);
  });

  test('a wider reading covers a narrower one in the same book only', () {
    final sermon = passageById('sermon_on_the_mount');
    expect(Passage.custom('matthew', 4, 8).covers(sermon), isTrue);
    expect(Passage.custom('matthew', 5, 7).covers(sermon), isTrue);
    expect(Passage.custom('matthew', 6, 7).covers(sermon), isFalse);
    expect(Passage.custom('luke', 5, 7).covers(sermon), isFalse);
  });

  test('a custom passage takes the book name as its title', () {
    expect(Passage.custom('psalms', 23, 23).title, 'Psalms');
    expect(Passage.custom('psalms', 23, 23).reference, 'Psalms 23');
  });
}

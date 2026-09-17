import 'package:bible_reading_plan/core/bible/bible_text.dart';
import 'package:bible_reading_plan/core/bible/books.dart';
import 'package:bible_reading_plan/core/verses.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bible = BibleText();

  test('every quoted verse is the bundled text, exactly', () async {
    expect(kVerses, isNotEmpty);
    for (final v in kVerses) {
      // "Philippians 4:13" / "1 Peter 5:7"
      final m = RegExp(r'^(.+) (\d+):(\d+)$').firstMatch(v.ref);
      expect(m, isNotNull, reason: 'unparseable reference: ${v.ref}');
      final book = kBibleBooks.firstWhere(
        (b) => b.name == m!.group(1),
        orElse: () => throw StateError('no such book in ${v.ref}'),
      );
      final actual = await bible.verse(
        book.id,
        int.parse(m!.group(2)!),
        int.parse(m.group(3)!),
      );
      expect(
        v.text,
        actual,
        reason:
            '${v.ref} does not match the bundled KJV. Regenerate the list '
            'rather than editing it by hand — an abridged quote under a '
            'whole-verse citation is how the previous list went wrong.',
      );
    }
  });

  test('verseFor and verseForKey are total and stable', () {
    for (final i in [-5, -1, 0, 1, 7, 364, 100000]) {
      expect(() => verseFor(i), returnsNormally);
    }
    expect(verseForKey('matthew5'), verseForKey('matthew5'));
    expect(verseForKey('john13'), isNotNull);
  });
}

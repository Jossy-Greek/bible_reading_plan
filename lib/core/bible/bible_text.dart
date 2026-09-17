import 'dart:convert';

import 'package:flutter/services.dart';

import 'chapter_reference.dart';

/// One chapter, ready to render.
class ChapterText {
  const ChapterText({required this.reference, required this.verses});

  final ChapterReference reference;

  /// Verse 1 is `verses[0]`. The index *is* the verse number, which is why
  /// the asset stores no verse numbers.
  final List<String> verses;

  int get verseCount => verses.length;
}

/// The bundled King James text.
///
/// Public domain. Structure verified against [kVerseCounts] at build time:
/// 66 books, 1,189 chapters, 31,102 verses, every chapter's verse count equal
/// to the table the reading times are computed from — see
/// `test/core/bible_text_test.dart`.
///
/// Books load lazily and stay cached. A reading day touches one or two books,
/// so the app never holds more than a few hundred KB of text.
class BibleText {
  BibleText({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final Map<String, List<List<String>>> _books = {};
  final Map<String, Future<List<List<String>>>> _inFlight = {};

  static String assetPath(String bookId) => 'assets/bible/kjv/$bookId.json';

  /// Chapters of [bookId], outer index 0 = chapter 1.
  Future<List<List<String>>> _book(String bookId) {
    final cached = _books[bookId];
    if (cached != null) return Future.value(cached);
    // Two chapters of the same book requested at once must not decode twice.
    return _inFlight[bookId] ??= _load(bookId);
  }

  Future<List<List<String>>> _load(String bookId) async {
    try {
      final raw = await _bundle.loadString(assetPath(bookId));
      final decoded = (jsonDecode(raw) as List)
          .map((c) => (c as List).cast<String>())
          .toList(growable: false);
      _books[bookId] = decoded;
      return decoded;
    } finally {
      _inFlight.remove(bookId);
    }
  }

  Future<ChapterText> chapter(ChapterReference ref) async {
    final book = await _book(ref.bookId);
    return ChapterText(reference: ref, verses: book[ref.chapter - 1]);
  }

  /// Every chapter of [assignments], in reading order.
  Future<List<ChapterText>> forAssignments(
    List<ReadingAssignment> assignments,
  ) async {
    final refs = [for (final a in assignments) ...a.chapters];
    return [for (final r in refs) await chapter(r)];
  }

  /// One verse, for the quiet accents on Home and the reading screen.
  Future<String> verse(String bookId, int chapter, int verse) async {
    final book = await _book(bookId);
    return book[chapter - 1][verse - 1];
  }

  /// True once [bookId] is in memory — lets the UI skip its loading state.
  bool isLoaded(String bookId) => _books.containsKey(bookId);
}

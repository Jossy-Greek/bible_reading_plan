import '../../core/bible/chapter_reference.dart';

/// How fast the person reads. A setting, not a measurement.
enum ReadingPace {
  relaxed(160),
  normal(220),
  quick(280);

  const ReadingPace(this.wordsPerMinute);
  final int wordsPerMinute;
}

/// How large the scripture itself is drawn. Independent of the system font
/// scale, which still applies on top: someone who has enlarged everything
/// may still want the text larger again, and only here.
enum ScriptureSize {
  small(0.92, 'Small'),
  medium(1.0, 'Medium'),
  large(1.18, 'Large'),
  xlarge(1.4, 'Larger');

  const ScriptureSize(this.factor, this.title);
  final double factor;
  final String title;
}

/// Turns a reading assignment into a required duration.
///
/// Verse-based (product decision 2026-09-14): every chapter's verse count is
/// static data, so "Genesis 1–5" is 138 verses, not "5 chapters". The KJV
/// averages ~25 words per verse (783k words / 31,102 verses), which at a
/// normal 220 wpm is ~6.8 s per verse — Genesis 1–5 ≈ 16 minutes.
///
/// This is the only place minutes are computed. When Bible text ships, swap
/// the verse×words model for real word counts here and nothing else moves.
class ReadingTimeService {
  const ReadingTimeService({
    this.wordsPerVerse = 25.0,
    this.minimum = const Duration(minutes: 1),
    this.maximum = const Duration(hours: 3),
  });

  final double wordsPerVerse;

  /// Floors: a one-verse chapter is still a sit-down. Ceiling: a "whole Bible
  /// in a month" pace shows its real size on the plan screen, but a session
  /// longer than this is a mistake, not a discipline.
  final Duration minimum;
  final Duration maximum;

  Duration estimate(Iterable<ChapterReference> chapters, ReadingPace pace) {
    final verses = chapters.fold<int>(0, (s, c) => s + c.verses);
    return estimateForVerses(verses, pace);
  }

  Duration estimateForVerses(int verses, ReadingPace pace) {
    if (verses <= 0) return Duration.zero;
    final minutes = verses * wordsPerVerse / pace.wordsPerMinute;
    final seconds = (minutes * 60).round();
    final d = Duration(seconds: seconds);
    if (d < minimum) return minimum;
    if (d > maximum) return maximum;
    return d;
  }
}

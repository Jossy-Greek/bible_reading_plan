import 'package:bible_reading_plan/core/bible/chapter_reference.dart';
import 'package:bible_reading_plan/domain/reading_time/reading_time_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const svc = ReadingTimeService();
  final gen1to5 = kAllChapters.sublist(0, 5);

  test('Genesis 1–5 is 138 verses ≈ 16 min at normal pace', () {
    expect(gen1to5.fold<int>(0, (s, c) => s + c.verses), 138);
    final d = svc.estimate(gen1to5, ReadingPace.normal);
    expect(d.inMinutes, 15); // 138*25/220 = 15.68 min → 15:41
    expect(d.inSeconds, 941);
  });

  test('pace changes the requirement', () {
    final relaxed = svc.estimate(gen1to5, ReadingPace.relaxed);
    final quick = svc.estimate(gen1to5, ReadingPace.quick);
    expect(relaxed > quick, isTrue);
    expect(quick.inMinutes, 12); // 138*25/280 = 12.3
  });

  test('a short chapter is a short requirement, floored at one minute', () {
    expect(
      svc.estimateForVerses(2, ReadingPace.quick),
      const Duration(minutes: 1),
    );
    expect(svc.estimateForVerses(17, ReadingPace.normal).inSeconds, 116);
  });

  test('zero verses is zero', () {
    expect(svc.estimate(const [], ReadingPace.normal), Duration.zero);
  });
}

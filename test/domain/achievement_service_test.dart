import 'package:bible_reading_plan/core/time/local_date.dart';
import 'package:bible_reading_plan/domain/achievements/achievement_service.dart';
import 'package:bible_reading_plan/domain/achievements/badges.dart';
import 'package:bible_reading_plan/domain/progress/bible_progress.dart';
import 'package:bible_reading_plan/domain/streak/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const svc = AchievementService();
  const start = LocalDate(2026, 9, 1);

  BibleProgress progress(Map<String, int> byBook) => BibleProgress.compute(
    completedByBook: byBook,
    daysCompleted: 1,
    totalDays: 365,
    planStart: start,
    today: start,
  );

  Set<String> ids(List<BadgeDefinition> l) => l.map((b) => b.id).toSet();

  test('first reading unlocks Getting Started and nothing else', () {
    final got = svc.evaluate(
      progress: progress({'genesis': 4}),
      streak: const StreakState(current: 1, longest: 1),
      unlocked: {},
    );
    expect(ids(got), {'first_reading'});
  });

  test('already-unlocked badges are not returned again', () {
    final got = svc.evaluate(
      progress: progress({'genesis': 4}),
      streak: const StreakState(current: 1, longest: 1),
      unlocked: {'first_reading'},
    );
    expect(got, isEmpty);
  });

  test('streak badges key off the longest run', () {
    final got = svc.evaluate(
      progress: progress({'genesis': 30}),
      streak: const StreakState(current: 1, longest: 7),
      unlocked: {'first_reading'},
    );
    expect(ids(got), {'streak_3', 'streak_7'});
  });

  test('chapter thresholds', () {
    final got = svc.evaluate(
      progress: progress({'genesis': 50, 'exodus': 40, 'leviticus': 10}),
      streak: const StreakState(),
      unlocked: {'first_reading'},
    );
    expect(ids(got), {'chapters_50', 'chapters_100'});
  });

  test('halfway is 595 chapters, not 594', () {
    expect(
      ids(
        svc.evaluate(
          progress: progress({
            'psalms': 150,
            'genesis': 50,
            'isaiah': 66,
            'jeremiah': 52,
            'ezekiel': 48,
            'numbers': 36,
            'exodus': 40,
            'deuteronomy': 34,
            'job': 42,
            '1_samuel': 31,
            '2_kings': 25,
            'matthew': 20,
          }), // 594
          streak: const StreakState(),
          unlocked: kBadges.map((b) => b.id).toSet()..remove('halfway'),
        ),
      ),
      isEmpty,
    );
    expect(
      ids(
        svc.evaluate(
          progress: progress({
            'psalms': 150,
            'genesis': 50,
            'isaiah': 66,
            'jeremiah': 52,
            'ezekiel': 48,
            'numbers': 36,
            'exodus': 40,
            'deuteronomy': 34,
            'job': 42,
            '1_samuel': 31,
            '2_kings': 25,
            'matthew': 21,
          }), // 595
          streak: const StreakState(),
          unlocked: kBadges.map((b) => b.id).toSet()..remove('halfway'),
        ),
      ),
      {'halfway'},
    );
  });

  test('testaments and the whole Bible', () {
    final nt = {
      for (final b in kBadges)
        b.id: 0, // placeholder to keep map literal simple
    };
    nt.clear();
    final ntBooks = <String, int>{
      'matthew': 28,
      'mark': 16,
      'luke': 24,
      'john': 21,
      'acts': 28,
      'romans': 16,
      '1_corinthians': 16,
      '2_corinthians': 13,
      'galatians': 6,
      'ephesians': 6,
      'philippians': 4,
      'colossians': 4,
      '1_thessalonians': 5,
      '2_thessalonians': 3,
      '1_timothy': 6,
      '2_timothy': 4,
      'titus': 3,
      'philemon': 1,
      'hebrews': 13,
      'james': 5,
      '1_peter': 5,
      '2_peter': 3,
      '1_john': 5,
      '2_john': 1,
      '3_john': 1,
      'jude': 1,
      'revelation': 22,
    };
    final got = svc.evaluate(
      progress: progress(ntBooks),
      streak: const StreakState(),
      unlocked: {
        'first_reading',
        'chapters_50',
        'chapters_100',
        'chapters_250',
      },
    );
    expect(ids(got), {'new_testament'});
    expect(progress(ntBooks).newTestamentCompleted, 260);
  });

  test('every badge id is unique and resolvable', () {
    expect(kBadges.map((b) => b.id).toSet().length, kBadges.length);
    for (final b in kBadges) {
      expect(badgeById(b.id), same(b));
    }
  });
}

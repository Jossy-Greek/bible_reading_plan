import 'package:bible_reading_plan/core/time/local_date.dart';
import 'package:bible_reading_plan/domain/achievements/achievement_service.dart';
import 'package:bible_reading_plan/domain/achievements/badges.dart';
import 'package:bible_reading_plan/domain/plan/plan_definition.dart';
import 'package:bible_reading_plan/domain/plan/reading_day.dart';
import 'package:bible_reading_plan/domain/plan/reading_plan_generator.dart';
import 'package:bible_reading_plan/domain/progress/bible_progress.dart';
import 'package:bible_reading_plan/domain/reading_time/reading_time_service.dart';
import 'package:bible_reading_plan/domain/streak/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const svc = AchievementService();
  const start = LocalDate(2026, 9, 1);
  final plan = PlanDefinition(
    id: 1,
    scope: const WholeBible(),
    targetDays: 365,
    startDate: start,
  );
  final schedule = const ReadingPlanGenerator(
    ReadingTimeService(),
  ).generate(plan, ReadingPace.normal);

  const ntBooks = <String, int>{
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

  AchievementFacts facts({
    Map<String, int> byBook = const {'genesis': 4},
    StreakState before = const StreakState(),
    StreakState after = const StreakState(current: 1, longest: 1),
    int totalDays = 1,
    Set<int> planDone = const {0},
    ReadingDay? day,
    LocalDate? today,
    DateTime? at,
  }) => AchievementFacts(
    progress: BibleProgress.compute(
      completedByBook: byBook,
      daysCompleted: planDone.length,
      totalDays: schedule.length,
      planStart: start,
      today: today ?? start,
    ),
    streakBefore: before,
    streakAfter: after,
    totalDaysCompleted: totalDays,
    planDaysCompleted: planDone.length,
    planSchedule: schedule,
    completedDayIndexes: planDone,
    completedDay: day ?? schedule.first,
    today: today ?? start,
    completedAtLocal: at ?? DateTime(2026, 9, 1, 9, 0),
  );

  Set<String> ids(List<BadgeDefinition> l) => l.map((b) => b.id).toSet();
  final allIds = kBadges.map((b) => b.id).toSet();
  Set<String> allBut(Set<String> keep) => allIds.difference(keep);

  test('first reading at 9 AM unlocks only Getting Started', () {
    expect(ids(svc.evaluate(facts: facts(), unlocked: {})), {'first_reading'});
  });

  test('already-unlocked badges are never returned again', () {
    expect(svc.evaluate(facts: facts(), unlocked: allIds), isEmpty);
  });

  test('streak badges key off the longest run', () {
    final got = svc.evaluate(
      facts: facts(after: const StreakState(current: 1, longest: 7)),
      unlocked: allBut({'streak_3', 'streak_7', 'streak_14'}),
    );
    expect(ids(got), {'streak_3', 'streak_7'});
  });

  test('consistency counts days across plans, not consecutively', () {
    final got = svc.evaluate(
      facts: facts(
        totalDays: 100,
        after: const StreakState(current: 1, longest: 1),
      ),
      unlocked: allBut({'days_30', 'days_100', 'days_365'}),
    );
    expect(ids(got), {'days_30', 'days_100'});
  });

  test(
    'early bird and night owl, with the 04:00 rollover counted as night',
    () {
      Set<String> at(DateTime t) => ids(
        svc.evaluate(
          facts: facts(at: t),
          unlocked: allBut({'early_bird', 'night_owl'}),
        ),
      );
      expect(at(DateTime(2026, 9, 1, 6, 59)), {'early_bird'});
      expect(at(DateTime(2026, 9, 1, 7, 0)), isEmpty);
      expect(at(DateTime(2026, 9, 1, 22, 0)), {'night_owl'});
      expect(at(DateTime(2026, 9, 2, 1, 30)), {'night_owl'});
      expect(at(DateTime(2026, 9, 1, 12, 0)), isEmpty);
    },
  );

  test('catching up is completing a day whose date has passed', () {
    final today = start.plusDays(3);
    expect(
      ids(
        svc.evaluate(
          facts: facts(day: schedule[1], today: today),
          unlocked: allBut({'caught_up'}),
        ),
      ),
      {'caught_up'},
    );
    expect(
      svc.evaluate(
        facts: facts(day: schedule[3], today: today),
        unlocked: allBut({'caught_up'}),
      ),
      isEmpty,
    );
  });

  test('back on track needs a real gap and a prior habit', () {
    final today = start.plusDays(10);
    Set<String> withBefore(StreakState b) => ids(
      svc.evaluate(
        facts: facts(before: b, today: today, day: schedule[10]),
        unlocked: allBut({'came_back'}),
      ),
    );
    // Last read on day 7, today is day 10 → days 8 and 9 missed.
    expect(
      withBefore(
        StreakState(current: 5, longest: 5, lastCompletedOn: start.plusDays(7)),
      ),
      {'came_back'},
    );
    // Only one missed day: not a comeback, just a streak reset.
    expect(
      withBefore(
        StreakState(current: 5, longest: 5, lastCompletedOn: start.plusDays(8)),
      ),
      isEmpty,
    );
    // Gap but no habit ever built.
    expect(
      withBefore(
        StreakState(current: 1, longest: 1, lastCompletedOn: start.plusDays(7)),
      ),
      isEmpty,
    );
  });

  test('perfect month needs every scheduled day of a month with ≥10 days', () {
    // September 2026 from the 1st: 30 scheduled days.
    final sept = {for (var i = 0; i < 30; i++) i};
    expect(
      ids(
        svc.evaluate(
          facts: facts(
            planDone: sept,
            day: schedule[29],
            today: start.plusDays(29),
          ),
          unlocked: allBut({'perfect_month'}),
        ),
      ),
      {'perfect_month'},
    );
    final missingOne = Set<int>.from(sept)..remove(12);
    expect(
      svc.evaluate(
        facts: facts(
          planDone: missingOne,
          day: schedule[29],
          today: start.plusDays(29),
        ),
        unlocked: allBut({'perfect_month'}),
      ),
      isEmpty,
    );
  });

  test('books, sections, Psalms', () {
    final got = svc.evaluate(
      facts: facts(
        byBook: {
          'genesis': 50,
          'exodus': 40,
          'leviticus': 27,
          'numbers': 36,
          'deuteronomy': 34,
          'psalms': 150,
          'ruth': 4,
        },
      ),
      unlocked: allBut({
        'first_book',
        'books_10',
        'section_law',
        'psalms',
        'section_wisdom',
      }),
    );
    expect(ids(got), {'first_book', 'section_law', 'psalms'});
  });

  test('plan complete, testaments, whole Bible', () {
    final all = {for (var i = 0; i < schedule.length; i++) i};
    final got = svc.evaluate(
      facts: facts(
        byBook: ntBooks,
        planDone: all,
        day: schedule.last,
        today: start.plusDays(364),
      ),
      unlocked: allBut({
        'plan_complete',
        'new_testament',
        'old_testament',
        'bible_completed',
        'section_gospels',
        'section_paul',
      }),
    );
    expect(ids(got), {
      'plan_complete',
      'new_testament',
      'section_gospels',
      'section_paul',
    });
  });

  test(
    'every badge id is unique, resolvable, and every section book exists',
    () {
      expect(allIds.length, kBadges.length);
      for (final b in kBadges) {
        expect(badgeById(b.id), same(b));
      }
      for (final s in BibleSection.values) {
        for (final id in s.bookIds) {
          expect(
            kBadges.isNotEmpty && id.isNotEmpty,
            isTrue,
            reason: '${s.name}:$id',
          );
        }
      }
    },
  );
}

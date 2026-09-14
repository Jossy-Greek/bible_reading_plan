import 'package:bible_reading_plan/core/time/local_date.dart';
import 'package:bible_reading_plan/data/db/database.dart';
import 'package:bible_reading_plan/data/repositories/plan_repository.dart';
import 'package:bible_reading_plan/data/repositories/progress_repository.dart';
import 'package:bible_reading_plan/domain/plan/plan_definition.dart';
import 'package:bible_reading_plan/domain/plan/reading_plan_generator.dart';
import 'package:bible_reading_plan/domain/reading_time/reading_time_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProgressRepository repo;
  const start = LocalDate(2026, 9, 14);
  final now = DateTime.utc(2026, 9, 14, 8);
  const gen = ReadingPlanGenerator(ReadingTimeService());

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    repo = ProgressRepository(db);
  });
  tearDown(() => db.close());

  test(
    'completing a day records chapters, the day, the streak and badges atomically',
    () async {
      final plan = await PlanRepository(db).startPlan(
        scope: const WholeBible(),
        targetDays: 365,
        startDate: start,
        now: now,
      );
      final days = gen.generate(plan, ReadingPace.normal);
      final day = days.first; // Genesis 1–4

      final session = await repo.startSession(
        plan: plan,
        day: day,
        nowUtc: now,
      );
      expect(await repo.watchOpenSession().first, isNotNull);

      final result = await repo.completeDay(
        plan: plan,
        day: day,
        sessionId: session.id,
        nowUtc: now.add(const Duration(minutes: 20)),
        nowLocal: DateTime(2026, 9, 14, 11, 20),
        today: start,
        schedule: days,
      );
      expect(result.streak.current, 1);
      expect(result.newBadges.map((b) => b.id), ['first_reading']);
      expect((await repo.watchAchievements().first).keys, ['first_reading']);
      expect(await repo.watchOpenSession().first, isNull);
      expect(await repo.watchDayCompleted(plan.id, 0).first, isTrue);
      expect(await repo.watchCompletedChapterCount().first, 4);
      expect((await repo.watchCompletedChaptersByBook().first)['genesis'], 4);

      // Doing it again is a no-op: no double count, no second badge.
      final again = await repo.completeDay(
        plan: plan,
        day: day,
        sessionId: session.id,
        nowUtc: now.add(const Duration(minutes: 30)),
        nowLocal: DateTime(2026, 9, 14, 11, 30),
        today: start,
        schedule: days,
      );
      expect(await repo.watchCompletedChapterCount().first, 4);
      expect((await repo.watchStreak().first).current, 1);
      expect(again.newBadges, isEmpty);
    },
  );

  test('a new plan keeps chapters already read', () async {
    final plans = PlanRepository(db);
    final p1 = await plans.startPlan(
      scope: const BookScope('jude'),
      targetDays: 7,
      startDate: start,
      now: now,
    );
    final day = gen.generate(p1, ReadingPace.normal).single;
    final s = await repo.startSession(plan: p1, day: day, nowUtc: now);
    await repo.completeDay(
      plan: p1,
      day: day,
      sessionId: s.id,
      nowUtc: now,
      nowLocal: DateTime(2026, 9, 14, 11),
      today: start,
      schedule: [day],
    );

    final p2 = await plans.startPlan(
      scope: const WholeBible(),
      targetDays: 365,
      startDate: start,
      now: now,
    );
    expect((await plans.activePlan())!.id, p2.id);
    expect(await repo.watchCompletedChapterCount().first, 1);
  });

  test('badges fire through the real completion path', () async {
    final plan = await PlanRepository(db).startPlan(
      scope: const WholeBible(),
      targetDays: 365,
      startDate: const LocalDate(2026, 9, 1),
      now: DateTime.utc(2026, 9, 1, 6),
    );
    final days = gen.generate(plan, ReadingPace.normal);

    Future<List<String>> complete(int dayIndex, DateTime local) async {
      final s = await repo.startSession(
        plan: plan,
        day: days[dayIndex],
        nowUtc: local.toUtc(),
      );
      final r = await repo.completeDay(
        plan: plan,
        day: days[dayIndex],
        sessionId: s.id,
        nowUtc: local.toUtc(),
        nowLocal: local,
        today: LocalDate.fromDateTime(local),
        schedule: days,
      );
      return r.newBadges.map((b) => b.id).toList();
    }

    // Day 1 at 05:30 → first reading + early bird.
    expect(
      await complete(0, DateTime(2026, 9, 1, 5, 30)),
      containsAll(['first_reading', 'early_bird']),
    );
    // Days 2 and 3 → a 3-day streak.
    await complete(1, DateTime(2026, 9, 2, 9));
    expect(await complete(2, DateTime(2026, 9, 3, 9)), contains('streak_3'));

    // Skip the 4th and 5th. Read the 6th on the 6th → back on track.
    expect(await complete(5, DateTime(2026, 9, 6, 9)), contains('came_back'));
    // Then go back for the missed 4th → catching up. Not a comeback again.
    final catchUp = await complete(3, DateTime(2026, 9, 6, 23, 15));
    expect(catchUp, contains('caught_up'));
    expect(catchUp, contains('night_owl'));
    expect(catchUp, isNot(contains('came_back')));

    final earned = (await repo.watchAchievements().first).keys.toSet();
    expect(earned, {
      'first_reading',
      'early_bird',
      'streak_3',
      'came_back',
      'caught_up',
      'night_owl',
    });
    // Streak: 6th counted as a fresh day 1; the catch-up did not move it.
    expect((await repo.watchStreak().first).current, 1);
    expect((await repo.watchStreak().first).longest, 3);
  });
}

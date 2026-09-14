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
        today: start,
        totalDays: days.length,
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
        today: start,
        totalDays: days.length,
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
      today: start,
      totalDays: 1,
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
}

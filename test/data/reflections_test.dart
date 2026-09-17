import 'package:bible_reading_plan/core/time/local_date.dart';
import 'package:bible_reading_plan/data/db/database.dart';
import 'package:bible_reading_plan/data/repositories/plan_repository.dart';
import 'package:bible_reading_plan/data/repositories/progress_repository.dart';
import 'package:bible_reading_plan/domain/passages/passage.dart';
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

  Future<(PlanDefinition, ReadingSession)> startFirstDay() async {
    final plan = await PlanRepository(db).startPlan(
      scope: const WholeBible(),
      targetDays: 365,
      startDate: start,
      now: now,
    );
    final day = gen.generate(plan, ReadingPace.normal).first;
    final session = await repo.startSession(plan: plan, day: day, nowUtc: now);
    return (plan, session);
  }

  test('a sitting stamps what was read, so the journal cannot lie', () async {
    final (_, session) = await startFirstDay();
    // Genesis 1–4 on a whole-Bible year plan.
    expect(session.reference, isNotNull);
    expect(session.reference, startsWith('Genesis 1'));
  });

  test('a note is trimmed, and emptying it clears the entry', () async {
    final (plan, session) = await startFirstDay();
    final days = gen.generate(plan, ReadingPace.normal);
    await repo.completeDay(
      plan: plan,
      day: days.first,
      sessionId: session.id,
      nowUtc: now,
      nowLocal: now,
      today: start,
      schedule: days,
    );

    await repo.setNote(session.id, '   He is faithful.  ');
    var all = await repo.watchReflections().first;
    expect(all, hasLength(1));
    expect(all.single.note, 'He is faithful.');
    expect(all.single.reference, startsWith('Genesis 1'));

    await repo.setNote(session.id, '    ');
    all = await repo.watchReflections().first;
    expect(all, isEmpty, reason: 'a blank note is not a reflection');
  });

  test('only completed sittings appear in the journal', () async {
    final (_, session) = await startFirstDay();
    await repo.setNote(session.id, 'written before finishing');
    expect(
      await repo.watchReflections().first,
      isEmpty,
      reason: 'the sitting is still open',
    );
  });

  test('a one-time reading carries its own reflection', () async {
    const passage = Passage(
      id: 'sermon_on_the_mount',
      title: 'Sermon on the Mount',
      bookId: 'matthew',
      fromChapter: 5,
      toChapter: 7,
    );
    final session = await repo.startPassageSession(
      passage: passage,
      planId: null,
      required: const Duration(minutes: 10),
      nowUtc: now,
    );
    expect(session.reference, 'Matthew 5–7');

    await repo.completePassage(
      sessionId: session.id,
      passage: passage,
      plan: null,
      schedule: const [],
      nowUtc: now,
      nowLocal: now,
      today: start,
    );
    await repo.setNote(session.id, 'Blessed are the poor in spirit.');

    final all = await repo.watchReflections().first;
    expect(all.single.reference, 'Matthew 5–7');
    expect(all.single.note, 'Blessed are the poor in spirit.');
  });

  test('reflections come back newest first', () async {
    Future<void> writeAt(DateTime t, String note) async {
      const passage = Passage(
        title: 'Psalm',
        bookId: 'psalms',
        fromChapter: 23,
        toChapter: 23,
      );
      final s = await repo.startPassageSession(
        passage: passage,
        planId: null,
        required: Duration.zero,
        nowUtc: t,
      );
      await repo.completePassage(
        sessionId: s.id,
        passage: passage,
        plan: null,
        schedule: const [],
        nowUtc: t,
        nowLocal: t,
        today: LocalDate.fromDateTime(t),
      );
      await repo.setNote(s.id, note);
    }

    await writeAt(DateTime.utc(2026, 9, 14), 'first');
    await writeAt(DateTime.utc(2026, 9, 16), 'third');
    await writeAt(DateTime.utc(2026, 9, 15), 'second');

    final all = await repo.watchReflections().first;
    expect(all.map((s) => s.note), ['third', 'second', 'first']);
  });
}

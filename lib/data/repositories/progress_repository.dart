import 'package:drift/drift.dart';

import '../../core/time/local_date.dart';
import '../../domain/achievements/achievement_service.dart';
import '../../domain/achievements/badges.dart';
import '../../domain/plan/plan_definition.dart';
import '../../domain/progress/bible_progress.dart';
import '../../domain/plan/reading_day.dart';
import '../../domain/streak/streak_service.dart';
import '../db/database.dart';

/// Sessions, completions and the streak: everything that records what the
/// person actually did. One class so the completion transaction has one owner.
class ProgressRepository {
  ProgressRepository(
    this._db, [
    this._streak = const StreakService(),
    this._achievements = const AchievementService(),
  ]);

  final AppDatabase _db;
  final StreakService _streak;
  final AchievementService _achievements;

  // ── sessions ────────────────────────────────────────────────────────────

  /// The one session that is neither completed nor invalidated, if any.
  Stream<ReadingSession?> watchOpenSession() =>
      (_db.select(_db.readingSessions)
            ..where(
              (s) => s.completedAt.isNull() & s.invalidatedReason.isNull(),
            )
            ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
            ..limit(1))
          .watchSingleOrNull();

  Future<ReadingSession> startSession({
    required PlanDefinition plan,
    required ReadingDay day,
    required DateTime nowUtc,
  }) async {
    final id = await _db
        .into(_db.readingSessions)
        .insert(
          ReadingSessionsCompanion.insert(
            planId: plan.id,
            dayIndex: day.dayIndex,
            startedAt: nowUtc,
            requiredMs: day.requiredDuration.inMilliseconds,
          ),
        );
    return (_db.select(
      _db.readingSessions,
    )..where((s) => s.id.equals(id))).getSingle();
  }

  Future<void> invalidateSession(int id, String reason) =>
      (_db.update(_db.readingSessions)..where((s) => s.id.equals(id))).write(
        ReadingSessionsCompanion(invalidatedReason: Value(reason)),
      );

  Future<void> addForegroundMs(int id, int ms) async {
    final row = await (_db.select(
      _db.readingSessions,
    )..where((s) => s.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (_db.update(
      _db.readingSessions,
    )..where((s) => s.id.equals(id))).write(
      ReadingSessionsCompanion(foregroundMs: Value(row.foregroundMs + ms)),
    );
  }

  // ── completion ─────────────────────────────────────────────────────────

  Stream<bool> watchDayCompleted(int planId, int dayIndex) =>
      (_db.select(_db.dayCompletions)..where(
            (d) => d.planId.equals(planId) & d.dayIndex.equals(dayIndex),
          ))
          .watchSingleOrNull()
          .map((r) => r != null);

  Future<bool> isDayCompleted(int planId, int dayIndex) async =>
      (await (_db.select(_db.dayCompletions)..where(
            (d) => d.planId.equals(planId) & d.dayIndex.equals(dayIndex),
          ))
          .getSingleOrNull()) !=
      null;

  /// Closes every open session with [reason]. Used when the plan changes:
  /// a session's day index means nothing under a different schedule.
  Future<void> invalidateOpenSessions(String reason) =>
      (_db.update(_db.readingSessions)..where(
            (s) => s.completedAt.isNull() & s.invalidatedReason.isNull(),
          ))
          .write(ReadingSessionsCompanion(invalidatedReason: Value(reason)));

  /// Wipes everything the person did, keeps who they are and what plan they
  /// chose. Chapters, days, sessions, streak, badges — gone together.
  Future<void> resetProgress() => _db.transaction(() async {
    await _db.delete(_db.chapterCompletions).go();
    await _db.delete(_db.dayCompletions).go();
    await _db.delete(_db.readingSessions).go();
    await _db.delete(_db.streaks).go();
    await _db.delete(_db.achievements).go();
  });

  Stream<Set<int>> watchCompletedDayIndexes(int planId) =>
      (_db.select(_db.dayCompletions)..where((d) => d.planId.equals(planId)))
          .watch()
          .map((rows) => rows.map((r) => r.dayIndex).toSet());

  /// book_id → chapters completed in it. Plan-independent.
  Stream<Map<String, int>> watchCompletedChaptersByBook() => _db
      .customSelect(
        'SELECT book_id, COUNT(*) AS n FROM chapter_completions GROUP BY book_id',
        readsFrom: {_db.chapterCompletions},
      )
      .watch()
      .map(
        (rows) => {
          for (final r in rows) r.read<String>('book_id'): r.read<int>('n'),
        },
      );

  Stream<int> watchCompletedChapterCount() => _db
      .customSelect(
        'SELECT COUNT(*) AS n FROM chapter_completions',
        readsFrom: {_db.chapterCompletions},
      )
      .watchSingle()
      .map((r) => r.read<int>('n'));

  /// Marks the day done. Atomic: session closed, chapters recorded, day
  /// recorded, streak advanced, badges unlocked — or none of it. Repeating it
  /// is harmless: chapters and the day use INSERT OR IGNORE, the streak
  /// ignores a second completion on the same date, and an unlocked badge is
  /// never re-awarded.
  Future<CompletionResult> completeDay({
    required PlanDefinition plan,
    required ReadingDay day,
    required int sessionId,
    required DateTime nowUtc,
    required DateTime nowLocal,
    required LocalDate today,
    required List<ReadingDay> schedule,
  }) {
    return _db.transaction(() async {
      await (_db.update(_db.readingSessions)
            ..where((s) => s.id.equals(sessionId)))
          .write(ReadingSessionsCompanion(completedAt: Value(nowUtc)));

      await _db.batch((b) {
        b.insertAll(_db.chapterCompletions, [
          for (final c in day.chapters)
            ChapterCompletionsCompanion.insert(
              bookId: c.bookId,
              chapter: c.chapter,
              completedAt: nowUtc,
              planId: Value(plan.id),
            ),
        ], mode: InsertMode.insertOrIgnore);
      });

      await _db
          .into(_db.dayCompletions)
          .insert(
            DayCompletionsCompanion.insert(
              planId: plan.id,
              dayIndex: day.dayIndex,
              completedOnEpochDay: today.epochDay,
              completedAt: nowUtc,
            ),
            mode: InsertMode.insertOrIgnore,
          );

      final before = await _readStreak();
      final after = _streak.record(before, today);
      await _db
          .into(_db.streaks)
          .insertOnConflictUpdate(
            StreaksCompanion(
              id: const Value(1),
              current: Value(after.current),
              longest: Value(after.longest),
              lastCompletedOnEpochDay: Value(after.lastCompletedOn?.epochDay),
            ),
          );

      // Badges, from the facts as they now stand inside this transaction.
      final planDone = await _completedDayIndexesOnce(plan.id);
      final progress = BibleProgress.compute(
        completedByBook: await _completedByBookOnce(),
        daysCompleted: planDone.length,
        totalDays: schedule.length,
        planStart: plan.startDate,
        today: today,
      );
      final unlocked = await _unlockedIdsOnce();
      final newBadges = _achievements.evaluate(
        facts: AchievementFacts(
          progress: progress,
          streakBefore: before,
          streakAfter: after,
          totalDaysCompleted: await _totalDayCountOnce(),
          planDaysCompleted: planDone.length,
          planSchedule: schedule,
          completedDayIndexes: planDone,
          completedDay: day,
          today: today,
          completedAtLocal: nowLocal,
        ),
        unlocked: unlocked,
      );
      if (newBadges.isNotEmpty) {
        await _db.batch((b) {
          b.insertAll(_db.achievements, [
            for (final badge in newBadges)
              AchievementsCompanion.insert(
                badgeId: badge.id,
                unlockedAt: nowUtc,
              ),
          ], mode: InsertMode.insertOrIgnore);
        });
      }
      return CompletionResult(streak: after, newBadges: newBadges);
    });
  }

  // ── achievements ───────────────────────────────────────────────────────

  Stream<Map<String, DateTime>> watchAchievements() => _db
      .select(_db.achievements)
      .watch()
      .map((rows) => {for (final r in rows) r.badgeId: r.unlockedAt});

  Future<Set<String>> _unlockedIdsOnce() async =>
      (await _db.select(_db.achievements).get()).map((r) => r.badgeId).toSet();

  Future<Map<String, int>> _completedByBookOnce() async {
    final rows = await _db
        .customSelect(
          'SELECT book_id, COUNT(*) AS n FROM chapter_completions GROUP BY book_id',
        )
        .get();
    return {for (final r in rows) r.read<String>('book_id'): r.read<int>('n')};
  }

  Future<Set<int>> _completedDayIndexesOnce(int planId) async {
    final rows = await (_db.select(
      _db.dayCompletions,
    )..where((d) => d.planId.equals(planId))).get();
    return rows.map((r) => r.dayIndex).toSet();
  }

  Future<int> _totalDayCountOnce() async =>
      (await _db.select(_db.dayCompletions).get()).length;

  // ── streak ─────────────────────────────────────────────────────────────

  Future<StreakState> _readStreak() async {
    final row = await (_db.select(
      _db.streaks,
    )..where((s) => s.id.equals(1))).getSingleOrNull();
    return _toState(row);
  }

  Stream<StreakState> watchStreak() => (_db.select(
    _db.streaks,
  )..where((s) => s.id.equals(1))).watchSingleOrNull().map(_toState);

  StreakState _toState(Streak? row) => row == null
      ? const StreakState()
      : StreakState(
          current: row.current,
          longest: row.longest,
          lastCompletedOn: row.lastCompletedOnEpochDay == null
              ? null
              : LocalDate.fromEpochDay(row.lastCompletedOnEpochDay!),
        );
}

/// What a completion produced, for the celebration screen.
class CompletionResult {
  const CompletionResult({required this.streak, required this.newBadges});
  final StreakState streak;
  final List<BadgeDefinition> newBadges;
}

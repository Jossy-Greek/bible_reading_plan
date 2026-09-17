import 'package:drift/drift.dart';

import '../../core/time/local_date.dart';
import '../../domain/achievements/achievement_service.dart';
import '../../domain/achievements/badges.dart';
import '../../domain/passages/passage.dart';
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
            reference: Value(day.label),
            startedAt: nowUtc,
            requiredMs: day.requiredDuration.inMilliseconds,
          ),
        );
    return (_db.select(
      _db.readingSessions,
    )..where((s) => s.id.equals(id))).getSingle();
  }

  /// A one-time reading. `dayIndex` is -1; the passage rides on the row.
  Future<ReadingSession> startPassageSession({
    required Passage passage,
    required int? planId,
    required Duration required,
    required DateTime nowUtc,
  }) async {
    final id = await _db
        .into(_db.readingSessions)
        .insert(
          ReadingSessionsCompanion.insert(
            planId: planId ?? 0,
            dayIndex: -1,
            startedAt: nowUtc,
            requiredMs: required.inMilliseconds,
            reference: Value(passage.reference),
            passageTitle: Value(passage.title),
            passageBookId: Value(passage.bookId),
            passageFrom: Value(passage.fromChapter),
            passageTo: Value(passage.toChapter),
          ),
        );
    return (_db.select(
      _db.readingSessions,
    )..where((s) => s.id.equals(id))).getSingle();
  }

  /// Completed one-time readings, newest first.
  Stream<List<Passage>> watchCompletedPassages() =>
      (_db.select(_db.readingSessions)
            ..where(
              (s) => s.passageBookId.isNotNull() & s.completedAt.isNotNull(),
            )
            ..orderBy([(s) => OrderingTerm.desc(s.completedAt)]))
          .watch()
          .map((rows) => [for (final r in rows) passageOf(r)!]);

  /// The passage carried by a session row, or null for a plan day.
  static Passage? passageOf(ReadingSession r) => r.passageBookId == null
      ? null
      : Passage(
          title: r.passageTitle ?? '',
          bookId: r.passageBookId!,
          fromChapter: r.passageFrom!,
          toChapter: r.passageTo!,
        );

  /// Marks a one-time reading done. Chapters are recorded (plan-independent,
  /// so Progress and every chapter badge count them); no plan day completes
  /// and the streak does not move — the streak is the *scheduled* habit.
  Future<CompletionResult> completePassage({
    required int sessionId,
    required Passage passage,
    required PlanDefinition? plan,
    required List<ReadingDay> schedule,
    required DateTime nowUtc,
    required DateTime nowLocal,
    required LocalDate today,
  }) {
    return _db.transaction(() async {
      await (_db.update(_db.readingSessions)
            ..where((s) => s.id.equals(sessionId)))
          .write(ReadingSessionsCompanion(completedAt: Value(nowUtc)));
      await _db.batch((b) {
        b.insertAll(_db.chapterCompletions, [
          for (final c in passage.assignment.chapters)
            ChapterCompletionsCompanion.insert(
              bookId: c.bookId,
              chapter: c.chapter,
              completedAt: nowUtc,
            ),
        ], mode: InsertMode.insertOrIgnore);
      });
      final streak = await _readStreak();
      final synthetic = ReadingDay(
        dayIndex: -1,
        date: today,
        assignments: [passage.assignment],
        requiredDuration: Duration.zero,
      );
      final newBadges = await _awardBadges(
        plan: plan,
        schedule: schedule,
        completedDay: synthetic,
        streakBefore: streak,
        streakAfter: streak,
        today: today,
        nowUtc: nowUtc,
        nowLocal: nowLocal,
      );
      return CompletionResult(streak: streak, newBadges: newBadges);
    });
  }

  /// Saves (or clears) the reflection on a sitting. Empty is null: a note
  /// the reader emptied should disappear from the journal, not sit there
  /// blank.
  Future<void> setNote(int sessionId, String note) {
    final trimmed = note.trim();
    return (_db.update(
      _db.readingSessions,
    )..where((s) => s.id.equals(sessionId))).write(
      ReadingSessionsCompanion(note: Value(trimmed.isEmpty ? null : trimmed)),
    );
  }

  /// Every reflection, newest first.
  Stream<List<ReadingSession>> watchReflections() =>
      (_db.select(_db.readingSessions)
            ..where((s) => s.note.isNotNull() & s.completedAt.isNotNull())
            ..orderBy([(s) => OrderingTerm.desc(s.completedAt)]))
          .watch();

  /// The completed sitting for a plan day, if there is one — the row a note
  /// for that day hangs off.
  Future<ReadingSession?> completedSessionFor(int planId, int dayIndex) =>
      (_db.select(_db.readingSessions)
            ..where(
              (s) =>
                  s.planId.equals(planId) &
                  s.dayIndex.equals(dayIndex) &
                  s.completedAt.isNotNull(),
            )
            ..orderBy([(s) => OrderingTerm.desc(s.completedAt)])
            ..limit(1))
          .getSingleOrNull();

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
              graceUsedOnEpochDay: Value(after.graceUsedOn?.epochDay),
            ),
          );

      final newBadges = await _awardBadges(
        plan: plan,
        schedule: schedule,
        completedDay: day,
        streakBefore: before,
        streakAfter: after,
        today: today,
        nowUtc: nowUtc,
        nowLocal: nowLocal,
      );
      return CompletionResult(
        streak: after,
        newBadges: newBadges,
        graceUsedOn: after.graceUsedOn != before.graceUsedOn
            ? after.graceUsedOn
            : null,
      );
    });
  }

  // ── achievements ───────────────────────────────────────────────────────

  /// Evaluate and store badges from the facts as they stand inside the
  /// caller's transaction. Shared by plan-day and one-time completions.
  Future<List<BadgeDefinition>> _awardBadges({
    required PlanDefinition? plan,
    required List<ReadingDay> schedule,
    required ReadingDay completedDay,
    required StreakState streakBefore,
    required StreakState streakAfter,
    required LocalDate today,
    required DateTime nowUtc,
    required DateTime nowLocal,
  }) async {
    final planDone = plan == null
        ? <int>{}
        : await _completedDayIndexesOnce(plan.id);
    final progress = BibleProgress.compute(
      completedByBook: await _completedByBookOnce(),
      daysCompleted: planDone.length,
      totalDays: schedule.length,
      planStart: plan?.startDate ?? today,
      today: today,
    );
    final newBadges = _achievements.evaluate(
      facts: AchievementFacts(
        progress: progress,
        streakBefore: streakBefore,
        streakAfter: streakAfter,
        totalDaysCompleted: await _totalDayCountOnce(),
        planDaysCompleted: planDone.length,
        planSchedule: schedule,
        completedDayIndexes: planDone,
        completedDay: completedDay,
        today: today,
        completedAtLocal: nowLocal,
        completedPassages: await _completedPassagesOnce(),
      ),
      unlocked: await _unlockedIdsOnce(),
    );
    if (newBadges.isNotEmpty) {
      await _db.batch((b) {
        b.insertAll(_db.achievements, [
          for (final badge in newBadges)
            AchievementsCompanion.insert(badgeId: badge.id, unlockedAt: nowUtc),
        ], mode: InsertMode.insertOrIgnore);
      });
    }
    return newBadges;
  }

  Future<List<Passage>> _completedPassagesOnce() async {
    final rows =
        await (_db.select(_db.readingSessions)..where(
              (s) => s.passageBookId.isNotNull() & s.completedAt.isNotNull(),
            ))
            .get();
    return [for (final r in rows) passageOf(r)!];
  }

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
          graceUsedOn: row.graceUsedOnEpochDay == null
              ? null
              : LocalDate.fromEpochDay(row.graceUsedOnEpochDay!),
        );
}

/// What a completion produced, for the celebration screen.
class CompletionResult {
  const CompletionResult({
    required this.streak,
    required this.newBadges,
    this.graceUsedOn,
  });
  final StreakState streak;
  final List<BadgeDefinition> newBadges;

  /// Set when this completion spent the month's grace day, naming the day it
  /// covered. The celebration says so — a run that survives a miss without
  /// explanation looks like a bug.
  final LocalDate? graceUsedOn;
}

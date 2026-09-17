import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// A plan as the user configured it. Everything else about a plan is
/// regenerated from these fields — see `ReadingPlanGenerator`.
class ReadingPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get scopeCode => text()();
  IntColumn get targetDays => integer()();
  IntColumn get startEpochDay => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}

/// A scheduled day the user finished. Keyed by day index, not date, so a
/// start-date change keeps every completed day attached to its chapters.
class DayCompletions extends Table {
  IntColumn get planId => integer()();
  IntColumn get dayIndex => integer()();
  IntColumn get completedOnEpochDay => integer()();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {planId, dayIndex};
}

/// The source of truth for Bible progress, independent of any plan.
/// Switching plans never loses a chapter already read.
class ChapterCompletions extends Table {
  TextColumn get bookId => text()();
  IntColumn get chapter => integer()();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get planId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {bookId, chapter};
}

/// A timed reading. `startedAt` is the fact the timer is computed from; the
/// UI counter is cosmetic.
class ReadingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId => integer()();
  IntColumn get dayIndex => integer()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get requiredMs => integer()();
  IntColumn get foregroundMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get invalidatedReason => text().nullable()();

  /// A one-time reading outside the plan ("Sermon on the Mount", Matthew
  /// 5–7). When set, `dayIndex` is -1 and the session is not a plan day: its
  /// chapters still land in `chapter_completions`, it does not complete a
  /// `day_completions` row and does not move the streak.
  /// What the reader wrote afterwards, if anything. A reflection belongs to
  /// the sitting, not the day, so a one-time reading can carry one too.
  TextColumn get note => text().nullable()();

  /// "Mark 9–10", stamped when the sitting starts. Recomputing it later from
  /// the schedule would lie: changing the plan or its start date moves which
  /// chapters day 4 holds, and a journal entry must keep saying what was
  /// actually read.
  TextColumn get reference => text().nullable()();

  TextColumn get passageTitle => text().nullable()();
  TextColumn get passageBookId => text().nullable()();
  IntColumn get passageFrom => integer().nullable()();
  IntColumn get passageTo => integer().nullable()();
}

class Streaks extends Table {
  IntColumn get id => integer()();
  IntColumn get current => integer().withDefault(const Constant(0))();
  IntColumn get longest => integer().withDefault(const Constant(0))();
  IntColumn get lastCompletedOnEpochDay => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Achievements extends Table {
  TextColumn get badgeId => text()();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {badgeId};
}

@DriftDatabase(
  tables: [
    ReadingPlans,
    DayCompletions,
    ChapterCompletions,
    ReadingSessions,
    Streaks,
    Achievements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'bible_reading_plan'));

  /// For tests: any executor, typically `NativeDatabase.memory()`.
  AppDatabase.withExecutor(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v2: one-time readings ride on the sessions table.
        await m.addColumn(readingSessions, readingSessions.passageTitle);
        await m.addColumn(readingSessions, readingSessions.passageBookId);
        await m.addColumn(readingSessions, readingSessions.passageFrom);
        await m.addColumn(readingSessions, readingSessions.passageTo);
      }
      if (from < 3) {
        // v3: a reflection on the sitting, and what was read.
        await m.addColumn(readingSessions, readingSessions.note);
        await m.addColumn(readingSessions, readingSessions.reference);
      }
    },
  );

  /// Every table, in one transaction. The "clear local data" action.
  Future<void> clearAll() => transaction(() async {
    for (final t in allTables) {
      await delete(t).go();
    }
  });
}

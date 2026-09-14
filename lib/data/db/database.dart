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
  int get schemaVersion => 1;

  /// Every table, in one transaction. The "clear local data" action.
  Future<void> clearAll() => transaction(() async {
    for (final t in allTables) {
      await delete(t).go();
    }
  });
}

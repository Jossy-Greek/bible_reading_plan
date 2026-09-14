import 'package:drift/drift.dart';

import '../../core/time/local_date.dart';
import '../../domain/plan/plan_definition.dart';
import '../db/database.dart';

class PlanRepository {
  PlanRepository(this._db);

  final AppDatabase _db;

  Future<PlanDefinition?> activePlan() async {
    final row =
        await (_db.select(_db.readingPlans)
              ..where((p) => p.isActive.equals(true))
              ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _toDefinition(row);
  }

  /// Deactivates any current plan and starts a new one. Chapter completions
  /// are untouched: they belong to the person, not the plan.
  Future<PlanDefinition> startPlan({
    required PlanScope scope,
    required int targetDays,
    required LocalDate startDate,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      await (_db.update(_db.readingPlans)
            ..where((p) => p.isActive.equals(true)))
          .write(const ReadingPlansCompanion(isActive: Value(false)));
      final id = await _db
          .into(_db.readingPlans)
          .insert(
            ReadingPlansCompanion.insert(
              scopeCode: scope.code,
              targetDays: targetDays,
              startEpochDay: startDate.epochDay,
              createdAt: now,
            ),
          );
      return PlanDefinition(
        id: id,
        scope: scope,
        targetDays: targetDays,
        startDate: startDate,
      );
    });
  }

  /// Moves the plan's first day. Day completions are keyed by index, so
  /// every completed day keeps its chapters and simply shows a new date.
  Future<void> updateStartDate(int planId, LocalDate start) =>
      (_db.update(_db.readingPlans)..where((p) => p.id.equals(planId))).write(
        ReadingPlansCompanion(startEpochDay: Value(start.epochDay)),
      );

  PlanDefinition _toDefinition(ReadingPlan r) => PlanDefinition(
    id: r.id,
    scope: PlanScope.fromCode(r.scopeCode),
    targetDays: r.targetDays,
    startDate: LocalDate.fromEpochDay(r.startEpochDay),
  );
}

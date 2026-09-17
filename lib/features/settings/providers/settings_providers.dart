import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/plan/plan_definition.dart';
import '../../../domain/reading_time/reading_time_service.dart';
import '../../../notifications/reminder_coordinator.dart';
import '../../../notifications/reminder_plan.dart';
import '../../reading/providers/reading_providers.dart';

/// SharedPreferences is not observable, so every write bumps this and every
/// screen that shows a setting watches it.
class SettingsRevision extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final settingsRevisionProvider = NotifierProvider<SettingsRevision, int>(
  SettingsRevision.new,
);

/// Everything Settings can do, in one place, each step followed by the
/// invalidations and reminder refresh it implies.
class SettingsActions {
  SettingsActions(this._ref);
  final Ref _ref;

  Future<void> setName(String name) async {
    await _ref.read(settingsProvider).setName(name);
    _ref.read(settingsRevisionProvider.notifier).bump();
    await _ref.read(reminderCoordinatorProvider).refresh();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _ref.read(settingsProvider).setThemeMode(mode);
    _ref.read(settingsRevisionProvider.notifier).bump();
  }

  Future<void> setPace(ReadingPace pace) async {
    await _ref.read(settingsProvider).setPace(pace);
    _ref.read(settingsRevisionProvider.notifier).bump();
    _ref.invalidate(scheduleProvider);
  }

  Future<void> setReminders(ReminderSettings r) async {
    await _ref.read(settingsProvider).setReminders(r);
    _ref.read(settingsRevisionProvider.notifier).bump();
    await _ref.read(reminderCoordinatorProvider).refresh();
  }

  /// Replaces the active plan. Chapters already read are kept (they belong
  /// to the person); any open session is closed because its day index no
  /// longer means anything.
  Future<void> startNewPlan({
    required PlanScope scope,
    required int targetDays,
  }) async {
    final clock = _ref.read(clockProvider);
    await _ref
        .read(progressRepositoryProvider)
        .invalidateOpenSessions('plan_changed');
    await _ref
        .read(planRepositoryProvider)
        .startPlan(
          scope: scope,
          targetDays: targetDays,
          startDate: clock.today(),
          now: clock.nowUtc(),
        );
    _ref.invalidate(activePlanProvider);
    await _ref.read(reminderCoordinatorProvider).refresh();
  }

  Future<void> changeStartDate(int planId, DateTime picked) async {
    await _ref
        .read(planRepositoryProvider)
        .updateStartDate(planId, LocalDate.fromDateTime(picked));
    _ref.invalidate(activePlanProvider);
    await _ref.read(reminderCoordinatorProvider).refresh();
  }

  /// Same plan, from today, with a clean slate for this plan's days. Chapter
  /// completions are kept: restarting the schedule is not unreading.
  Future<void> restartPlan(PlanDefinition current) =>
      startNewPlan(scope: current.scope, targetDays: current.targetDays);

  Future<void> resetProgress() async {
    await _ref.read(progressRepositoryProvider).resetProgress();
    _ref.invalidate(activePlanProvider);
    await _ref.read(reminderCoordinatorProvider).refresh();
  }

  /// Back to the very first launch.
  Future<void> clearAllData() async {
    await _ref.read(notificationServiceProvider).cancelAll();
    await _ref.read(databaseProvider).clearAll();
    await _ref.read(settingsProvider).clearAll();
    _ref.read(settingsRevisionProvider.notifier).bump();
    _ref.invalidate(activePlanProvider);
  }
}

final settingsActionsProvider = Provider<SettingsActions>(
  (ref) => SettingsActions(ref),
);

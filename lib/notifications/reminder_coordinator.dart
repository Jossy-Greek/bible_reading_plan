import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../features/reading/providers/reading_providers.dart';
import 'notification_service.dart';
import 'reminder_plan.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (_) => NotificationService(),
);

final reminderCoordinatorProvider = Provider<ReminderCoordinator>(
  (ref) => ReminderCoordinator(ref),
);

/// Turns current state into scheduled notifications. Called on launch, on
/// resume, after a completion and after any reminder setting changes — the
/// four moments the right answer can change while the app is around.
class ReminderCoordinator {
  ReminderCoordinator(this._ref);

  final Ref _ref;
  static const _planner = ReminderPlanner();

  Future<void> refresh() async {
    final settings = _ref.read(settingsProvider);
    final service = _ref.read(notificationServiceProvider);
    await service.init();

    final tzChanged = await service.refreshTimezone();
    if (tzChanged && service.timezone != null) {
      await settings.setLastTimezone(service.timezone!);
    }

    var todayCompleted = false;
    final plan = await _ref.read(activePlanProvider.future);
    final days = await _ref.read(scheduleProvider.future);
    if (plan != null) {
      final clock = _ref.read(clockProvider);
      final idx = plan.startDate.daysUntil(clock.today());
      if (idx >= 0 && idx < days.length) {
        todayCompleted = await _ref
            .read(progressRepositoryProvider)
            .isDayCompleted(plan.id, idx);
      }
    }

    final reminders = _planner.plan(
      settings: settings.reminders,
      name: settings.name ?? '',
      todayCompleted: todayCompleted,
      nowLocal: _ref.read(clockProvider).nowLocal(),
    );
    await service.apply(reminders);
  }
}

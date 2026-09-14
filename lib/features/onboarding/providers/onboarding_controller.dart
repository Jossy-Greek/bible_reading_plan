import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/plan/plan_definition.dart';
import '../../../notifications/reminder_coordinator.dart';
import '../../../notifications/reminder_plan.dart';

class OnboardingState {
  const OnboardingState({
    this.name = '',
    this.scope = const WholeBible(),
    this.targetDays = 365,
  });

  final String name;
  final PlanScope scope;
  final int targetDays;

  OnboardingState copyWith({String? name, PlanScope? scope, int? targetDays}) =>
      OnboardingState(
        name: name ?? this.name,
        scope: scope ?? this.scope,
        targetDays: targetDays ?? this.targetDays,
      );
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setName(String v) => state = state.copyWith(name: v);
  void setScope(PlanScope s) => state = state.copyWith(scope: s);
  void setTargetDays(int d) => state = state.copyWith(targetDays: d);

  /// Pre-fill from an existing plan (Settings → Change plan).
  void seedFrom(PlanDefinition plan) =>
      state = state.copyWith(scope: plan.scope, targetDays: plan.targetDays);

  /// Persists name, plan and reminder choice, marks onboarding done. The
  /// plan starts today. Asking the OS for notification permission happens
  /// here, at the moment the person said yes to reminders.
  Future<void> finish({required ReminderSettings reminders}) async {
    final settings = ref.read(settingsProvider);
    final clock = ref.read(clockProvider);
    await settings.setName(state.name);
    await ref
        .read(planRepositoryProvider)
        .startPlan(
          scope: state.scope,
          targetDays: state.targetDays,
          startDate: clock.today(),
          now: clock.nowUtc(),
        );
    var r = reminders;
    if (r.enabled) {
      final granted = await ref
          .read(notificationServiceProvider)
          .requestPermission();
      if (!granted) r = r.copyWith(enabled: false);
    }
    await settings.setReminders(r);
    await settings.setOnboardingDone(true);
    ref.invalidate(activePlanProvider);
    await ref.read(reminderCoordinatorProvider).refresh();
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );

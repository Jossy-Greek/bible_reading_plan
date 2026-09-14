import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/calendar/plan_calendar.dart';
import '../../reading/providers/reading_providers.dart';

/// Null until the plan and schedule are loaded. Recomputed when a day is
/// completed or the date changes.
final planCalendarProvider = Provider<PlanCalendar?>((ref) {
  final plan = ref.watch(activePlanProvider).value;
  final days = ref.watch(scheduleProvider).value;
  final completed = ref.watch(completedDayIndexesProvider).value;
  if (plan == null || days == null || completed == null) return null;
  return PlanCalendar(
    plan: plan,
    days: days,
    completed: completed,
    today: ref.watch(clockProvider).today(),
  );
});

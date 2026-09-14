import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/progress/bible_progress.dart';
import '../../reading/providers/reading_providers.dart';

final bibleProgressProvider = Provider<BibleProgress?>((ref) {
  final plan = ref.watch(activePlanProvider).value;
  final days = ref.watch(scheduleProvider).value;
  final byBook = ref.watch(completedByBookProvider).value;
  final completedDays = ref.watch(completedDayIndexesProvider).value;
  if (plan == null || days == null || byBook == null || completedDays == null) {
    return null;
  }
  return BibleProgress.compute(
    completedByBook: byBook,
    daysCompleted: completedDays.length,
    totalDays: days.length,
    planStart: plan.startDate,
    today: ref.watch(clockProvider).today(),
  );
});

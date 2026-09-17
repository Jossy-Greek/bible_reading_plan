import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/bible/bible_text.dart';
import '../core/time/clock.dart';
import '../data/db/database.dart';
import '../data/prefs/settings_store.dart';
import '../data/repositories/plan_repository.dart';
import '../domain/plan/plan_definition.dart';
import '../domain/plan/reading_day.dart';
import '../domain/plan/reading_plan_generator.dart';
import '../domain/reading_time/reading_time_service.dart';

/// Overridden in `main` once the real instance is ready.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('override in main'),
);

final clockProvider = Provider<Clock>((_) => SystemClock());

/// The bundled KJV. One instance for the app, so its book cache is shared.
final bibleTextProvider = Provider<BibleText>((_) => BibleText());

final settingsProvider = Provider<SettingsStore>(
  (ref) => SettingsStore(ref.watch(sharedPreferencesProvider)),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final planRepositoryProvider = Provider<PlanRepository>(
  (ref) => PlanRepository(ref.watch(databaseProvider)),
);

final readingTimeServiceProvider = Provider<ReadingTimeService>(
  (_) => const ReadingTimeService(),
);

final planGeneratorProvider = Provider<ReadingPlanGenerator>(
  (ref) => ReadingPlanGenerator(ref.watch(readingTimeServiceProvider)),
);

/// The active plan, or null before onboarding. Invalidate after startPlan.
final activePlanProvider = FutureProvider<PlanDefinition?>(
  (ref) => ref.watch(planRepositoryProvider).activePlan(),
);

/// The active plan's full schedule. Regenerated whenever the plan or the
/// reading pace changes; cheap enough that caching is not worth a bug.
final scheduleProvider = FutureProvider<List<ReadingDay>>((ref) async {
  final plan = await ref.watch(activePlanProvider.future);
  if (plan == null) return const [];
  final pace = ref.watch(settingsProvider).pace;
  return ref.watch(planGeneratorProvider).generate(plan, pace);
});

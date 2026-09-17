import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications/reminder_coordinator.dart';
import '../features/settings/providers/settings_providers.dart';
import 'providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class BibleReadingPlanApp extends ConsumerStatefulWidget {
  const BibleReadingPlanApp({super.key});

  @override
  ConsumerState<BibleReadingPlanApp> createState() => _AppState();
}

class _AppState extends ConsumerState<BibleReadingPlanApp>
    with WidgetsBindingObserver {
  late final _router = buildRouter(ref.read(settingsProvider));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Launch: the day may have changed since last time, the phone may have
    // rebooted, the zone may have moved. All three are one refresh.
    _refreshReminders();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshReminders();
  }

  void _refreshReminders() {
    if (!ref.read(settingsProvider).onboardingDone) return;
    ref.read(reminderCoordinatorProvider).refresh().catchError((Object e) {
      debugPrint('reminder refresh failed: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(settingsRevisionProvider);
    final themeMode = ref.watch(settingsProvider).themeMode;
    return MaterialApp.router(
      title: 'Bible Reading Plan',
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      // SharedPreferences is not observable: watch the revision counter so
      // switching Light/Dark in Settings repaints the whole app at once.
      themeMode: themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

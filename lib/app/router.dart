import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/prefs/settings_store.dart';
import '../features/achievements/screens/achievements_screen.dart';
import '../features/calendar/screens/calendar_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/onboarding/screens/name_screen.dart';
import '../features/onboarding/screens/plan_screen.dart';
import '../features/onboarding/screens/reminder_screen.dart';
import '../features/journal/screens/journal_screen.dart';
import '../features/passages/screens/passages_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/reading/screens/completion_screen.dart';
import '../features/reading/screens/reading_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import 'shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(SettingsStore settings) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    redirect: (context, state) {
      final inOnboarding = state.matchedLocation.startsWith('/onboarding');
      if (!settings.onboardingDone && !inOnboarding) return '/onboarding';
      if (settings.onboardingDone && inOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const NameScreen(),
        routes: [
          GoRoute(path: 'plan', builder: (_, _) => const PlanScreen()),
          GoRoute(path: 'reminder', builder: (_, _) => const ReminderScreen()),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (_, _) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (_, _) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/achievements',
                builder: (_, _) => const AchievementsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, _) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'plan',
                    builder: (_, _) => const PlanScreen(onboarding: false),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/journal',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const JournalScreen(),
      ),
      GoRoute(
        path: '/passages',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const PassagesScreen(),
      ),
      // Over the shell: a reading is a focused, full-screen act.
      GoRoute(
        path: '/reading',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ReadingScreen(),
        routes: [
          GoRoute(
            path: 'complete',
            parentNavigatorKey: _rootKey,
            builder: (_, state) =>
                CompletionScreen(args: state.extra as CompletionArgs),
          ),
        ],
      ),
    ],
  );
}

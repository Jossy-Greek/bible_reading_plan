import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../reading/providers/reading_providers.dart';

/// badgeId → when it was unlocked.
final unlockedBadgesProvider = StreamProvider<Map<String, DateTime>>(
  (ref) => ref.watch(progressRepositoryProvider).watchAchievements(),
);

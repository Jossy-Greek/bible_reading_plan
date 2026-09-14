import '../../core/bible/books.dart';
import '../progress/bible_progress.dart';
import '../streak/streak_service.dart';
import 'badges.dart';

/// Decides which badges a completion has just earned.
///
/// Pure. Given the facts after a completion and the set already unlocked, it
/// returns the definitions that are newly satisfied. The repository stores
/// them in the same transaction as the completion, so a badge can never be
/// earned by a reading that was then rolled back.
class AchievementService {
  const AchievementService();

  List<BadgeDefinition> evaluate({
    required BibleProgress progress,
    required StreakState streak,
    required Set<String> unlocked,
  }) => [
    for (final b in kBadges)
      if (!unlocked.contains(b.id) && _satisfied(b.rule, progress, streak)) b,
  ];

  bool _satisfied(BadgeRule rule, BibleProgress p, StreakState s) =>
      switch (rule) {
        FirstReading() => p.completedChapters > 0,
        // `longest`, not `current`: a streak badge is earned the day the run
        // reaches the number, and nothing after can un-earn it.
        StreakReached(:final days) => s.longest >= days,
        ChaptersReached(:final chapters) => p.completedChapters >= chapters,
        FractionReached(:final fraction) => p.fraction >= fraction,
        TestamentCompleted(:final testament) => switch (testament) {
          Testament.old => p.oldTestamentDone,
          Testament.newT => p.newTestamentDone,
        },
        BibleCompleted() => p.bibleDone,
      };
}

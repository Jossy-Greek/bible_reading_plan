import '../../core/bible/books.dart';

/// What has to be true for a badge to unlock. Sealed so [AchievementService]
/// is exhaustive over it: a new kind of rule cannot be added without saying
/// how it is evaluated.
sealed class BadgeRule {
  const BadgeRule();
}

class FirstReading extends BadgeRule {
  const FirstReading();
}

class StreakReached extends BadgeRule {
  const StreakReached(this.days);
  final int days;
}

class ChaptersReached extends BadgeRule {
  const ChaptersReached(this.chapters);
  final int chapters;
}

class FractionReached extends BadgeRule {
  const FractionReached(this.fraction);
  final double fraction;
}

class TestamentCompleted extends BadgeRule {
  const TestamentCompleted(this.testament);
  final Testament testament;
}

class BibleCompleted extends BadgeRule {
  const BibleCompleted();
}

class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.rule,
  });

  /// Stable storage key. Never rename.
  final String id;
  final String title;
  final String emoji;
  final String description;
  final BadgeRule rule;
}

/// The twelve badges, in the order the Achievements screen shows them.
/// Adding one is adding a line here.
const List<BadgeDefinition> kBadges = [
  BadgeDefinition(
    id: 'first_reading',
    title: 'Getting Started',
    emoji: '🏆',
    description: 'Complete your first reading',
    rule: FirstReading(),
  ),
  BadgeDefinition(
    id: 'streak_3',
    title: '3-Day Streak',
    emoji: '🔥',
    description: 'Read for 3 consecutive days',
    rule: StreakReached(3),
  ),
  BadgeDefinition(
    id: 'streak_7',
    title: '7-Day Streak',
    emoji: '🔥',
    description: 'Read for 7 consecutive days',
    rule: StreakReached(7),
  ),
  BadgeDefinition(
    id: 'streak_14',
    title: '14-Day Streak',
    emoji: '🔥',
    description: 'Read for 14 consecutive days',
    rule: StreakReached(14),
  ),
  BadgeDefinition(
    id: 'streak_30',
    title: '30-Day Streak',
    emoji: '🔥',
    description: 'Read for 30 consecutive days',
    rule: StreakReached(30),
  ),
  BadgeDefinition(
    id: 'chapters_50',
    title: '50 Chapters',
    emoji: '📖',
    description: 'Complete 50 chapters',
    rule: ChaptersReached(50),
  ),
  BadgeDefinition(
    id: 'chapters_100',
    title: '100 Chapters',
    emoji: '📖',
    description: 'Complete 100 chapters',
    rule: ChaptersReached(100),
  ),
  BadgeDefinition(
    id: 'chapters_250',
    title: '250 Chapters',
    emoji: '📖',
    description: 'Complete 250 chapters',
    rule: ChaptersReached(250),
  ),
  BadgeDefinition(
    id: 'halfway',
    title: 'Halfway There',
    emoji: '🏆',
    description: 'Complete 50% of the Bible',
    rule: FractionReached(0.5),
  ),
  BadgeDefinition(
    id: 'new_testament',
    title: 'New Testament',
    emoji: '✝️',
    description: 'Complete the New Testament',
    rule: TestamentCompleted(Testament.newT),
  ),
  BadgeDefinition(
    id: 'old_testament',
    title: 'Old Testament',
    emoji: '📜',
    description: 'Complete the Old Testament',
    rule: TestamentCompleted(Testament.old),
  ),
  BadgeDefinition(
    id: 'bible_completed',
    title: 'Bible Completed',
    emoji: '👑',
    description: 'Complete the entire Bible',
    rule: BibleCompleted(),
  ),
];

BadgeDefinition badgeById(String id) => kBadges.firstWhere((b) => b.id == id);

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

/// Longest run ever reached. Earned for good the day the run hits the number.
class StreakReached extends BadgeRule {
  const StreakReached(this.days);
  final int days;
}

/// Total days completed across every plan — consistency without the
/// all-or-nothing edge of a streak.
class DaysCompleted extends BadgeRule {
  const DaysCompleted(this.days);
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

class BooksCompleted extends BadgeRule {
  const BooksCompleted(this.books);
  final int books;
}

class BookCompleted extends BadgeRule {
  const BookCompleted(this.bookId);
  final String bookId;
}

class SectionCompleted extends BadgeRule {
  const SectionCompleted(this.section);
  final BibleSection section;
}

class TestamentCompleted extends BadgeRule {
  const TestamentCompleted(this.testament);
  final Testament testament;
}

class BibleCompleted extends BadgeRule {
  const BibleCompleted();
}

/// Every scheduled day of the active plan is done.
class PlanCompleted extends BadgeRule {
  const PlanCompleted();
}

/// This completion was for a day that had already passed.
class CaughtUp extends BadgeRule {
  const CaughtUp();
}

/// This completion came after two or more missed days, from someone who had
/// once built a streak of at least three. Breaks are not failures; coming
/// back is the achievement (the Duolingo "comeback" finding).
class CameBack extends BadgeRule {
  const CameBack();
}

/// Completed before [hour] local time.
class CompletedBefore extends BadgeRule {
  const CompletedBefore(this.hour);
  final int hour;
}

/// Completed at or after [hour] local time, or in the small hours before the
/// 04:00 rollover.
class CompletedAfter extends BadgeRule {
  const CompletedAfter(this.hour);
  final int hour;
}

/// Number of completed one-time readings (any passage).
class PassagesRead extends BadgeRule {
  const PassagesRead(this.count);
  final int count;
}

/// A completed one-time reading whose range covers this curated passage.
class PassageCovered extends BadgeRule {
  const PassageCovered(this.passageId);
  final String passageId;
}

/// A calendar month in which every scheduled day was completed. Needs at
/// least ten scheduled days in the month so a plan that starts on the 28th
/// does not hand this out for three readings.
class PerfectMonth extends BadgeRule {
  const PerfectMonth();
}

/// Traditional groupings of the canon, for section badges.
enum BibleSection {
  law('The Law', ['genesis', 'exodus', 'leviticus', 'numbers', 'deuteronomy']),
  history('The Histories', [
    'joshua',
    'judges',
    'ruth',
    '1_samuel',
    '2_samuel',
    '1_kings',
    '2_kings',
    '1_chronicles',
    '2_chronicles',
    'ezra',
    'nehemiah',
    'esther',
  ]),
  wisdom('Wisdom', ['job', 'proverbs', 'ecclesiastes', 'song_of_solomon']),
  prophets('The Prophets', [
    'isaiah',
    'jeremiah',
    'lamentations',
    'ezekiel',
    'daniel',
    'hosea',
    'joel',
    'amos',
    'obadiah',
    'jonah',
    'micah',
    'nahum',
    'habakkuk',
    'zephaniah',
    'haggai',
    'zechariah',
    'malachi',
  ]),
  gospels('The Gospels', ['matthew', 'mark', 'luke', 'john']),
  paul("Paul's Letters", [
    'romans',
    '1_corinthians',
    '2_corinthians',
    'galatians',
    'ephesians',
    'philippians',
    'colossians',
    '1_thessalonians',
    '2_thessalonians',
    '1_timothy',
    '2_timothy',
    'titus',
    'philemon',
  ]);

  const BibleSection(this.title, this.bookIds);
  final String title;
  final List<String> bookIds;
}

/// How the Achievements screen groups badges.
enum BadgeCategory {
  start('Getting going'),
  streak('Streaks'),
  consistency('Consistency'),
  volume('Chapters'),
  library('Books & sections'),
  passages('One-time readings'),
  milestone('Milestones');

  const BadgeCategory(this.title);
  final String title;
}

class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.rule,
    required this.category,
  });

  /// Stable storage key. Never rename.
  final String id;
  final String title;
  final String emoji;
  final String description;
  final BadgeRule rule;
  final BadgeCategory category;
}

/// Every badge, in display order within its category. Adding one is a line.
///
/// Design notes (2026-09-14, from a look at YouVersion, Duolingo, Nike Run
/// Club and the gamification literature):
///  - Streaks lead, because 7–14 consecutive days is where a habit sets, and
///    the ladder reaches a full year so the far target is visible on day one.
///  - Consistency badges count total days, so a person whose streak broke
///    still sees the count climb. "Back on Track" rewards the return itself.
///  - Volume, books and sections give something to earn between streak
///    milestones on a long plan; the whole-Bible tier sits at the top.
const List<BadgeDefinition> kBadges = [
  // ── Getting going ──
  BadgeDefinition(
    id: 'first_reading',
    title: 'Getting Started',
    emoji: '🏆',
    description: 'Complete your first reading',
    rule: FirstReading(),
    category: BadgeCategory.start,
  ),
  BadgeDefinition(
    id: 'early_bird',
    title: 'Early Bird',
    emoji: '🌄',
    description: 'Finish a reading before 7 AM',
    rule: CompletedBefore(7),
    category: BadgeCategory.start,
  ),
  BadgeDefinition(
    id: 'night_owl',
    title: 'Night Owl',
    emoji: '🌙',
    description: 'Finish a reading after 10 PM',
    rule: CompletedAfter(22),
    category: BadgeCategory.start,
  ),
  BadgeDefinition(
    id: 'caught_up',
    title: 'Catching Up',
    emoji: '🧭',
    description: 'Go back and read a day you missed',
    rule: CaughtUp(),
    category: BadgeCategory.start,
  ),
  BadgeDefinition(
    id: 'came_back',
    title: 'Back on Track',
    emoji: '🌅',
    description: 'Return after two or more missed days',
    rule: CameBack(),
    category: BadgeCategory.start,
  ),

  // ── Streaks ──
  BadgeDefinition(
    id: 'streak_3',
    title: '3-Day Streak',
    emoji: '🔥',
    description: 'Read for 3 consecutive days',
    rule: StreakReached(3),
    category: BadgeCategory.streak,
  ),
  BadgeDefinition(
    id: 'streak_7',
    title: '7-Day Streak',
    emoji: '🔥',
    description: 'Read for 7 consecutive days',
    rule: StreakReached(7),
    category: BadgeCategory.streak,
  ),
  BadgeDefinition(
    id: 'streak_14',
    title: '14-Day Streak',
    emoji: '🔥',
    description: 'Read for 14 consecutive days',
    rule: StreakReached(14),
    category: BadgeCategory.streak,
  ),
  BadgeDefinition(
    id: 'streak_30',
    title: '30-Day Streak',
    emoji: '🔥',
    description: 'Read for 30 consecutive days',
    rule: StreakReached(30),
    category: BadgeCategory.streak,
  ),
  BadgeDefinition(
    id: 'streak_50',
    title: '50-Day Streak',
    emoji: '🔥',
    description: 'Read for 50 consecutive days',
    rule: StreakReached(50),
    category: BadgeCategory.streak,
  ),
  BadgeDefinition(
    id: 'streak_100',
    title: '100-Day Streak',
    emoji: '💯',
    description: 'Read for 100 consecutive days',
    rule: StreakReached(100),
    category: BadgeCategory.streak,
  ),
  BadgeDefinition(
    id: 'streak_365',
    title: 'A Year Unbroken',
    emoji: '🏅',
    description: 'Read for 365 consecutive days',
    rule: StreakReached(365),
    category: BadgeCategory.streak,
  ),

  // ── Consistency ──
  BadgeDefinition(
    id: 'days_30',
    title: '30 Days of Reading',
    emoji: '📅',
    description: 'Complete 30 reading days, in any order',
    rule: DaysCompleted(30),
    category: BadgeCategory.consistency,
  ),
  BadgeDefinition(
    id: 'days_100',
    title: '100 Days of Reading',
    emoji: '📅',
    description: 'Complete 100 reading days',
    rule: DaysCompleted(100),
    category: BadgeCategory.consistency,
  ),
  BadgeDefinition(
    id: 'days_365',
    title: 'A Year of Reading',
    emoji: '🗓️',
    description: 'Complete 365 reading days',
    rule: DaysCompleted(365),
    category: BadgeCategory.consistency,
  ),
  BadgeDefinition(
    id: 'perfect_month',
    title: 'Perfect Month',
    emoji: '✨',
    description: 'Complete every scheduled day in a calendar month',
    rule: PerfectMonth(),
    category: BadgeCategory.consistency,
  ),

  // ── Chapters ──
  BadgeDefinition(
    id: 'chapters_50',
    title: '50 Chapters',
    emoji: '📖',
    description: 'Complete 50 chapters',
    rule: ChaptersReached(50),
    category: BadgeCategory.volume,
  ),
  BadgeDefinition(
    id: 'chapters_100',
    title: '100 Chapters',
    emoji: '📖',
    description: 'Complete 100 chapters',
    rule: ChaptersReached(100),
    category: BadgeCategory.volume,
  ),
  BadgeDefinition(
    id: 'chapters_250',
    title: '250 Chapters',
    emoji: '📖',
    description: 'Complete 250 chapters',
    rule: ChaptersReached(250),
    category: BadgeCategory.volume,
  ),
  BadgeDefinition(
    id: 'chapters_500',
    title: '500 Chapters',
    emoji: '📚',
    description: 'Complete 500 chapters',
    rule: ChaptersReached(500),
    category: BadgeCategory.volume,
  ),
  BadgeDefinition(
    id: 'halfway',
    title: 'Halfway There',
    emoji: '🏆',
    description: 'Complete 50% of the Bible',
    rule: FractionReached(0.5),
    category: BadgeCategory.volume,
  ),
  BadgeDefinition(
    id: 'chapters_1000',
    title: '1,000 Chapters',
    emoji: '📚',
    description: 'Complete 1,000 chapters',
    rule: ChaptersReached(1000),
    category: BadgeCategory.volume,
  ),

  // ── Books & sections ──
  BadgeDefinition(
    id: 'first_book',
    title: 'First Book',
    emoji: '📕',
    description: 'Finish every chapter of one book',
    rule: BooksCompleted(1),
    category: BadgeCategory.library,
  ),
  BadgeDefinition(
    id: 'books_10',
    title: 'Ten Books',
    emoji: '📗',
    description: 'Finish 10 books',
    rule: BooksCompleted(10),
    category: BadgeCategory.library,
  ),
  BadgeDefinition(
    id: 'books_33',
    title: 'Half the Library',
    emoji: '📘',
    description: 'Finish 33 of the 66 books',
    rule: BooksCompleted(33),
    category: BadgeCategory.library,
  ),
  BadgeDefinition(
    id: 'section_law',
    title: 'The Law',
    emoji: '📜',
    description: 'Finish Genesis through Deuteronomy',
    rule: SectionCompleted(BibleSection.law),
    category: BadgeCategory.library,
  ),
  BadgeDefinition(
    id: 'section_history',
    title: 'The Histories',
    emoji: '🏺',
    description: 'Finish Joshua through Esther',
    rule: SectionCompleted(BibleSection.history),
    category: BadgeCategory.library,
  ),
  BadgeDefinition(
    id: 'psalms',
    title: 'Psalms',
    emoji: '🎶',
    description: 'Finish all 150 Psalms',
    rule: BookCompleted('psalms'),
    category: BadgeCategory.library,
  ),
  BadgeDefinition(
    id: 'section_wisdom',
    title: 'Wisdom',
    emoji: '🦉',
    description: 'Finish Job, Proverbs, Ecclesiastes and Song of Solomon',
    rule: SectionCompleted(BibleSection.wisdom),
    category: BadgeCategory.library,
  ),
  BadgeDefinition(
    id: 'section_prophets',
    title: 'The Prophets',
    emoji: '🕊️',
    description: 'Finish Isaiah through Malachi',
    rule: SectionCompleted(BibleSection.prophets),
    category: BadgeCategory.library,
  ),
  BadgeDefinition(
    id: 'section_gospels',
    title: 'The Gospels',
    emoji: '✝️',
    description: 'Finish Matthew, Mark, Luke and John',
    rule: SectionCompleted(BibleSection.gospels),
    category: BadgeCategory.library,
  ),
  BadgeDefinition(
    id: 'section_paul',
    title: "Paul's Letters",
    emoji: '✉️',
    description: 'Finish Romans through Philemon',
    rule: SectionCompleted(BibleSection.paul),
    category: BadgeCategory.library,
  ),

  // ── One-time readings ──
  BadgeDefinition(
    id: 'first_passage',
    title: 'Free Reading',
    emoji: '🕊️',
    description: 'Complete a one-time reading outside your plan',
    rule: PassagesRead(1),
    category: BadgeCategory.passages,
  ),
  BadgeDefinition(
    id: 'passages_5',
    title: 'Explorer',
    emoji: '🗺️',
    description: 'Complete 5 one-time readings',
    rule: PassagesRead(5),
    category: BadgeCategory.passages,
  ),
  BadgeDefinition(
    id: 'passages_15',
    title: 'Wayfarer',
    emoji: '⛰️',
    description: 'Complete 15 one-time readings',
    rule: PassagesRead(15),
    category: BadgeCategory.passages,
  ),
  BadgeDefinition(
    id: 'sermon_on_the_mount',
    title: 'Sermon on the Mount',
    emoji: '🏔️',
    description: 'Read Matthew 5–7 in one sitting',
    rule: PassageCovered('sermon_on_the_mount'),
    category: BadgeCategory.passages,
  ),
  BadgeDefinition(
    id: 'upper_room',
    title: 'The Upper Room',
    emoji: '🍞',
    description: 'Read John 13–17 in one sitting',
    rule: PassageCovered('upper_room'),
    category: BadgeCategory.passages,
  ),
  BadgeDefinition(
    id: 'psalm_119',
    title: 'The Longest Psalm',
    emoji: '📜',
    description: 'Read all 176 verses of Psalm 119 in one sitting',
    rule: PassageCovered('psalm_119'),
    category: BadgeCategory.passages,
  ),
  BadgeDefinition(
    id: 'passion',
    title: 'The Passion',
    emoji: '✝️',
    description: 'Read Matthew 26–28 in one sitting',
    rule: PassageCovered('passion'),
    category: BadgeCategory.passages,
  ),

  // ── Milestones ──
  BadgeDefinition(
    id: 'plan_complete',
    title: 'Plan Complete',
    emoji: '🎯',
    description: 'Finish every day of a reading plan',
    rule: PlanCompleted(),
    category: BadgeCategory.milestone,
  ),
  BadgeDefinition(
    id: 'new_testament',
    title: 'New Testament',
    emoji: '✝️',
    description: 'Complete the New Testament',
    rule: TestamentCompleted(Testament.newT),
    category: BadgeCategory.milestone,
  ),
  BadgeDefinition(
    id: 'old_testament',
    title: 'Old Testament',
    emoji: '📜',
    description: 'Complete the Old Testament',
    rule: TestamentCompleted(Testament.old),
    category: BadgeCategory.milestone,
  ),
  BadgeDefinition(
    id: 'bible_completed',
    title: 'Bible Completed',
    emoji: '👑',
    description: 'Complete the entire Bible',
    rule: BibleCompleted(),
    category: BadgeCategory.milestone,
  ),
];

BadgeDefinition badgeById(String id) => kBadges.firstWhere((b) => b.id == id);

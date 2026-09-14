# Bible Reading Plan — Design (Phase 0, for approval)

**Status:** awaiting approval before any app code is written (brief §23).
**Target:** Flutter 3.44 stable, Dart 3.x. Android + iOS. Fully offline.
**Folder:** `~/Documents/bible_reading_plan/` (Flutter project will be created here on approval).

---

## 1. Architecture

Feature-first, three layers, no cross-feature imports of UI.

```
UI (features/*)  →  application (providers)  →  domain services  →  data (repositories → Drift/Prefs)
```

- **Domain services are pure Dart** (no Flutter imports): `ReadingPlanGenerator`, `ReadingTimeService`, `ReadingSessionService`, `StreakService`, `AchievementService`. Every rule the brief calls "critical" lives here and is unit-tested without a device.
- **Repositories** own persistence. Providers never touch the database.
- **The plan is deterministic and generated in memory** from `(planType, startDate, pacing, bibleMetadata)`. It is not stored. Only *facts about the user* are stored: chapter completions, day completions, sessions, streak, badges, settings. A plan change or start-date change is therefore a regeneration, never a migration.
- **Bible progress is independent of the plan.** `chapter_completions(book_id, chapter)` is the source of truth for "127 / 1,189". Switching plans never loses read chapters.
- **Time enters through one seam**: a `Clock` interface (`now()`, `today()` as a local calendar date). Production uses the device clock; tests inject a fake. Every date rule below is written against `LocalDate` (year, month, day), never a `DateTime` timestamp.

## 2. Packages (versions current as of 2026-09-14)

| Purpose | Package | Why |
|---|---|---|
| State | `flutter_riverpod` 3.4, `riverpod_annotation` 4.0 | Compile-safe providers, easy to test, codegen already required by Drift |
| Persistence | `drift` 2.35 + `drift_flutter` 0.3 | See §3 |
| Small settings | `shared_preferences` 2.5 | Name, onboarding flag, reminder settings |
| Navigation | `go_router` 18 | `StatefulShellRoute` for the 5 tabs, full-screen reading route outside the shell |
| Notifications | `flutter_local_notifications` 22.3, `timezone` 0.11, `flutter_timezone` 5.1 | Local zoned scheduling, no server |
| Dates | `intl` 0.20 | Month names, "September 14", 12/24h |
| Codegen | `build_runner`, `drift_dev`, `riverpod_generator` | dev only |

Not used: `table_calendar` (both calendars are custom designs, a grid is 60 lines), `isar` (last release 2023, unmaintained), `hive`.

## 3. Local database: Drift (SQLite) + SharedPreferences

**Recommendation: Drift for structured user data, SharedPreferences for a handful of scalars.**

| Option | Verdict | Reason |
|---|---|---|
| **Drift / SQLite** | **Chosen** | Reading history is relational and date-shaped: "completed days this month", "chapters per book", "longest run of consecutive days" are one query each. Typed schema, real migrations for a multi-year personal-data app, transactions so "complete day + insert chapters + update streak + unlock badges" is atomic. |
| SharedPreferences | Chosen for scalars only | Right for name, onboarding flag, reminder time. Wrong for 1,189 chapter rows and a year of history. |
| Hive / hive_ce | Not chosen | Fast, but no queries and weak schema evolution. The heatmap and streak logic would be re-implemented in Dart over whole boxes. |
| Isar | Not chosen | Excellent API, no release since April 2023. Not a base for a long-lived app. |

Not over-engineered: five tables, one DAO, no joins in hot paths.

## 4. Data model

Static (Dart constants, `core/bible/`):

```dart
enum Testament { old, newT }
class BibleBook { String id; String name; String abbreviation; Testament testament; int chapters; int order; }
const kBibleBooks = [...66 books...];            // 929 OT + 260 NT = 1,189 chapters
class ChapterReference { String bookId; int chapter; }
class ReadingAssignment { String bookId; int fromChapter; int toChapter; }  // "Genesis 49–50"
class ReadingDay {                                // generated, never stored
  int dayIndex;                                   // 0-based
  LocalDate date;                                 // startDate + dayIndex
  List<ReadingAssignment> assignments;            // spans book boundaries
  int chapterCount;
  Duration requiredDuration;                      // from ReadingTimeService
}
class BadgeDefinition { String id; String title; String emoji; String description; BadgeRule rule; }
```

Persisted (Drift tables):

```
user_profile      id=1, name, created_at
reading_plans     id, type (oneYear|bookOfWeek), start_date, pacing_json, book_id?, is_active, created_at
day_completions   plan_id, day_index, completed_on (LocalDate), completed_at (UTC ms)   PK(plan_id, day_index)
chapter_completions book_id, chapter, completed_at, plan_id?                            PK(book_id, chapter)
reading_sessions  id, plan_id, day_index, started_at, required_ms, completed_at?, invalidated_reason?
streaks           id=1, current, longest, last_completed_on (LocalDate)
achievements      badge_id, unlocked_at                                                   PK(badge_id)
```

SharedPreferences: `onboarding_done`, `reminder_enabled`, `reminder_minutes_of_day`, `evening_nudge_enabled`, `evening_nudge_minutes_of_day`, `reading_pace` (relaxed|normal|quick).

Value objects: `LocalDate` (y/m/d, comparable, `+ days`, `daysBetween`), `PlanPacing` (see §5), `StreakState`, `BibleProgress` (completed, total, byTestament, byBook, percent, estimatedFinish).

## 5. Reading plan algorithm — `ReadingPlanGenerator`

Input: ordered chapter list (1,189 `ChapterReference`s Genesis 1 → Revelation 22), `startDate`, `PlanPacing`.

```
PlanPacing = fixedChaptersPerDay(n)   // brief's default: 5
           | targetDays(n)            // e.g. 365 → 94 days of 4 chapters, 271 days of 3
```

```
generate():
  perDay = pacing.chaptersFor(dayIndex)        // constant, or 4/3 spread evenly
  cursor = 0
  while cursor < 1189:
    take = min(perDay, 1189 - cursor)           // final day may be shorter
    slice = chapters[cursor : cursor+take]
    assignments = coalesce(slice)               // consecutive same-book chapters → one range
    days.add(ReadingDay(dayIndex, startDate + dayIndex, assignments, take, timeService.estimate(slice)))
    cursor += take
```

`coalesce` is what makes "Genesis 49–50 + Exodus 1–3" a single day: it walks the slice and closes a range whenever the book changes. Book boundaries need no special casing because the input is one flat list.

**A conflict in the brief to resolve (question 1 below):** 5 chapters/day finishes in **238 days**, not a year. "Bible in 1 Year" with 365 days needs 3–4 chapters/day. The generator supports both; which is the default labelled "Bible in 1 Year" is a product call.

**Plan B — Book of the Week:** `targetDays(7)` over that book's chapters only (Psalms = 21–22 chapters/day, Obadiah = 1 chapter on day 1 then rest days; a book with < 7 chapters produces < 7 reading days).

Tests: total chapters 1,189; every chapter appears exactly once; day count for each pacing; the boundary day around Genesis 50; final-day shortfall; single-chapter books.

## 6. Reading time — `ReadingTimeService`

No text in v1, so estimate from a per-book length class:

```
wordsPerChapter(book) = { short: 300, medium: 650, long: 900 }[book.lengthClass]
  // Psalms, Proverbs, Song, Lamentations, epistles → short
  // Genesis, Kings, Chronicles, Job, Isaiah, Jeremiah, Ezekiel, Gospels, Acts → long
  // everything else → medium
estimatedWords   = Σ wordsPerChapter(chapter.book)
minutes          = estimatedWords / wpm(pace)     // relaxed 160, normal 220, quick 280
required         = clamp(round(minutes), 3, 60) minutes
```

Genesis 1–5 → 4,500 words / 220 ≈ 20 min at normal, 16 at quick. The brief's "12 minutes" is reachable with `quick`; the constants are one table and are the first thing to replace with real word counts. The interface is `Duration estimate(List<ChapterReference>)`; nothing else knows how it is computed.

## 7. Session algorithm — `ReadingSessionService` (brief §4, §16)

State is **timestamps, never a counter**:

```
start(day):   insert reading_sessions(started_at = clock.nowUtc, required_ms = day.requiredDuration)
elapsed():    clock.nowUtc - started_at
remaining():  max(0, required - elapsed)
canComplete:  remaining == 0
complete():   transaction { mark session completed; insert chapter_completions for day.assignments
                            (INSERT OR IGNORE → duplicate completion is a no-op);
                            insert day_completions; StreakService.record(today); AchievementService.evaluate() }
```

The UI ticks once a second to repaint `remaining()`; the tick is cosmetic. Closing, rebuilding, navigating, or restarting the app changes nothing because `started_at` is on disk. On launch: if an uncompleted session exists for today's `dayIndex`, restore it and show "Keep reading — 7:42 remaining."

**Clock manipulation, what is realistic offline:**
- *Backwards jump* (`now < started_at`): detectable. Session is invalidated with reason `clock_moved_back`; user sees "Your device clock changed. Start again."
- *Forward jump*: indistinguishable from putting the phone down to read a paper Bible, which is the primary use case in v1 (there is no text in the app). Allowed. We additionally record `foreground_ms` via a monotonic `Stopwatch` per foreground segment and store it on the session, so a future rule ("at least 25% of the time in-app once text exists") is a one-line change.
- *Changing the date to complete future days*: `ReadingDay.date > clock.today()` → Start Reading is disabled for future days. Past days can be caught up.
- Honest limit: a determined user who edits the clock forward wins. The goal is stopping accidental and casual bypass, and the design does that; DRM is out of scope by the brief's own words.

## 8. Streak algorithm — `StreakService`

All in `LocalDate`. "Today" is `clock.today()` with a **04:00 rollover**: a reading finished at 00:40 counts for the previous calendar day. (Question 3 below.)

```
record(completedOn):
  if last == null || completedOn == last + 1  → current += 1
  else if completedOn == last                  → no change (second completion same day)
  else if completedOn > last + 1               → current = 1
  longest = max(longest, current); last = max(last, completedOn)
displayed current:
  if last < today - 1 → 0 (lazy reset; never mutates on read)
```

Catch-up (completing yesterday's reading today) completes the chapters and the day, and counts as *today's* completion for streak purposes if today's own reading is not yet done; it never resurrects a broken streak. Plan B rest days (book shorter than 7 chapters) are not scheduled days and do not break a streak. Timezone: `today()` derives from the device's local zone at call time; a traveller crossing a date line at most gains or loses one day, and the lazy reset tolerates a single gap of zero (same date twice).

## 9. Badge system — `AchievementService`

```dart
sealed class BadgeRule {
  FirstReading(); StreakReached(days); ChaptersReached(n); PercentReached(p);
  TestamentCompleted(t); BibleCompleted();
}
```

`evaluate(progress, streak)` runs after every completion inside the same transaction, iterates `kBadges`, unlocks any rule that is satisfied and not yet in `achievements`, and returns the newly unlocked list so the completion screen can celebrate them. Adding a badge is one constant. The twelve badges in the brief map one-to-one onto these six rule types.

## 10. Notification architecture

- `NotificationService` wraps `flutter_local_notifications`; `ReminderScheduler` decides *what* to schedule from `ReminderSettings` + today's completion state.
- Two channels, at most two notifications per day: **daily reminder** at the chosen time; **evening nudge** at a second chosen time, scheduled only while today is incomplete and cancelled the moment the day completes.
- Scheduling uses `zonedSchedule` with `matchDateTimeComponents: time` for the daily one (repeats without the app opening) and a one-shot for the nudge, rescheduled on: app launch, completion, settings change, `didChangeAppLifecycleState.resumed` when the timezone name differs from the last stored one.
- Android: `POST_NOTIFICATIONS` runtime permission (13+); **inexact** alarms so the special `SCHEDULE_EXACT_ALARM` permission is never requested; a few minutes' drift is fine for a reminder. iOS: permission requested on the onboarding reminder step, not on first launch.
- Permission denied → the toggle shows "Notifications are off in system settings" with a deep link; the app never re-prompts on its own. Scheduling failure → logged, reminder toggle stays on, retried next launch.

## 11. Navigation

```
/onboarding            (name → plan → reminder)          outside shell, first launch only
/                      StatefulShellRoute, 5 branches:
  /home  /calendar  /progress  /achievements  /settings
/calendar/day/:date    day detail (pushed within branch)
/calendar/year         yearly heatmap
/reading               full-screen session, pushed over the shell, back button asks before leaving
/reading/complete      celebration
/settings/profile  /settings/reminders  /settings/reading  /settings/data
```

## 12. Screens

Onboarding: Name · Choose plan (A / B with book picker) · Reminder time (skippable).
Home: greeting by time of day, Today's Reading card (range, day X of N, minutes, chapters done), Start Reading / Keep Reading / Completed state, streak chip, small progress bar, one verse.
Reading Session: range, required time, large remaining, verse, Continue Reading / Mark as Done (disabled until 0:00). Completion: 🎉, streak, chapters ticked, new badges.
Calendar: month grid (✓ ○ — with today ringed), day detail sheet, yearly heatmap (52×7 cells, 4 intensity levels by chapters read, legend, totals).
Progress: 127 / 1,189 · 10.7%, ring, OT and NT bars, per-book list, days completed, streaks, estimated finish.
Achievements: badge grid, locked greyed with rule text, unlocked with date.
Settings: Profile · Reminders · Reading pace · Data (reset progress, restart plan, clear all — each with a typed-confirmation dialog).

## 13. Folder structure

```
lib/
  main.dart  app/ (app.dart, router.dart, theme/)
  core/  bible/ (books.dart, chapters.dart)  time/ (clock.dart, local_date.dart)  util/
  data/  db/ (database.dart, tables.dart, daos/)  prefs/ (settings_store.dart)  repositories/
  domain/  plan/ (reading_plan_generator.dart, pacing.dart)  reading_time/  session/  streak/  achievements/ (badges.dart, rules.dart)
  features/  onboarding/  home/  reading/  calendar/  progress/  achievements/  settings/   (each: providers/ screens/ widgets/)
  notifications/ (notification_service.dart, reminder_scheduler.dart)
test/  domain/ (generator, time, session, streak, badges)  data/ (repositories against in-memory Drift)
```

## 14. Edge cases — chosen behaviour

| Case | Behaviour |
|---|---|
| Skips a day | Day shows ○ missed; streak resets lazily; the reading stays available to catch up from the calendar |
| Completes several days later | Each catch-up runs its own timed session; chapters and days complete; streak counts only today once |
| Changes plan | Old plan marked inactive; chapter completions kept; new plan starts today; badges kept |
| Changes start date | Regenerate; `day_completions` are keyed by `day_index` so completed days keep their chapters; confirm dialog explains dates will shift |
| Changes device date backwards | Active session invalidated (`clock_moved_back`); streak unaffected (lazy read uses max) |
| Changes device date forwards | Allowed; future days still gated by `date > today()` at the new date |
| App killed during reading | Session restored from `started_at` on next launch |
| Phone restarted | Same; notifications rescheduled on launch (Android `RECEIVE_BOOT_COMPLETED` also re-registers) |
| Starts, closes, never finishes | Session remains open for that day; next day it is shown as an unfinished day; a new day starts a new session |
| Finishes after midnight | 04:00 rollover: before 04:00 counts for the previous day |
| Leap years / month lengths | `LocalDate` arithmetic via `DateTime.utc(y, m, d + n)` normalisation; tested for Feb 29 2028 |
| Final day < 5 chapters | Generator takes `min(perDay, remaining)` |
| Book boundaries | Flat chapter list + `coalesce` |
| Duplicate completion | `INSERT OR IGNORE` on chapters; day completion PK; button disabled after first tap |
| Notification permission denied | Toggle explains, links to system settings, no re-prompt |
| Scheduling failure | Logged, retried on next launch, never blocks completion |
| Timezone change | Detected on resume, notifications rescheduled, `today()` follows device zone |

## 15. MVP order — all five phases shipped 2026-09-14

Deviations from the plan above, made during implementation:
- `user_profile` table dropped; the name lives in SharedPreferences.
- `ReadingTimeService` is verse-based (decision 4), not length-class based.
- Plans are scope × duration (decision 1); `PlanPacing` became `targetDays`.
- The evening nudge repeats daily from tomorrow once today is done, rather than
  being a one-shot, so a day the app is never opened still gets its nudge.
- Onboarding gained a third step (reminder time) where notification permission
  is requested — never on first launch.

| Phase | Delivers | Proof |
|---|---|---|
| 1 | Project, theme, `LocalDate`/`Clock`, Bible metadata, generator, time service, Drift schema, onboarding (name + plan), **all five tabs as real screens**: Settings with Profile / Reading pace / Data actions working, Achievements showing every badge locked, Calendar and Progress reading the (empty) store | Unit tests: 1,189 chapters, boundaries, day counts |
| 2 | Home, reading session with persisted timestamps, completion transaction | Kill-and-restore test; clock-back test |
| 3 | Month calendar, day detail, yearly heatmap, Progress screen | Repository tests on in-memory DB |
| 4 | Streak, badge **unlocking**, celebration | Streak tests across midnight, gaps, catch-up |
| 5 | Notifications, reminder settings, polish, edge-case sweep | Device run on Android and iOS |

**Phasing rule (maintainer, 2026-09-14):** every tab exists as a real screen from
Phase 1. A screen whose feature is not built yet shows the real empty state
(locked badges, an empty calendar, settings that work on what exists), never a
"coming in Phase N" placeholder. Phases add behaviour behind screens that are
already there.

## Decisions (approved 2026-09-14)

1. **Plans are scope × duration.** The user picks WHAT (whole Bible, a testament, a single book) and HOW LONG (1 year, 6 months, 3 months, 1 month, 1 week); the generator computes the daily split with `targetDays`. "Bible in 1 Year" is the 365-day spread (3–4 chapters/day). Chapters/day is shown before confirming so a heavy pace is visible.
2. **App name "Bible Reading Plan"; org `com.planbible`** → Android `com.planbible.bible_reading_plan`, iOS `com.planbible.bibleReadingPlan`.
3. **Day rollover at 04:00.**
4. **Reading time is verse-based.** Every one of the 1,189 chapters carries its verse count (KJV numbering, 31,102 verses total); `required = verses × secondsPerVerse(pace)`, with words/verse ≈ 25 so normal (220 wpm) ≈ 6.8 s per verse. Genesis 1–5 = 138 verses ≈ 16 min. Replaces the length-class table in §6.

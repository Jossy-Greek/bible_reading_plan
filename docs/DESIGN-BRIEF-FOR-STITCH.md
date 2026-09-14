# Bible Reading Plan — App description and screens (design brief)

Written for a visual design pass in Stitch. Every screen below exists in the
app today; the states, copy and numbers are the real ones.

---

## The app in one paragraph

Bible Reading Plan is an offline, on-device companion that helps one person
read the Bible consistently and finish it. You choose what to read (the whole
Bible, a testament, or one book) and how long to take (a year, six months,
three months, a month, a week, or any number of days). The app generates the
daily schedule, and each day is a **timed reading**: you press Start Reading,
a countdown runs for the time those chapters need, and only when it reaches
zero can you mark the day done. Around that one act sit a calendar, a yearly
heatmap, per-book progress, a streak, 36 badges and a gentle daily reminder.
No account, no cloud, no feed. Everything stays on the phone.

**Feel:** peaceful, spiritual, modern, minimal, motivating. A quiet companion
to Scripture, not a productivity dashboard. One primary action per screen.
Generous whitespace. Numbers are large and calm. Emoji are used sparingly as
warm accents (📖 🔥 🎉 🏆).

## Design language

| Token | Value | Use |
|---|---|---|
| Parchment | `#FBF8F1` | App background |
| Parchment deep | `#F1EBDD` | Subtle fills, progress tracks, locked badges |
| Ink | `#1F3A3D` | Primary text |
| Ink soft | `#52696B` | Secondary text |
| Teal | `#2F5D62` | Primary buttons, progress, today ring |
| Gold | `#C6A15B` | Accent, highlights |
| Success | `#4E7D5B` | Completed days, ticks, done states |
| Missed | `#C77B6A` | Missed days, destructive actions |

- Material 3. Cards white, no elevation, 20 px radius, no margin between card and its content padding of 24.
- Primary button: full width, 56 px tall, 16 px radius, teal, white 17 px semibold text.
- Text fields: white fill, 16 px radius, no border.
- Typography: system sans. Large numbers (countdown, scores) light weight, tabular figures. Scripture quotes italic in ink-soft.
- Bottom navigation: 5 destinations with outlined/filled icon pairs: Home, Calendar, Progress, Badges, Settings.

---

## Navigation map

```
First launch:  Name → Plan → Reminder → Home
Tabs:          Home · Calendar · Progress · Badges · Settings
Over the tabs: Reading Session → Completion
Sheets/dialogs: Book picker (OT/NT tabs) · Custom days · Day detail · confirmations
Settings → Change plan (reuses the Plan screen)
```

---

## 1. Onboarding — Name

**Purpose:** learn the name used everywhere else. First screen ever seen.

- Top: 📖 large.
- Title: **What should we call you?**
- Subtitle (ink soft): Your name stays on this device.
- Text field, placeholder "Your name", auto-capitalised, autofocus.
- Bottom: primary button **Continue**, disabled until the field has text.

## 2. Onboarding — Plan (also Settings → Change plan)

**Purpose:** choose scope × duration and see the daily load before committing.

- App bar: "Your reading plan" (or "Change plan").
- Greeting: **Welcome, Yoseph 👋** (onboarding only). In change mode, a one-line note instead: "Chapters you have already read stay read. Your streak and badges are kept. The new plan starts today."
- Section **What will you read?** — choice chips: `The whole Bible` (selected by default) · `Old Testament` · `New Testament` · `A single book…` (opens the book picker; once picked the chip shows the book's name).
- Section **Over how long?** — choice chips: `One year` (default) · `Six months` · `Three months` · `One month` · `One week` · `Custom…` (shows e.g. `100 days` once set).
- Preview card **Each day**: big line `3–4 chapters`, small line `about 16 minutes · 365 reading days`. Updates live. For a heavy pace it reads e.g. `40 chapters` / `about 2.7 hours · 30 reading days`.
- Bottom: primary button **Continue** (onboarding) or **Switch to this plan** (change mode, then a confirmation dialog).

### Book picker (bottom sheet, 80% height)
Drag handle. Two tabs: **Old Testament** · **New Testament**. Each a list: book name, "50 chapters" subtitle. Tap to choose.

### Custom days (dialog)
Title **How many days?** Number field with suffix "days", placeholder "e.g. 100". Helper line updates live: "About 12 chapters a day for the whole Bible." Buttons Cancel · **Use** (disabled outside 1–3650).

## 3. Onboarding — Reminder

**Purpose:** offer one daily reminder. Skippable.

- App bar: "A daily reminder".
- Title: **When should we remind you?**
- Subtitle: One gentle notification a day. You can change or turn it off any time in Settings.
- Card row: alarm icon · "Reminder time" · trailing `7:00 AM` (tap opens a time picker).
- Bottom: primary **Remind me** (asks the system permission), text button **Not now**.

## 4. Home

**Purpose:** today's reading and the one button that matters.

- Header row: **Good morning, Yoseph 👋** (morning / afternoon / evening by hour). Right: streak chip `🔥 7` on parchment-deep, only when the streak is alive.
- **Today's Reading card** (white, 24 padding):
  - label `Today's Reading`
  - range, large: **Genesis 1–4**
  - meta line: `Day 1 of 365 · 16 min · 111 verses`
  - `0 / 4 chapters completed`
  - Three states for the action:
    1. Not started → primary **Start Reading**
    2. In progress → primary **Keep reading — 11:42** (live countdown on the button)
    3. Done → green check icon + **Today's reading completed** (no button)
  - Fourth case: another day's catch-up is open → **Continue your open reading**
- Plan finished (no today): card "Your plan has finished. 🎉" + **Start a new plan**. Plan not started yet: "Your plan starts on 2026-10-01." + **Change plan**.

## 5. Reading Session (full screen, over the tabs)

**Purpose:** a focused, calm timer. The person is usually reading a physical Bible with the phone set down.

- App bar with back arrow, title "Reading".
- `Today's Reading` (or `Reading for September 12` for a catch-up)
- Range, large: **Genesis 1–4**
- `Required time 16:20`
- Centre: the countdown, very large, light weight, tabular: **11:42**, under it `remaining`. When finished: a large green **✓** and `Reading time completed`.
- Thin progress bar (6 px, rounded), teal filling to green when done.
- Scripture quote, italic, centred: *"Be still, and know that I am God."* — `Psalm 46:10` (rotates daily among seven).
- Bottom primary button: **Keep reading — 11:42** (disabled, shows the countdown) → **Mark as Done ✓** (enabled at zero) → **Saving…**.

### Clock changed (variant)
Title **Your device clock changed**. Body: "The time is now earlier than when this reading started, so the timer cannot be trusted. Start the reading again." Button **Back to today**.

## 6. Completion

- Centre: 🎉 very large.
- **Today's reading is complete!**
- `🔥 7 day streak`
- `Genesis 1–4 ✓` in green.
- If any: label `New badge` / `New badges`, then one card per badge: emoji · title · description (e.g. 🏆 Getting Started — Complete your first reading).
- Bottom primary **Done** → Home.

## 7. Calendar — Month

- App bar "Calendar", right: segmented control **Month | Year**.
- **Today card:** label `Today`, range `Genesis 9–12`, status `Not completed` / `Completed ✓`; right side `🔥 7` over `streak`.
- Month header with ‹ › arrows: **September 2026**.
- Weekday row `M T W T F S S` (Monday first).
- Grid of day cells, 12 px radius, 6 px gaps:
  - Completed: success green fill, white number, `✓` beneath
  - Missed: missed red at 18% fill, red number, `○`
  - Today (pending): parchment-deep fill, teal 2 px ring, bold number
  - Future in plan: white, ink-soft number, `—`
  - Outside the plan: transparent, faded number, not tappable
- Legend line: `✓ completed   ○ missed   — ahead`

## 8. Calendar — Year (heatmap)

- Same today card.
- Range line: **Sep 14, 2026 → Sep 13, 2027**; under it `40 of 365 days completed · 3 missed`.
- Heatmap: one column per week (Monday top), 14 px cells, 3 px gaps, month labels above the first column of each month; scrolls sideways for long plans. Cell colours: green with four intensities by chapters that day; missed = red 35%; today = ringed teal; ahead = parchment-deep; outside plan = empty.
- Legend: `Lighter day · Heavier day · Missed · Ahead`.

## 9. Day detail (bottom sheet)

- Title: **September 14**
- Range: **Genesis 9–12**; meta `Day 14 · 4 chapters · 16 min`
- One of:
  - `Completed ✓` (green with check icon)
  - `Not yet — this reading opens on its day.`
  - `Not completed. You can still read it.` + primary **Read this day**
  - `Not completed yet.` + primary **Start Reading** (today)
  - If another reading is open: **Finish your open reading first**
- No reading scheduled → `No reading scheduled.`

## 10. Progress

- App bar "Progress".
- **Hero card:** left a 96 px ring (teal on parchment-deep, 9 px stroke, rounded caps) with `10.7%` inside; right `Bible Progress`, **127 / 1,189**, `chapters`.
- Two bars: **Old Testament** `99 / 929` · **New Testament** `28 / 260` (green when complete).
- 2×2… actually 2×3 grid of stat tiles (label small, value titleMedium): `Chapters completed 127` · `Chapters remaining 1,062` · `Days completed 30 / 365` · `Current streak 🔥 7` · `Longest streak 12 days` · `Estimated finish Sep 13, 2027` (or `Done 🎉`).
- **By book:** under `Old Testament` and `New Testament` sub-headers, one row per book: name (green when finished) · thin progress bar · `50/50`.

## 11. Achievements (Badges)

- App bar "Achievements", right `6 / 36`.
- Six sections, each a title row with its own count (`Streaks  2 / 7`) and a 2-column grid of badge tiles:
  - **Getting going:** 🏆 Getting Started · 🌄 Early Bird · 🌙 Night Owl · 🧭 Catching Up · 🌅 Back on Track
  - **Streaks:** 🔥 3 · 7 · 14 · 30 · 50 days · 💯 100-Day Streak · 🏅 A Year Unbroken
  - **Consistency:** 📅 30 Days of Reading · 📅 100 Days · 🗓️ A Year of Reading · ✨ Perfect Month
  - **Chapters:** 📖 50 · 100 · 250 · 📚 500 · 🏆 Halfway There · 📚 1,000 Chapters
  - **Books & sections:** 📕 First Book · 📗 Ten Books · 📘 Half the Library · 📜 The Law · 🏺 The Histories · 🎶 Psalms · 🦉 Wisdom · 🕊️ The Prophets · ✝️ The Gospels · ✉️ Paul's Letters
  - **Milestones:** 🎯 Plan Complete · ✝️ New Testament · 📜 Old Testament · 👑 Bible Completed
- **Badge tile:** emoji top-left, title, then either the rule ("Read for 7 consecutive days") when locked, or `Earned Sep 20, 2026` when unlocked. Locked = parchment-deep at 60%, emoji at 35% opacity, ink-soft title. Earned = white card, full colour.

## 12. Settings

Grouped cards with small uppercase section headers.

- **PROFILE:** Name (subtitle current name, tap → dialog) · Reading plan (subtitle `The whole Bible · One year`, chevron → Change plan) · Start date (subtitle `Sep 14, 2026`, tap → date picker + confirmation "Move the start date?")
- **REMINDERS:** switch **Daily reminder** · Reminder time `7:00 AM` · switch **Evening nudge** (subtitle "Only if today is not done yet") · Nudge time `8:00 PM` · row **Send a test notification** (subtitle "Appears right away if notifications can reach you") · small status line `Scheduled on this device: Bible Reading Plan · Still time today` or `Nothing is scheduled on this device.` · red note when the system has notifications off.
- **READING:** "Reading pace" + explainer, segmented **Relaxed | Normal | Quick**.
- **DATA:** Restart plan (subtitle "Same plan, from today. Chapters read are kept.") · Reset progress (red icon; "Erase every chapter, day, streak and badge.") · Clear all local data (red icon; "Back to the first launch." — dialog requires typing `DELETE`).
- Footer, centred, ink soft: `Everything stays on this device.`

### Confirmation dialogs
Title, one-paragraph body, Cancel · action. Destructive actions use the missed red on the confirm button.

---

## Ready-to-paste Stitch prompts (one per screen)

**Global prefix for every prompt:** "Mobile app, Material 3, warm parchment background #FBF8F1, deep teal primary #2F5D62, ink text #1F3A3D, soft secondary text #52696B, success green #4E7D5B, gold accent #C6A15B. White cards with 20px radius and no shadow. Full-width 56px teal primary button with 16px radius. Calm, spiritual, minimal, generous whitespace. Bottom navigation with five tabs: Home, Calendar, Progress, Badges, Settings."

1. **Onboarding name:** large 📖, headline "What should we call you?", subtitle "Your name stays on this device.", one white text field "Your name", primary button "Continue" pinned at the bottom.
2. **Onboarding plan:** app bar "Your reading plan", headline "Welcome, Yoseph 👋", section "What will you read?" with choice chips (The whole Bible selected, Old Testament, New Testament, A single book…), section "Over how long?" with chips (One year selected, Six months, Three months, One month, One week, Custom…), a white preview card titled "Each day" showing "3–4 chapters" large and "about 16 minutes · 365 reading days" small, primary button "Continue".
3. **Onboarding reminder:** app bar "A daily reminder", headline "When should we remind you?", subtitle, a card row with alarm icon "Reminder time" and "7:00 AM" on the right, primary "Remind me", text button "Not now".
4. **Home:** headline "Good morning, Yoseph 👋" with a small pill "🔥 7" on the right; one white card: label "Today's Reading", "Genesis 1–4" large, "Day 1 of 365 · 16 min · 111 verses", "0 / 4 chapters completed", primary button "Start Reading". Show two more variants: button reading "Keep reading — 11:42", and a completed state with a green check and "Today's reading completed" instead of a button.
5. **Reading session:** app bar back arrow "Reading"; "Today's Reading", "Genesis 1–4" large, "Required time 16:20"; centred huge light-weight countdown "11:42" with "remaining" beneath; thin teal progress bar; italic centred verse "Be still, and know that I am God." with "Psalm 46:10"; bottom disabled button "Keep reading — 11:42". Variant: green ✓ with "Reading time completed" and an enabled button "Mark as Done ✓".
6. **Completion:** huge 🎉, "Today's reading is complete!", "🔥 7 day streak", "Genesis 1–4 ✓" in green, a section "New badge" with one card "🏆 Getting Started — Complete your first reading", primary "Done".
7. **Calendar month:** app bar "Calendar" with a Month|Year segmented control; a today card ("Today", "Genesis 9–12", "Not completed", "🔥 7 streak" on the right); "September 2026" with ‹ › arrows; Monday-first weekday row; a 7-column grid of rounded day cells: green with ✓ for completed, faint red with ○ for missed, today ringed in teal, future white with —, days outside the plan faded; legend "✓ completed ○ missed — ahead".
8. **Calendar year:** same header with Year selected; "Sep 14, 2026 → Sep 13, 2027", "40 of 365 days completed · 3 missed"; a GitHub-style heatmap with one column per week, month labels above, four green intensities, faint red missed cells, a teal-ringed today, light cells ahead; legend "Lighter day · Heavier day · Missed · Ahead".
9. **Day detail sheet:** bottom sheet with drag handle: "September 14", "Genesis 9–12" large, "Day 14 · 4 chapters · 16 min", line "Not completed. You can still read it.", primary button "Read this day". Variant: green check "Completed ✓".
10. **Progress:** app bar "Progress"; hero card with a 96px teal ring reading "10.7%" and beside it "Bible Progress", "127 / 1,189", "chapters"; two labelled bars "Old Testament 99 / 929" and "New Testament 28 / 260"; a 2×3 grid of stat tiles (Chapters completed 127, Chapters remaining 1,062, Days completed 30 / 365, Current streak 🔥 7, Longest streak 12 days, Estimated finish Sep 13, 2027); then "By book" with rows: book name, thin bar, "50/50".
11. **Achievements:** app bar "Achievements" with "6 / 36"; sections "Getting going", "Streaks", "Consistency", "Chapters", "Books & sections", "Milestones", each with a small count and a 2-column grid of badge tiles (emoji top-left, title, rule text); earned tiles white and vivid with "Earned Sep 20, 2026", locked tiles faded parchment with the emoji at 35% opacity. Include 🏆 Getting Started earned, 🔥 7-Day Streak locked, 👑 Bible Completed locked.
12. **Settings:** grouped white cards under small uppercase headers PROFILE (Name, Reading plan with chevron, Start date), REMINDERS (Daily reminder switch on, Reminder time 7:00 AM, Evening nudge switch, Nudge time 8:00 PM, Send a test notification, small grey status line "Scheduled on this device: Bible Reading Plan"), READING (segmented Relaxed | Normal | Quick), DATA (Restart plan, Reset progress in red, Clear all local data in red); footer "Everything stays on this device."

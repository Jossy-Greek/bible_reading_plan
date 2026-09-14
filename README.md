# Bible Reading Plan

An offline-first Bible reading companion. No backend, no account, no network:
everything lives on the device.

- Pick what to read (whole Bible, a testament, one book) and how long to take;
  the schedule is generated, never stored.
- Each day is a timed reading. The timer is two timestamps on disk, so closing
  or restarting the app cannot shorten it.
- Month calendar, yearly heatmap, per-book progress, streaks, twelve badges,
  and two local reminders a day at most.

## Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen
flutter run
```

## Layout

```
lib/
  core/        bible metadata (66 books, 1,189 chapters, 31,102 verses), LocalDate, Clock
  domain/      pure rules: plan generator, reading time, session timing, streak, calendar, progress, badges
  data/        Drift schema, SharedPreferences store, repositories
  features/    onboarding, home, reading, calendar, progress, achievements, settings
  notifications/  reminder planner (pure) + plugin wrapper + coordinator
  app/         theme, router, shell, providers
test/          every domain rule, the completion transaction on an in-memory DB
```

See `DESIGN.md` for the architecture, algorithms and the behaviour chosen for
each edge case.

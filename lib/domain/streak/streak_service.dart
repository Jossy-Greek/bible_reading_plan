import '../../core/time/local_date.dart';

class StreakState {
  const StreakState({
    this.current = 0,
    this.longest = 0,
    this.lastCompletedOn,
    this.graceUsedOn,
  });

  final int current;
  final int longest;
  final LocalDate? lastCompletedOn;

  /// The missed day a grace day covered, if one has been spent. One per
  /// calendar month, so this also records which month is used up.
  final LocalDate? graceUsedOn;
}

/// Streak rules, on calendar dates only.
///
/// Stored state is only ever advanced by a completion; the "you broke it"
/// verdict is computed on read against today's date, so the app never has to
/// run at midnight to keep the number honest.
///
/// ## The grace day
/// One missed day per calendar month does not end a run. It is automatic:
/// there is nothing to buy, equip or remember, because a streak-insurance
/// economy is the kind of engagement loop this app exists to avoid. It is
/// deliberately narrow — it covers exactly one day, and only the day
/// immediately before the reading that claims it.
class StreakService {
  const StreakService();

  /// Whether a grace day is still available for the month containing [day].
  bool graceAvailableFor(StreakState s, LocalDate day) {
    final used = s.graceUsedOn;
    return used == null || used.year != day.year || used.month != day.month;
  }

  /// Apply a completion that happened on [completedOn] (a reading day, so
  /// already 04:00-rolled by the clock).
  StreakState record(StreakState s, LocalDate completedOn) {
    final last = s.lastCompletedOn;
    if (last == null) {
      return _advance(s, 1, completedOn, s.graceUsedOn);
    }
    if (completedOn == last) return s; // second reading the same day
    if (completedOn.isBefore(last)) return s; // catching up never moves it
    if (completedOn == last.plusDays(1)) {
      return _advance(s, s.current + 1, completedOn, s.graceUsedOn);
    }

    // Exactly one day missed, and this month's grace is unspent: the run
    // continues and the grace is consumed by the day it covered.
    final missed = last.plusDays(1);
    if (completedOn == last.plusDays(2) && graceAvailableFor(s, missed)) {
      return _advance(s, s.current + 1, completedOn, missed);
    }

    return _advance(s, 1, completedOn, s.graceUsedOn);
  }

  StreakState _advance(
    StreakState s,
    int current,
    LocalDate completedOn,
    LocalDate? graceUsedOn,
  ) => StreakState(
    current: current,
    longest: current > s.longest ? current : s.longest,
    lastCompletedOn: completedOn,
    graceUsedOn: graceUsedOn,
  );

  /// What to show today. Still alive if the last completion was today or
  /// yesterday; otherwise the run is over even though storage says otherwise.
  ///
  /// Also alive if yesterday is the single missed day and this month's grace
  /// is unspent — [heldByGrace] is true then, and reading today claims it.
  int displayed(StreakState s, LocalDate today) {
    final last = s.lastCompletedOn;
    if (last == null) return 0;
    if (!last.isBefore(today.plusDays(-1))) return s.current;
    if (heldByGrace(s, today)) return s.current;
    return 0;
  }

  /// True when the run survives only because a grace day is waiting to cover
  /// yesterday. The reader has today to claim it; the UI should say so
  /// rather than showing a number that silently vanishes tomorrow.
  bool heldByGrace(StreakState s, LocalDate today) {
    final last = s.lastCompletedOn;
    if (last == null || s.current == 0) return false;
    final yesterday = today.plusDays(-1);
    return last == yesterday.plusDays(-1) && graceAvailableFor(s, yesterday);
  }

  /// True when [record] of a completion on [completedOn] would spend a grace
  /// day — what the celebration screen uses to explain itself.
  bool wouldUseGrace(StreakState s, LocalDate completedOn) {
    final last = s.lastCompletedOn;
    if (last == null) return false;
    final missed = last.plusDays(1);
    return completedOn == last.plusDays(2) && graceAvailableFor(s, missed);
  }
}

import '../../core/time/local_date.dart';

class StreakState {
  const StreakState({this.current = 0, this.longest = 0, this.lastCompletedOn});

  final int current;
  final int longest;
  final LocalDate? lastCompletedOn;
}

/// Streak rules, on calendar dates only.
///
/// Stored state is only ever advanced by a completion; the "you broke it"
/// verdict is computed on read against today's date, so the app never has to
/// run at midnight to keep the number honest.
class StreakService {
  const StreakService();

  /// Apply a completion that happened on [completedOn] (a reading day, so
  /// already 04:00-rolled by the clock).
  StreakState record(StreakState s, LocalDate completedOn) {
    final last = s.lastCompletedOn;
    int current;
    if (last == null) {
      current = 1;
    } else if (completedOn == last) {
      return s; // second reading the same day: nothing changes
    } else if (completedOn.isBefore(last)) {
      return s; // catching up an old day never moves the streak
    } else if (completedOn == last.plusDays(1)) {
      current = s.current + 1;
    } else {
      current = 1; // a gap: start over
    }
    return StreakState(
      current: current,
      longest: current > s.longest ? current : s.longest,
      lastCompletedOn: completedOn,
    );
  }

  /// What to show today. Still alive if the last completion was today or
  /// yesterday; otherwise the run is over even though storage says otherwise.
  int displayed(StreakState s, LocalDate today) {
    final last = s.lastCompletedOn;
    if (last == null) return 0;
    if (last.isBefore(today.plusDays(-1))) return 0;
    return s.current;
  }
}

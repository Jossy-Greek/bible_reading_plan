import 'local_date.dart';

/// The one seam through which time enters the app.
///
/// Production uses the device clock. Tests inject a [FixedClock] and walk it
/// across midnight, across a month end, across a timezone change — which is
/// the only way the streak and session rules get exercised without waiting a
/// day.
abstract class Clock {
  /// The current instant, UTC. Sessions are measured in this.
  DateTime nowUtc();

  /// The current instant in the device's local zone.
  DateTime nowLocal();

  /// Today's calendar date for reading purposes.
  ///
  /// Rolls over at [rolloverHour], not midnight (product decision
  /// 2026-09-14): a reading finished at 00:40 belongs to the evening that
  /// started it. So 03:59 on the 15th is still "the 14th" here.
  LocalDate today() {
    final local = nowLocal();
    final shifted = local.subtract(const Duration(hours: rolloverHour));
    return LocalDate.fromDateTime(shifted);
  }

  static const int rolloverHour = 4;
}

class SystemClock extends Clock {
  @override
  DateTime nowUtc() => DateTime.now().toUtc();

  @override
  DateTime nowLocal() => DateTime.now();
}

/// A clock that stands still until told otherwise. Test-only.
class FixedClock extends Clock {
  FixedClock(this._local);

  DateTime _local;

  void set(DateTime local) => _local = local;
  void advance(Duration d) => _local = _local.add(d);

  @override
  DateTime nowLocal() => _local;

  @override
  DateTime nowUtc() => _local.toUtc();
}

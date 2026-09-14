/// A calendar date with no time and no zone.
///
/// Every rule in this app that says "day" — streaks, the calendar, which
/// reading is today's — is written against this type, never a [DateTime].
/// A DateTime carries an instant, and an instant is a different calendar day
/// depending on where you stand; a streak must not break because the phone
/// flew east.
class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day);

  factory LocalDate.fromDateTime(DateTime dt) =>
      LocalDate(dt.year, dt.month, dt.day);

  /// Days since 1970-01-01. The storage form: a single integer that sorts,
  /// subtracts, and survives every timezone.
  factory LocalDate.fromEpochDay(int epochDay) {
    final dt = DateTime.utc(1970, 1, 1 + epochDay);
    return LocalDate(dt.year, dt.month, dt.day);
  }

  final int year;
  final int month;
  final int day;

  int get epochDay =>
      DateTime.utc(year, month, day).difference(DateTime.utc(1970)).inDays;

  /// Arithmetic goes through DateTime.utc normalisation, so Feb 29, 31-day
  /// months and year ends are handled by the platform, not by us.
  LocalDate plusDays(int n) {
    final dt = DateTime.utc(year, month, day + n);
    return LocalDate(dt.year, dt.month, dt.day);
  }

  int daysUntil(LocalDate other) => other.epochDay - epochDay;

  /// 1 = Monday … 7 = Sunday (ISO).
  int get weekday => DateTime.utc(year, month, day).weekday;

  bool isBefore(LocalDate o) => epochDay < o.epochDay;
  bool isAfter(LocalDate o) => epochDay > o.epochDay;

  @override
  int compareTo(LocalDate other) => epochDay.compareTo(other.epochDay);

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => epochDay;

  @override
  String toString() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

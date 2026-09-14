import 'package:intl/intl.dart';

import 'local_date.dart';

DateTime _dt(LocalDate d) => DateTime(d.year, d.month, d.day);

/// "September 14"
String formatLongDate(LocalDate d) => DateFormat.MMMMd().format(_dt(d));

/// "Sep 14, 2027"
String formatMediumDate(LocalDate d) => DateFormat.yMMMd().format(_dt(d));

/// "September 2026"
String formatMonthYear(int year, int month) =>
    DateFormat.yMMMM().format(DateTime(year, month));

/// "Sep"
String formatMonthShort(int month) =>
    DateFormat.MMM().format(DateTime(2000, month));

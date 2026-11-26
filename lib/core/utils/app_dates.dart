import 'package:intl/intl.dart';

abstract final class AppDates {
  static String dayMonth(DateTime d) => DateFormat('dd MMM').format(d);
  static String dayMonthYear(DateTime d) => DateFormat('d MMM yyyy').format(d);
  static String monthYear(DateTime d) => DateFormat('MMMM yyyy').format(d);
  static String monthYearShort(DateTime d) => DateFormat('MMM yyyy').format(d);
  static String monthShort(DateTime d) => DateFormat('MMM').format(d);
  static String monthName(DateTime d) => DateFormat('MMMM').format(d);
}

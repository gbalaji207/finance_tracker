import 'package:intl/intl.dart';

/// `yyyy-MM-dd` for the database. Never use toIso8601String for dates.
String sqlDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

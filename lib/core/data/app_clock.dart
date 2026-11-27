import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/data/mock_clock.dart';

/// Today's date (no time part). Fixed in sample mode.
DateTime appToday() {
  if (!AppConfig.useSupabase) return mockToday;
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

/// First day of the current month.
DateTime appMonth() {
  final t = appToday();
  return DateTime(t.year, t.month);
}

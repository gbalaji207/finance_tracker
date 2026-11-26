import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:intl/intl.dart';

/// Indian digit grouping, no decimals, `₹` prefix, real minus sign U+2212.
abstract final class Money {
  static final NumberFormat _fmt = NumberFormat('#,##,##0', 'en_IN');
  static String _abs(double v) => '₹${_fmt.format(v)}';

  /// ₹1,32,400. Negative: −₹1,000.
  static String plain(double v) => v < 0 ? '−${_abs(-v)}' : _abs(v);

  /// Direction from entry type: income "+₹", others "−₹", zero "₹0".
  static String signed(double v, TxType type) {
    if (v == 0) return _abs(0);
    return type == TxType.income ? '+${_abs(v)}' : '−${_abs(v)}';
  }
}

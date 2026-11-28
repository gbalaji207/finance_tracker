import 'package:finance_tracker/core/models/tx_type.dart';

/// Parses text such as `32,000.50` or `₹ 1,200`. Null when empty or not a
/// number. Rounded to 2 decimals.
double? parseAmount(String text) {
  final cleaned = text.replaceAll(RegExp(r'[,\s₹]'), '');
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null || value.isNaN || value.isInfinite) return null;
  return (value * 100).round() / 100;
}

/// The first problem with an entry form, or null when it is valid.
String? validateEntry({
  required String amountText,
  required String sourceId,
  required TxType type,
  required String? categoryId,
}) {
  if (sourceId.isEmpty) return 'Select a source.';
  if (type != TxType.income && categoryId == null) return 'Select a category.';
  final amount = parseAmount(amountText);
  if (amount == null || amount <= 0) return 'Enter an amount above zero.';
  return null;
}

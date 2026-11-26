import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/tx_type.dart';

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.date,
    required this.type,
    required this.sourceId,
    this.categoryId,
    required this.amount,
    required this.description,
  });

  final String id;
  final DateTime date;
  final TxType type;
  final String sourceId;
  final String? categoryId;

  /// Positive rupees; direction comes from [type].
  final double amount;
  final String description;

  @override
  List<Object?> get props =>
      [id, date, type, sourceId, categoryId, amount, description];
}

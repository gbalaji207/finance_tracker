import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/tx_type.dart';

/// The values needed to create or change an entry.
class EntryInput extends Equatable {
  const EntryInput({
    required this.date,
    required this.type,
    required this.sourceId,
    this.categoryId,
    required this.amount,
    this.description = '',
  });

  final DateTime date;
  final TxType type;
  final String sourceId;

  /// Null for income.
  final String? categoryId;

  /// Above zero.
  final double amount;
  final String description;

  @override
  List<Object?> get props => [
    date,
    type,
    sourceId,
    categoryId,
    amount,
    description,
  ];
}

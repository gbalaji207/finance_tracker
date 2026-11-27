import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/tx_type.dart';

class EntryTemplate extends Equatable {
  const EntryTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.sourceId,
    this.categoryId,
    this.amount,
    required this.description,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final TxType type;
  final String sourceId;
  final String? categoryId;
  final double? amount;
  final String description;

  /// Position in the list; new templates go after the largest one.
  final int sortOrder;

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    sourceId,
    categoryId,
    amount,
    description,
    sortOrder,
  ];
}

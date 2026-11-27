import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/tx_type.dart';

/// The values needed to create a template.
class TemplateInput extends Equatable {
  const TemplateInput({
    required this.name,
    required this.type,
    required this.sourceId,
    this.categoryId,
    this.amount,
    this.description = '',
    this.quickAdd = false,
    required this.sortOrder,
  });

  final String name;
  final TxType type;
  final String sourceId;

  /// Null for income.
  final String? categoryId;

  /// Null means ask each time.
  final double? amount;
  final String description;
  final bool quickAdd;

  /// The largest existing sort order plus one.
  final int sortOrder;

  @override
  List<Object?> get props => [
    name,
    type,
    sourceId,
    categoryId,
    amount,
    description,
    quickAdd,
    sortOrder,
  ];
}

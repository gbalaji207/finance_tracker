import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/tx_type.dart';

/// The values needed to create a category.
class CategoryInput extends Equatable {
  const CategoryInput({required this.name, required this.kind});

  final String name;

  /// expense, investment or savings; never income.
  final TxType kind;

  @override
  List<Object?> get props => [name, kind];
}

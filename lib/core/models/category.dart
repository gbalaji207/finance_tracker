import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/tx_type.dart';

class Category extends Equatable {
  const Category({required this.id, required this.name, required this.kind});

  final String id;
  final String name;

  /// expense, investment or savings.
  final TxType kind;

  @override
  List<Object?> get props => [id, name, kind];
}

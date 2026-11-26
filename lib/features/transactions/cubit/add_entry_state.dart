import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/data/mock_clock.dart';
import 'package:finance_tracker/core/models/tx_type.dart';

class AddEntryState extends Equatable {
  AddEntryState({
    this.type = TxType.expense,
    this.sourceId = 'salary',
    this.categoryId = 'groceries',
    DateTime? date,
  }) : date = date ?? mockToday;

  final TxType type;
  final String sourceId;

  /// Null for income entries.
  final String? categoryId;
  final DateTime date;

  /// `categoryId` is nullable and null is meaningful (income), so it is always
  /// passed explicitly instead of falling back to the current value.
  AddEntryState copyWith({
    TxType? type,
    String? sourceId,
    String? categoryId,
    bool clearCategory = false,
    DateTime? date,
  }) =>
      AddEntryState(
        type: type ?? this.type,
        sourceId: sourceId ?? this.sourceId,
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
        date: date ?? this.date,
      );

  @override
  List<Object?> get props => [type, sourceId, categoryId, date];
}

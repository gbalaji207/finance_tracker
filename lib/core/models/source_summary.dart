import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/source.dart';

class SourceSummary extends Equatable {
  const SourceSummary({
    required this.source,
    required this.income,
    required this.expense,
    required this.invested,
    required this.saved,
    required this.closing,
    required this.investedSavedToDate,
    this.monthOpening,
  });

  final Source source;
  final double income;
  final double expense;
  final double invested;
  final double saved;
  final double closing;
  final double investedSavedToDate;

  /// Balance at the start of the month (from the database).
  final double? monthOpening;

  double get opening => monthOpening ?? source.openingBalance;

  @override
  List<Object?> get props => [
    source,
    income,
    expense,
    invested,
    saved,
    closing,
    investedSavedToDate,
    monthOpening,
  ];
}

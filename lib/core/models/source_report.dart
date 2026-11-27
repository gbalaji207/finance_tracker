import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/source.dart';

class SourceMonthRow extends Equatable {
  const SourceMonthRow({
    required this.month,
    required this.income,
    required this.expense,
    required this.investedSaved,
    required this.closing,
    this.partner = 0,
  });

  final DateTime month;
  final double income;
  final double expense;
  final double investedSaved;
  final double closing;

  /// Sent to the partner in this month.
  final double partner;

  @override
  List<Object?> get props => [
    month,
    income,
    expense,
    investedSaved,
    closing,
    partner,
  ];
}

class SourceReport extends Equatable {
  const SourceReport({
    required this.source,
    required this.balanceToday,
    required this.incomeThisMonth,
    required this.expenseThisMonth,
    required this.investedSavedToDate,
    required this.months,
    this.partnerThisMonth = 0,
  });

  final Source source;
  final double balanceToday;
  final double incomeThisMonth;
  final double expenseThisMonth;
  final double investedSavedToDate;
  final double partnerThisMonth;

  /// Newest first.
  final List<SourceMonthRow> months;

  @override
  List<Object?> get props => [
    source,
    balanceToday,
    incomeThisMonth,
    expenseThisMonth,
    investedSavedToDate,
    partnerThisMonth,
    months,
  ];
}

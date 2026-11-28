import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/tx_type.dart';

/// One entry of the Accounts report, with the running balance after it.
class LedgerRow extends Equatable {
  const LedgerRow({
    required this.id,
    required this.date,
    required this.description,
    required this.type,
    required this.sourceId,
    required this.amount,
    required this.closing,
  });

  final String id;
  final DateTime date;
  final String description;
  final TxType type;
  final String sourceId;

  /// Always positive; the direction comes from [type].
  final double amount;

  /// The running balance after this row.
  final double closing;

  /// An income entry is a credit.
  double get credit => type == TxType.income ? amount : 0;

  /// Every other type (expense, investment, savings, partner) is a debit.
  double get debit => type == TxType.income ? 0 : amount;

  @override
  List<Object?> get props => [
    id,
    date,
    description,
    type,
    sourceId,
    amount,
    closing,
  ];
}

/// One page of the Accounts report plus the figures for the whole range.
class AccountLedger extends Equatable {
  const AccountLedger({
    required this.rows,
    required this.total,
    required this.page,
    required this.pageCount,
    required this.opening,
    required this.totalCredit,
    required this.totalDebit,
  });

  /// One page, newest first.
  final List<LedgerRow> rows;

  /// Rows in the whole filtered range.
  final int total;
  final int page;
  final int pageCount;

  /// The balance of the chosen sources just before the From date.
  final double opening;

  /// Over the whole filtered range, not only this page.
  final double totalCredit;
  final double totalDebit;

  double get closing => opening + totalCredit - totalDebit;

  @override
  List<Object?> get props => [
    rows,
    total,
    page,
    pageCount,
    opening,
    totalCredit,
    totalDebit,
  ];
}

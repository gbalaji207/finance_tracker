import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/transaction.dart';

class TransactionPage extends Equatable {
  const TransactionPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageCount,
  });

  final List<Transaction> items;
  final int total;
  final int page;
  final int pageCount;

  @override
  List<Object?> get props => [items, total, page, pageCount];
}

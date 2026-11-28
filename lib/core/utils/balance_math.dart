import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/models/tx_type.dart';

abstract final class BalanceMath {
  /// Balance of a source after the given entry is deleted.
  /// Income was added to the balance, so deleting it subtracts; every other
  /// type (expense, investment, savings) was subtracted, so deleting it adds.
  static double afterDeleting(Transaction entry, double balance) =>
      entry.type == TxType.income
      ? balance - entry.amount
      : balance + entry.amount;
}

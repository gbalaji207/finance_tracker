import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/utils/balance_math.dart';
import 'package:flutter_test/flutter_test.dart';

Transaction entry(TxType type, double amount) => Transaction(
      id: 'x',
      date: DateTime(2026, 11, 1),
      type: type,
      sourceId: 'salary',
      amount: amount,
      description: '',
    );

void main() {
  group('BalanceMath.afterDeleting', () {
    test('deleting an expense adds it back', () {
      expect(BalanceMath.afterDeleting(entry(TxType.expense, 32000), 53200), 85200);
    });
    test('deleting an investment adds it back', () {
      expect(BalanceMath.afterDeleting(entry(TxType.investment, 20000), 53200), 73200);
    });
    test('deleting income subtracts it, even below zero', () {
      expect(BalanceMath.afterDeleting(entry(TxType.income, 45000), 31000), -14000);
    });
    test('deleting a partner transfer adds it back', () {
      expect(BalanceMath.afterDeleting(entry(TxType.partner, 8000), 45200), 53200);
    });
    test('deleting savings adds it back', () {
      expect(BalanceMath.afterDeleting(entry(TxType.savings, 10000), 1000), 11000);
    });
  });
}

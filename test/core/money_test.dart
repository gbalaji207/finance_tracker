import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money.plain', () {
    test('uses Indian grouping', () {
      expect(Money.plain(132400), '₹1,32,400');
      expect(Money.plain(15000), '₹15,000');
    });
    test('formats zero', () => expect(Money.plain(0), '₹0'));
    test('uses a real minus sign for negatives',
        () => expect(Money.plain(-1000), '−₹1,000'));
  });

  group('Money.signed', () {
    test('income is positive',
        () => expect(Money.signed(45000, TxType.income), '+₹45,000'));
    test('non-income is negative',
        () => expect(Money.signed(32000, TxType.expense), '−₹32,000'));
    test('zero has no sign',
        () => expect(Money.signed(0, TxType.savings), '₹0'));
  });
}

import 'package:finance_tracker/core/models/bank_account.dart';
import 'package:finance_tracker/core/models/bank_reconciliation.dart';
import 'package:flutter_test/flutter_test.dart';

BankAccountReconciliation _row(String id, double sources, double? bank) =>
    BankAccountReconciliation(
      account: BankAccount(id: id, name: id),
      sourcesTotal: sources,
      bankBalance: bank,
      asOf: bank == null ? null : DateTime(2026, 11, 26),
    );

void main() {
  test('two accounts that both match', () {
    final rec = BankReconciliation([
      _row('a', 75600, 75600),
      _row('b', 56800, 56800),
    ]);
    expect(rec.allMatch, isTrue);
    expect(rec.bankTotal, 132400);
    expect(rec.sourcesTotal, 132400);
    expect(rec.offCount, 0);
    expect(rec.missingCount, 0);
  });

  test('one account off by 400', () {
    final rec = BankReconciliation([
      _row('a', 75600, 75200),
      _row('b', 56800, 56800),
    ]);
    expect(rec.offCount, 1);
    expect(rec.offAmount, 400);
    expect(rec.allMatch, isFalse);
  });

  test('an account with no bank balance', () {
    final rec = BankReconciliation([
      _row('a', 75600, 75600),
      _row('b', 56800, null),
    ]);
    expect(rec.missingCount, 1);
    expect(rec.allMatch, isFalse);
    expect(rec.bankTotal, 75600);
  });

  test('no accounts never counts as matching', () {
    expect(const BankReconciliation([]).allMatch, isFalse);
  });
}

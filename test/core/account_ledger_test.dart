import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/data/mock_finance_repository.dart';
import 'package:finance_tracker/core/models/account_ledger.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final from = DateTime(2026, 11);
  final to = DateTime(2026, 11, 30);

  Future<AccountLedger> ledger({
    DateTime? start,
    DateTime? end,
    String? bankAccountId,
    String? sourceId,
    TxType? type,
  }) => MockFinanceRepository().accountLedger(
    from: start ?? from,
    to: end ?? to,
    bankAccountId: bankAccountId,
    sourceId: sourceId,
    type: type,
  );

  test('all sources and types: totals, order and closing', () async {
    final l = await ledger();
    expect(l.total, 10);
    expect(l.rows, hasLength(10));
    expect(l.pageCount, 1);
    expect(l.opening, 33000);
    expect(l.totalCredit, 228000);
    expect(l.totalDebit, 72200);
    expect(l.closing, 188800);
    // Newest first: the 25 Nov entries, ending with the 5 Nov salary.
    expect(l.rows.first.date, DateTime(2026, 11, 25));
    expect(l.rows.last.id, 't10');
    expect(l.rows.first.closing, 188800);
  });

  test('closing runs oldest to newest', () async {
    final l = await ledger();
    // t10: salary credited 120000 on top of the 33000 opening.
    expect(l.rows.last.closing, 153000);
    for (var i = 0; i < l.rows.length - 1; i++) {
      final newer = l.rows[i];
      final older = l.rows[i + 1];
      expect(
        newer.closing,
        older.closing + newer.credit - newer.debit,
        reason: newer.id,
      );
    }
  });

  test('one source only', () async {
    final l = await ledger(sourceId: 'salary');
    expect(l.opening, 15000);
    expect(l.rows.map((r) => r.id).toSet(), {'t1', 't2', 't3', 't10'});
  });

  test('one bank account only', () async {
    final hdfc = await ledger(bankAccountId: 'hdfc-salary');
    // Salary 15000 + Side hustle 6000 + Old freelance 0.
    expect(hdfc.opening, 21000);
    expect(hdfc.rows.map((r) => r.id).toSet(), {'t1', 't2', 't3', 't7', 't10'});
    expect(hdfc.totalCredit, 155000);
    expect(hdfc.totalDebit, 56200);
    expect(hdfc.closing, 119800);

    final sbi = await ledger(bankAccountId: 'sbi-rentals');
    // Aqua 105 8000 + VR 4000.
    expect(sbi.opening, 12000);
    expect(sbi.rows.map((r) => r.id).toSet(), {'t4', 't5', 't6', 't8', 't9'});
    expect(sbi.totalCredit, 73000);
    expect(sbi.totalDebit, 16000);
    expect(sbi.closing, 69000);

    // The two accounts add up to the whole.
    expect(hdfc.closing + sbi.closing, 188800);
  });

  test('a source outside the chosen bank account gives nothing', () async {
    final l = await ledger(bankAccountId: 'sbi-rentals', sourceId: 'salary');
    expect(l.rows, isEmpty);
    expect(l.opening, 0);
  });

  test(
    'a type filter keeps the opening and runs over the shown rows',
    () async {
      final l = await ledger(type: TxType.income);
      expect(l.totalDebit, 0);
      expect(l.opening, 33000);
      expect(l.rows.every((r) => r.debit == 0 && r.credit > 0), isTrue);
      expect(l.rows.last.closing, 33000 + 120000);
      expect(l.rows.first.closing, 33000 + 228000);
    },
  );

  test('the date range limits the rows', () async {
    final early = await ledger(end: DateTime(2026, 11, 10));
    expect(early.rows.map((r) => r.id), ['t10']);
    final october = await ledger(
      start: DateTime(2026, 10),
      end: DateTime(2026, 10, 31),
    );
    expect(october.rows, isEmpty);
    expect(october.total, 0);
    expect(october.pageCount, 1);
    expect(october.opening, 33000);
    expect(october.closing, 33000);
  });

  test('credit and debit follow the type', () async {
    final l = await ledger();
    final byId = {for (final r in l.rows) r.id: r};
    expect(byId['t10']!.type, TxType.income);
    expect(byId['t10']!.credit, 120000);
    expect(byId['t10']!.debit, 0);
    expect(byId['t1']!.type, TxType.expense);
    expect(byId['t1']!.debit, 32000);
    expect(byId['t1']!.credit, 0);
  });

  test('rows are paged by kLedgerPageSize', () async {
    final l = await ledger();
    expect(l.rows.length, lessThanOrEqualTo(kLedgerPageSize));
  });
}

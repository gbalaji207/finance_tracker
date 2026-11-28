import 'package:finance_tracker/core/data/supabase/row_mappers.dart';
import 'package:finance_tracker/core/models/monthly_report.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sourceFromRow maps numbers given as int, double or string', () {
    for (final v in <Object>[6000, 6000.0, '6000.00']) {
      final s = sourceFromRow({
        'id': 'a',
        'name': 'Aqua 105',
        'kind': 'Rental',
        'opening_balance': v,
        'is_active': true,
        'opening_date': '2026-06-01',
      });
      expect(s.openingBalance, 6000);
      expect(s.openingDate, DateTime(2026, 6, 1));
      expect(s.isActive, isTrue);
    }
  });

  test('sourceFromRow allows a missing opening date', () {
    final s = sourceFromRow({
      'id': 'a',
      'name': 'x',
      'kind': 'Other',
      'opening_balance': '0',
      'is_active': false,
      'opening_date': null,
    });
    expect(s.openingDate, isNull);
    expect(s.isActive, isFalse);
  });

  test('categoryFromRow reads the kind by name', () {
    final c = categoryFromRow({
      'id': 'c',
      'name': 'Mutual funds',
      'kind': 'investment',
      'is_active': true,
    });
    expect(c.kind, TxType.investment);
  });

  test('categoryUsageFromRow accepts the count as int or string', () {
    for (final v in <Object>[7, '7']) {
      final u = categoryUsageFromRow({
        'category_id': 'c',
        'name': 'Groceries',
        'kind': 'expense',
        'is_active': true,
        'entry_count': v,
      });
      expect(u.entryCount, 7);
      expect(u.category.name, 'Groceries');
    }
  });

  test('templateFromRow handles a null amount and an income template', () {
    final t = templateFromRow({
      'id': 't',
      'name': 'Internet bill',
      'type': 'expense',
      'source_id': 's',
      'category_id': 'c',
      'amount': null,
      'description': null,
    });
    expect(t.amount, isNull);
    expect(t.description, '');
    final income = templateFromRow({
      'id': 't2',
      'name': 'Rent received',
      'type': 'income',
      'source_id': 's',
      'category_id': null,
      'amount': '45000.00',
      'description': 'Rent',
    });
    expect(income.categoryId, isNull);
    expect(income.amount, 45000);
  });

  test('transactionFromRow maps an income row with no category', () {
    final t = transactionFromRow({
      'id': 'x',
      'tx_date': '2026-11-22',
      'type': 'income',
      'source_id': 's',
      'category_id': null,
      'amount': '32000.00',
      'description': 'Rent received',
    });
    expect(t.date, DateTime(2026, 11, 22));
    expect(t.categoryId, isNull);
    expect(t.amount, 32000);
    expect(t.type, TxType.income);
  });

  test('sourceSummaryFromRow reads strings and uses month_opening', () {
    final s = sourceSummaryFromRow({
      'source_id': 'a',
      'name': 'Salary',
      'kind': 'Employment',
      'opening_balance': '2000.00',
      'is_active': true,
      'month_opening': '15000.00',
      'income': '120000.00',
      'expense': '55800.00',
      'invested': '20000.00',
      'saved': '6000.00',
      'closing': '53200.00',
      'invested_saved_to_date': '76000.00',
    });
    expect(s.opening, 15000);
    expect(s.source.openingBalance, 2000);
    expect(s.closing, 53200);
    expect(s.investedSavedToDate, 76000);
  });

  test('sourceMonthRowFromRow maps a source_month_rows row', () {
    final r = sourceMonthRowFromRow({
      'month': '2026-11-01',
      'income': '45000.00',
      'expense': 12000,
      'invested_saved': '10000.00',
      'closing': 31000.0,
    });
    expect(r.month, DateTime(2026, 11, 1));
    expect(r.income, 45000);
    expect(r.expense, 12000);
    expect(r.investedSaved, 10000);
    expect(r.closing, 31000);
  });

  test('MonthlyReport with income 0 has a savings rate of 0', () {
    const report = MonthlyReport(bySource: [], expenseByCategory: []);
    expect(report.savingsRate, 0);
  });

  test('bankAccountFromRow maps an account row', () {
    final a = bankAccountFromRow({
      'id': 'a1',
      'name': 'HDFC Salary',
      'is_active': true,
    });
    expect(a.id, 'a1');
    expect(a.name, 'HDFC Salary');
    expect(a.isActive, isTrue);
  });

  test('bankAccountUsageFromRow accepts the count as a string', () {
    final u = bankAccountUsageFromRow({
      'bank_account_id': 'a1',
      'name': 'SBI Rentals',
      'is_active': false,
      'active_source_count': '2',
    });
    expect(u.account.name, 'SBI Rentals');
    expect(u.account.isActive, isFalse);
    expect(u.activeSourceCount, 2);
  });

  test('bankAccountReconciliationFromRow handles a missing balance', () {
    final unset = bankAccountReconciliationFromRow({
      'bank_account_id': 'a1',
      'name': 'HDFC Salary',
      'is_active': true,
      'sources_total': '0.00',
      'bank_balance': null,
      'as_of': null,
    });
    expect(unset.isSet, isFalse);
    expect(unset.asOf, isNull);
    final set = bankAccountReconciliationFromRow({
      'bank_account_id': 'a1',
      'name': 'HDFC Salary',
      'is_active': true,
      'sources_total': '75600.00',
      'bank_balance': '75600.00',
      'as_of': '2026-11-26',
    });
    expect(set.isSet, isTrue);
    expect(set.asOf, DateTime(2026, 11, 26));
    expect(set.matches, isTrue);
  });

  test('sourceFromRow reads the account, embedded or not', () {
    final base = {
      'id': 's',
      'name': 'Salary',
      'kind': 'Employment',
      'opening_balance': '2000.00',
      'is_active': true,
      'opening_date': '2026-10-01',
      'bank_account_id': 'a1',
    };
    final withName = sourceFromRow({
      ...base,
      'bank_accounts': {'name': 'HDFC Salary'},
    });
    expect(withName.bankAccountId, 'a1');
    expect(withName.bankAccountName, 'HDFC Salary');
    final without = sourceFromRow(base);
    expect(without.bankAccountId, 'a1');
    expect(without.bankAccountName, isNull);
  });

  test('sourceSummaryFromRow reads the two account fields', () {
    final s = sourceSummaryFromRow({
      'source_id': 'a',
      'name': 'Salary',
      'kind': 'Employment',
      'opening_balance': '2000.00',
      'is_active': true,
      'month_opening': '15000.00',
      'income': '0',
      'expense': '0',
      'invested': '0',
      'saved': '0',
      'closing': '15000.00',
      'invested_saved_to_date': '0',
      'bank_account_id': 'a1',
      'bank_account_name': 'HDFC Salary',
    });
    expect(s.source.bankAccountId, 'a1');
    expect(s.source.bankAccountName, 'HDFC Salary');
  });

  group('ledger', () {
    Map<String, dynamic> row(String type, Object amount, Object closing) => {
      'entry_id': 'e1',
      'entry_date': '2026-11-25',
      'description': 'Home EMI',
      'entry_type': type,
      'source_id': 's1',
      'amount': amount,
      'closing': closing,
    };

    test('ledgerRowFromRow reads numbers given as strings or numbers', () {
      final fromStrings = ledgerRowFromRow(
        row('expense', '32000.00', '1500.50'),
      );
      expect(fromStrings.amount, 32000);
      expect(fromStrings.closing, 1500.5);
      expect(fromStrings.date, DateTime(2026, 11, 25));
      final fromNumbers = ledgerRowFromRow(row('expense', 32000, -200.0));
      expect(fromNumbers.closing, -200);
    });

    test('an income row is a credit', () {
      final r = ledgerRowFromRow(row('income', '45000.00', '1'));
      expect(r.credit, 45000);
      expect(r.debit, 0);
    });

    test('a partner row is a debit', () {
      final r = ledgerRowFromRow(row('partner', '8000.00', '1'));
      expect(r.type, TxType.partner);
      expect(r.debit, 8000);
      expect(r.credit, 0);
    });
  });

  group('partner', () {
    final summaryRow = {
      'source_id': 'a',
      'name': 'Salary',
      'kind': 'Employment',
      'opening_balance': '2000.00',
      'is_active': true,
      'month_opening': '15000.00',
      'income': '120000.00',
      'expense': '47800.00',
      'invested': '20000.00',
      'saved': '6000.00',
      'closing': '53200.00',
      'invested_saved_to_date': '76000.00',
    };

    test('sourceSummaryFromRow reads partner as a string', () {
      final s = sourceSummaryFromRow({...summaryRow, 'partner': '8000.00'});
      expect(s.partner, 8000);
    });

    test('sourceSummaryFromRow treats a missing partner as 0', () {
      expect(sourceSummaryFromRow(summaryRow).partner, 0);
    });

    test('sourceMonthRowFromRow reads partner', () {
      final r = sourceMonthRowFromRow({
        'month': '2026-09-01',
        'income': '45000.00',
        'expense': '6000.00',
        'invested_saved': '30000.00',
        'partner': '5000.00',
        'closing': '13500.00',
      });
      expect(r.partner, 5000);
    });

    test('a partner category and a partner entry map by name', () {
      final c = categoryFromRow({
        'id': 'c1',
        'name': 'Day-to-day',
        'kind': 'partner',
        'is_active': true,
      });
      expect(c.kind, TxType.partner);
      final t = transactionFromRow({
        'id': 't1',
        'tx_date': '2026-11-10',
        'type': 'partner',
        'source_id': 's1',
        'category_id': 'c1',
        'amount': '1000.00',
        'description': '',
      });
      expect(t.type, TxType.partner);
    });
  });
}

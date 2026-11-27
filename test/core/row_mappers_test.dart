import 'package:finance_tracker/core/data/supabase/row_mappers.dart';
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

  test('reconciliationFromRow maps a missing bank balance to nulls', () {
    final r = reconciliationFromRow({
      'sources_total': '132400.00',
      'bank_balance': null,
      'as_of': null,
    });
    expect(r.sourcesTotal, 132400);
    expect(r.bankBalance, isNull);
    expect(r.asOf, isNull);
    expect(r.difference, isNull);
  });
}

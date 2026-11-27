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
}

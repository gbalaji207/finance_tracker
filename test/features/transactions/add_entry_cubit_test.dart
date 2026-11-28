import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/features/transactions/cubit/add_entry_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sources = [
    Source(id: 's1', name: 'Salary', kind: 'Employment', openingBalance: 0),
    Source(id: 's2', name: 'VR', kind: 'Rental', openingBalance: 0),
  ];
  const categories = [
    Category(id: 'c1', name: 'Housing', kind: TxType.expense),
    Category(id: 'c2', name: 'Mutual funds', kind: TxType.investment),
  ];

  AddEntryCubit cubit() =>
      AddEntryCubit(categories: categories, sources: sources);

  test('a new form has no source and no category chosen', () {
    final c = cubit();
    expect(c.state.type, TxType.expense);
    expect(c.state.sourceId, isEmpty);
    expect(c.state.categoryId, isNull);
  });

  test('changing the type clears the category instead of picking one', () {
    final c = cubit()..selectCategory('c1');
    expect(c.state.categoryId, 'c1');
    c.selectType(TxType.investment);
    expect(c.state.type, TxType.investment);
    expect(c.state.categoryId, isNull);
  });

  test('reset returns to the empty form', () {
    final c = cubit()
      ..selectSource('s2')
      ..selectCategory('c1');
    c.reset();
    expect(c.state.sourceId, isEmpty);
    expect(c.state.categoryId, isNull);
  });

  test('a template fills its source and category, and nothing is guessed', () {
    final c = cubit();
    c.applyTemplate(
      const EntryTemplate(
        id: 'tp',
        name: 'Home EMI',
        type: TxType.expense,
        sourceId: 's1',
        categoryId: 'c1',
        amount: 32000,
        description: '',
      ),
    );
    expect(c.state.sourceId, 's1');
    expect(c.state.categoryId, 'c1');

    // A template without a category leaves the category to be chosen.
    c.applyTemplate(
      const EntryTemplate(
        id: 'tp2',
        name: 'Misc',
        type: TxType.investment,
        sourceId: 's2',
        amount: null,
        description: '',
      ),
    );
    expect(c.state.type, TxType.investment);
    expect(c.state.categoryId, isNull);
  });

  test('editing an entry fills the form from it', () {
    final c = cubit();
    c.startEdit(
      Transaction(
        id: 't1',
        date: DateTime(2026, 11, 25),
        type: TxType.expense,
        sourceId: 's1',
        categoryId: 'c1',
        amount: 32000,
        description: 'Home EMI',
      ),
    );
    expect(c.state.sourceId, 's1');
    expect(c.state.categoryId, 'c1');
    expect(c.state.editingId, 't1');
  });
}

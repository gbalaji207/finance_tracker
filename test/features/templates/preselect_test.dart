import 'package:finance_tracker/core/data/mock_finance_repository.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/features/templates/cubit/preselect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = MockFinanceRepository();

  test(
    'the recurring October entries are preselected, not the electricity bill',
    () async {
      final templates = await repo.templates();
      final entries = await repo.previousMonthEntries(DateTime(2026, 10));
      expect(preselectedIds(entries, templates), {
        'o1',
        'o2',
        'o3',
        'o4',
        'o6',
      });
    },
  );

  test(
    'an entry whose source differs from the template is not selected',
    () async {
      final templates = await repo.templates();
      final entries = await repo.previousMonthEntries(DateTime(2026, 10));
      final other = Transaction(
        id: 'x',
        date: entries.first.date,
        type: entries.first.type,
        sourceId: 'vr', // the Home EMI template uses salary
        amount: entries.first.amount,
        description: entries.first.description,
      );
      expect(preselectedIds([other], templates), isEmpty);
    },
  );
}

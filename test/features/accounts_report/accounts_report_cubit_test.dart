import 'package:finance_tracker/core/data/mock_finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/features/accounts_report/cubit/accounts_report_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<AccountsReportCubit> loaded() async {
    final cubit = AccountsReportCubit(MockFinanceRepository());
    await cubit.load();
    return cubit;
  }

  /// Waits until the list has finished reloading.
  Future<void> settle(AccountsReportCubit cubit) async {
    while (cubit.state.listLoading) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('the default range is the mock month and the ledger loads', () async {
    final cubit = await loaded();
    expect(cubit.state.status, LoadStatus.loaded);
    expect(cubit.state.from, DateTime(2026, 11));
    expect(cubit.state.to, DateTime(2026, 11, 30));
    expect(cubit.state.ledger!.rows, hasLength(10));
    await cubit.close();
  });

  test('a type filter leaves only credits for income', () async {
    final cubit = await loaded();
    cubit.setTypeFilter(TxType.income);
    await settle(cubit);
    final rows = cubit.state.ledger!.rows;
    expect(rows, isNotEmpty);
    expect(rows.every((r) => r.credit > 0 && r.debit == 0), isTrue);
    cubit.setTypeFilter(null);
    await settle(cubit);
    expect(cubit.state.typeFilter, isNull);
    expect(cubit.state.ledger!.rows, hasLength(10));
    await cubit.close();
  });

  test('a source filter leaves that source only', () async {
    final cubit = await loaded();
    cubit.setSourceFilter('salary');
    await settle(cubit);
    expect(cubit.state.ledger!.rows, hasLength(4));
    await cubit.close();
  });

  test('a bank account filter limits the sources and the rows', () async {
    final cubit = await loaded();
    expect(cubit.state.bankAccounts.map((a) => a.id), [
      'hdfc-salary',
      'sbi-rentals',
    ]);
    cubit.setBankAccountFilter('sbi-rentals');
    await settle(cubit);
    expect(cubit.state.ledger!.rows, hasLength(5));
    expect(cubit.state.ledger!.opening, 12000);
    expect(cubit.state.sourcesForFilter.map((s) => s.id), ['aqua-105', 'vr']);
    cubit.setBankAccountFilter(null);
    await settle(cubit);
    expect(cubit.state.ledger!.rows, hasLength(10));
    await cubit.close();
  });

  test('choosing another account clears a source that is not in it', () async {
    final cubit = await loaded();
    cubit.setSourceFilter('salary');
    await settle(cubit);
    cubit.setBankAccountFilter('sbi-rentals');
    await settle(cubit);
    expect(cubit.state.sourceFilter, isNull);
    expect(cubit.state.ledger!.rows, hasLength(5));
    // A source that is in the account stays chosen.
    cubit.setSourceFilter('vr');
    await settle(cubit);
    cubit.setBankAccountFilter('sbi-rentals');
    await settle(cubit);
    expect(cubit.state.sourceFilter, 'vr');
    await cubit.close();
  });

  test('a range with no entries gives an empty ledger', () async {
    final cubit = await loaded();
    cubit.setRange(DateTime(2026, 10), DateTime(2026, 10, 31));
    await settle(cubit);
    expect(cubit.state.ledger!.rows, isEmpty);
    expect(cubit.state.from, DateTime(2026, 10));
    await cubit.close();
  });
}

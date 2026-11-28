import 'package:finance_tracker/core/data/mock_finance_repository.dart';
import 'package:finance_tracker/core/models/source_input.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = MockFinanceRepository();

  test('every source summary balances', () async {
    for (final s in await repo.sourceSummaries(DateTime(2026, 11))) {
      expect(
        s.closing,
        s.opening + s.income - s.expense - s.invested - s.saved - s.partner,
        reason: s.source.name,
      );
    }
  });

  test('closing balances match the reconciliation', () async {
    final summaries = await repo.sourceSummaries(DateTime(2026, 11));
    final total = summaries.fold<double>(0, (sum, s) => sum + s.closing);
    final rec = await repo.reconciliation();
    expect(total, 132400);
    expect(total, rec.sourcesTotal);
    expect(rec.allMatch, isTrue);
  });

  test('monthly report totals', () async {
    final report = await repo.monthlyReport(DateTime(2026, 11));
    expect(report.income, 228000);
    expect(report.expense, 74600);
    expect(report.invested, 30000);
    expect(report.saved, 16000);
    expect(report.partner, 8000);
    expect(report.opening, 33000);
    expect(report.closing, 132400);
    expect(report.savingsRate, closeTo(0.20, 0.005));
    final categoryTotal = report.expenseByCategory.fold<double>(
      0,
      (sum, c) => sum + c.amount,
    );
    expect(categoryTotal, 74600);
  });

  test(
    'partner category exists and Partner is not in the expense list',
    () async {
      final categories = await repo.categories();
      expect(categories, hasLength(8));
      final partner = categories.firstWhere(
        (c) => c.name == 'Partner allowance',
      );
      expect(partner.kind, TxType.partner);
      final report = await repo.monthlyReport(DateTime(2026, 11));
      expect(
        report.expenseByCategory.map((c) => c.name),
        isNot(contains('Partner allowance')),
      );
    },
  );

  test('transactions and recent entries', () async {
    final page = await repo.transactions();
    expect(page.items, hasLength(10));
    expect(page.total, 38);
    final recent = await repo.recentTransactions();
    expect(recent.map((t) => t.id).toList(), [
      't1',
      't3',
      't4',
      't6',
      't7',
      't8',
    ]);
  });

  test('quick add templates', () async {
    final quick = await repo.quickAddTemplates();
    expect(quick.map((t) => t.id).toList(), ['tp1', 'tp2', 'tp3', 'tp5']);
  });

  test('source report has six months, newest first', () async {
    final report = await repo.sourceReport('aqua-105');
    expect(report.months, hasLength(6));
    expect(report.months.first.month, DateTime(2026, 11));
    final sep = report.months.firstWhere((m) => m.month == DateTime(2026, 9));
    expect(sep.partner, 5000);
    expect(report.partnerThisMonth, 0);
  });

  test('sources() is active only; allSources() includes archived', () async {
    final active = await repo.sources();
    expect(active, hasLength(4));
    expect(active.every((s) => s.isActive), isTrue);
    final all = await repo.allSources();
    expect(all, hasLength(5));
    expect(all.last.id, 'old-freelance');
    expect(all.last.isActive, isFalse);
  });

  test('category usage counts', () async {
    final usage = await repo.categoryUsage();
    expect(usage, hasLength(8));
    expect(usage.fold<int>(0, (sum, u) => sum + u.entryCount), 85);
  });

  test('sourceBalance', () async {
    expect(await repo.sourceBalance('salary'), 53200);
    expect(await repo.sourceBalance('old-freelance'), 0);
  });

  group('bank accounts', () {
    test('there are two active accounts', () async {
      final fresh = MockFinanceRepository();
      expect((await fresh.bankAccounts()).map((a) => a.name), [
        'HDFC Salary',
        'SBI Rentals',
      ]);
      final usage = await fresh.bankAccountUsage();
      expect(usage.map((u) => u.activeSourceCount), [2, 2]);
    });

    test('the reconciliation lists each account', () async {
      final rec = await MockFinanceRepository().reconciliation();
      expect(rec.accounts, hasLength(2));
      expect(rec.accounts[0].account.name, 'HDFC Salary');
      expect(rec.accounts[0].sourcesTotal, 75600);
      expect(rec.accounts[0].bankBalance, 75600);
      expect(rec.accounts[1].account.name, 'SBI Rentals');
      expect(rec.accounts[1].sourcesTotal, 56800);
      expect(rec.accounts[1].bankBalance, 56800);
      expect(rec.sourcesTotal, 132400);
    });

    test('setBankBalance changes one account only', () async {
      final fresh = MockFinanceRepository();
      await fresh.setBankBalance('hdfc-salary', 75200, DateTime(2026, 11, 27));
      final rec = await fresh.reconciliation();
      expect(rec.accounts[0].difference, 400);
      expect(rec.accounts[1].matches, isTrue);
    });

    test(
      'an archived account with money stays in the reconciliation',
      () async {
        final fresh = MockFinanceRepository();
        await fresh.setBankAccountActive('sbi-rentals', false);
        expect(await fresh.bankAccounts(), hasLength(1));
        final rec = await fresh.reconciliation();
        expect(
          rec.accounts.map((a) => a.account.name),
          contains('SBI Rentals'),
        );
      },
    );

    test('sources carry their account', () async {
      final sources = await MockFinanceRepository().allSources();
      final byName = {for (final s in sources) s.name: s.bankAccountName};
      expect(byName['Salary'], 'HDFC Salary');
      expect(byName['Old freelance'], 'HDFC Salary');
      expect(byName['Aqua 105'], 'SBI Rentals');
      expect(byName['VR'], 'SBI Rentals');
    });
  });

  group('editing', () {
    SourceInput input(String account, {String name = 'Salary'}) => SourceInput(
      name: name,
      kind: 'Employment',
      openingBalance: 2000,
      openingDate: DateTime(2026, 10),
      bankAccountId: account,
    );

    test('renaming a source shows everywhere in sample mode', () async {
      final fresh = MockFinanceRepository();
      await fresh.updateSource('salary', input('hdfc-salary', name: 'Pay'));
      final sources = await fresh.allSources();
      expect(sources.map((s) => s.name), contains('Pay'));
      final summaries = await fresh.sourceSummaries(DateTime(2026, 11));
      expect(summaries.first.source.name, 'Pay');
      expect(summaries.first.closing, 53200);
    });

    test('moving a source moves its balance between accounts', () async {
      final fresh = MockFinanceRepository();
      await fresh.updateSource('salary', input('sbi-rentals'));
      final rec = await fresh.reconciliation();
      expect(rec.accounts[0].sourcesTotal, 75600 - 53200);
      expect(rec.accounts[1].sourcesTotal, 56800 + 53200);
      expect(rec.sourcesTotal, 132400);
      final salary = (await fresh.allSources()).firstWhere(
        (s) => s.id == 'salary',
      );
      expect(salary.bankAccountName, 'SBI Rentals');
    });

    test('an in-memory source can change its opening balance', () async {
      final fresh = MockFinanceRepository();
      await fresh.addSource(input('hdfc-salary', name: 'Extra'));
      final added = (await fresh.allSources()).firstWhere(
        (s) => s.name == 'Extra',
      );
      await fresh.updateSource(
        added.id,
        SourceInput(
          name: 'Extra',
          kind: 'Employment',
          openingBalance: 2500,
          openingDate: DateTime(2026, 10),
          bankAccountId: 'hdfc-salary',
        ),
      );
      final rec = await fresh.reconciliation();
      expect(rec.accounts[0].sourcesTotal, 75600 + 2500);
    });

    test('renaming a category keeps its kind and shows everywhere', () async {
      final fresh = MockFinanceRepository();
      await fresh.renameCategory('groceries', 'Food');
      final all = await fresh.allCategories();
      final renamed = all.firstWhere((c) => c.id == 'groceries');
      expect(renamed.name, 'Food');
      expect(renamed.kind, TxType.expense);
      expect((await fresh.categories()).map((c) => c.name), contains('Food'));
      final usage = await fresh.categoryUsage();
      expect(
        usage.firstWhere((u) => u.category.id == 'groceries').category.name,
        'Food',
      );
    });

    test('renaming an unknown category fails', () async {
      expect(
        MockFinanceRepository().renameCategory('nope', 'x'),
        throwsA(isA<StateError>()),
      );
    });

    test('renaming an account renames it on its sources', () async {
      final fresh = MockFinanceRepository();
      await fresh.renameBankAccount('sbi-rentals', 'SBI Property');
      expect(
        (await fresh.bankAccounts()).map((a) => a.name),
        contains('SBI Property'),
      );
      final aqua = (await fresh.allSources()).firstWhere(
        (s) => s.id == 'aqua-105',
      );
      expect(aqua.bankAccountName, 'SBI Property');
      expect(
        (await fresh.reconciliation()).accounts[1].account.name,
        'SBI Property',
      );
    });
  });
}

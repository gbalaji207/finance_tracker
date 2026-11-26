import 'package:finance_tracker/core/data/mock_finance_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repo = MockFinanceRepository();

  test('every source summary balances', () async {
    for (final s in await repo.sourceSummaries(DateTime(2026, 11))) {
      expect(
        s.closing,
        s.opening + s.income - s.expense - s.invested - s.saved,
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
    expect(rec.difference, 0);
  });

  test('monthly report totals', () async {
    final report = await repo.monthlyReport(DateTime(2026, 11));
    expect(report.income, 228000);
    expect(report.expense, 82600);
    expect(report.invested, 30000);
    expect(report.saved, 16000);
    expect(report.opening, 33000);
    expect(report.closing, 132400);
    expect(report.savingsRate, closeTo(0.20, 0.005));
    final categoryTotal =
        report.expenseByCategory.fold<double>(0, (sum, c) => sum + c.amount);
    expect(categoryTotal, 82600);
  });

  test('transactions and recent entries', () async {
    final page = await repo.transactions();
    expect(page.items, hasLength(10));
    expect(page.total, 38);
    final recent = await repo.recentTransactions();
    expect(
      recent.map((t) => t.id).toList(),
      ['t1', 't3', 't4', 't6', 't7', 't8'],
    );
  });

  test('quick add templates', () async {
    final quick = await repo.quickAddTemplates();
    expect(quick.map((t) => t.id).toList(), ['tp1', 'tp2', 'tp3', 'tp5']);
  });

  test('source report has six months, newest first', () async {
    final report = await repo.sourceReport('aqua-105');
    expect(report.months, hasLength(6));
    expect(report.months.first.month, DateTime(2026, 11));
  });
}

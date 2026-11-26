import 'package:finance_tracker/core/models/bank_reconciliation.dart';
import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/monthly_report.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/source_report.dart';
import 'package:finance_tracker/core/models/source_summary.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/models/transaction_page.dart';

abstract interface class FinanceRepository {
  Future<List<Source>> sources();
  Future<List<Category>> categories();
  Future<BankReconciliation> reconciliation();
  Future<List<SourceSummary>> sourceSummaries(DateTime month);
  Future<List<Transaction>> recentTransactions();
  Future<TransactionPage> transactions({int page = 1});
  Future<List<EntryTemplate>> templates();
  Future<List<EntryTemplate>> quickAddTemplates();
  Future<List<Transaction>> previousMonthEntries(DateTime month);
  Future<MonthlyReport> monthlyReport(DateTime month);
  Future<SourceReport> sourceReport(String sourceId);
}

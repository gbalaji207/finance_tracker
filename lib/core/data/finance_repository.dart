import 'package:finance_tracker/core/models/bank_account.dart';
import 'package:finance_tracker/core/models/bank_reconciliation.dart';
import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/category_input.dart';
import 'package:finance_tracker/core/models/category_usage.dart';
import 'package:finance_tracker/core/models/entry_input.dart';
import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/monthly_report.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/source_input.dart';
import 'package:finance_tracker/core/models/source_report.dart';
import 'package:finance_tracker/core/models/source_summary.dart';
import 'package:finance_tracker/core/models/template_input.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/models/transaction_page.dart';
import 'package:finance_tracker/core/models/tx_type.dart';

const kPageSize = 10;

abstract interface class FinanceRepository {
  /// Active sources only (these are the ones offered for new entries).
  Future<List<Source>> sources();

  /// Active and archived sources.
  Future<List<Source>> allSources();
  Future<List<Category>> categories();

  /// Active and archived categories.
  Future<List<Category>> allCategories();
  Future<List<CategoryUsage>> categoryUsage();

  /// Current closing balance of a source.
  Future<double> sourceBalance(String sourceId);

  /// Active bank accounts only: for forms.
  Future<List<BankAccount>> bankAccounts();

  /// Active and archived bank accounts.
  Future<List<BankAccount>> allBankAccounts();

  /// Every bank account with its number of active sources (Settings).
  Future<List<BankAccountUsage>> bankAccountUsage();

  /// One entry per bank account.
  Future<BankReconciliation> reconciliation();
  Future<List<SourceSummary>> sourceSummaries(DateTime month);
  Future<List<Transaction>> recentTransactions();
  Future<TransactionPage> transactions({
    DateTime? month, // null = all months
    String? sourceId,
    TxType? type,
    String query = '',
    int page = 1,
  });
  Future<List<EntryTemplate>> templates();
  Future<List<EntryTemplate>> quickAddTemplates();
  Future<List<Transaction>> previousMonthEntries(DateTime month);
  Future<MonthlyReport> monthlyReport(DateTime month);
  Future<SourceReport> sourceReport(String sourceId);

  Future<void> addEntry(EntryInput input);
  Future<void> updateEntry(String id, EntryInput input);
  Future<void> deleteEntry(String id);

  Future<void> addTemplate(TemplateInput input);

  /// Creates all entries in one request; nothing is created if it fails.
  Future<void> addEntries(List<EntryInput> inputs);

  /// One balance per account and date; saving again for the same account
  /// and date replaces it.
  Future<void> setBankBalance(
    String bankAccountId,
    double balance,
    DateTime asOf,
  );
  Future<void> addBankAccount(String name);
  Future<void> setBankAccountActive(String id, bool active);
  Future<void> addSource(SourceInput input);

  /// Changes a source: the same fields as when creating it.
  Future<void> updateSource(String id, SourceInput input);

  Future<void> renameBankAccount(String id, String name);
  Future<void> setSourceActive(String id, bool active);
  Future<void> addCategory(CategoryInput input);

  /// Renames a category. The kind cannot change: entries and templates are
  /// tied to it.
  Future<void> renameCategory(String id, String name);
  Future<void> setCategoryActive(String id, bool active);
}

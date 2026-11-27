import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/data/mock_clock.dart';
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

/// Hardcoded sample data for the first phase.
///
/// The `month`, `page` and `sourceId` arguments are ignored: every call
/// returns the same fixed data. The summaries and reports are hardcoded on
/// purpose and are NOT computed from the (sample) transaction lists.
class MockFinanceRepository implements FinanceRepository {
  MockFinanceRepository();

  // In-memory changes made in sample mode; they reset on reload.
  final List<BankAccount> _addedAccounts = [];
  final Map<String, bool> _accountActive = {};
  final Map<String, ({double balance, DateTime asOf})> _bankBalances = {
    'hdfc-salary': (balance: 75600, asOf: mockToday),
    'sbi-rentals': (balance: 56800, asOf: mockToday),
  };
  final Map<String, bool> _sourceActive = {};
  final Map<String, Source> _sourceEdits = {};
  final Map<String, String> _accountNames = {};
  final Map<String, bool> _categoryActive = {};
  final List<Source> _addedSources = [];
  final List<Category> _addedCategories = [];
  int _nextNewId = 1;

  /// The name of the account now (it may have been renamed in memory).
  String? _accountName(String? id) {
    if (id == null) return null;
    for (final a in [_hdfc, _sbi, ..._addedAccounts]) {
      if (a.id == id) return _accountNames[a.id] ?? a.name;
    }
    return null;
  }

  /// [s] with the in-memory edits applied: its own edit, its archived flag
  /// and the current name of its account.
  Source _sourceNow(Source s) {
    final base = _sourceEdits[s.id] ?? s;
    return Source(
      id: base.id,
      name: base.name,
      kind: base.kind,
      openingBalance: base.openingBalance,
      isActive: _sourceActive[s.id] ?? base.isActive,
      openingDate: base.openingDate,
      bankAccountId: base.bankAccountId,
      bankAccountName: _accountName(base.bankAccountId) ?? base.bankAccountName,
    );
  }

  /// The fixed sample summaries, carrying the edited source details.
  List<SourceSummary> get _summariesNow => [
    for (final m in _summaries)
      SourceSummary(
        source: _sourceNow(m.source),
        income: m.income,
        expense: m.expense,
        invested: m.invested,
        saved: m.saved,
        closing: m.closing,
        investedSavedToDate: m.investedSavedToDate,
        monthOpening: m.monthOpening,
        partner: m.partner,
      ),
  ];

  Category _categoryNow(Category c) => Category(
    id: c.id,
    name: c.name,
    kind: c.kind,
    isActive: _categoryActive[c.id] ?? c.isActive,
  );

  static const _hdfc = BankAccount(id: 'hdfc-salary', name: 'HDFC Salary');
  static const _sbi = BankAccount(id: 'sbi-rentals', name: 'SBI Rentals');

  BankAccount _accountNow(BankAccount a) => BankAccount(
    id: a.id,
    name: _accountNames[a.id] ?? a.name,
    isActive: _accountActive[a.id] ?? a.isActive,
  );

  List<BankAccount> get _currentAccounts => [
    for (final a in [_hdfc, _sbi, ..._addedAccounts]) _accountNow(a),
  ];

  List<Source> get _currentSources => [
    for (final s in [..._allSources, ..._addedSources]) _sourceNow(s),
  ];

  List<Category> get _currentCategories => [
    for (final c in [..._categories, ..._addedCategories]) _categoryNow(c),
  ];

  static const _salary = Source(
    id: 'salary',
    name: 'Salary',
    kind: 'Employment',
    openingBalance: 15000,
    bankAccountId: 'hdfc-salary',
    bankAccountName: 'HDFC Salary',
  );
  static const _sideHustle = Source(
    id: 'side-hustle',
    name: 'Side hustle',
    kind: 'Freelance',
    openingBalance: 6000,
    bankAccountId: 'hdfc-salary',
    bankAccountName: 'HDFC Salary',
  );
  static const _aqua105 = Source(
    id: 'aqua-105',
    name: 'Aqua 105',
    kind: 'Rental',
    openingBalance: 8000,
    bankAccountId: 'sbi-rentals',
    bankAccountName: 'SBI Rentals',
  );
  static const _vr = Source(
    id: 'vr',
    name: 'VR',
    kind: 'Rental',
    openingBalance: 4000,
    bankAccountId: 'sbi-rentals',
    bankAccountName: 'SBI Rentals',
  );

  static const _oldFreelance = Source(
    id: 'old-freelance',
    name: 'Old freelance',
    kind: 'Freelance',
    openingBalance: 0,
    isActive: false,
    bankAccountId: 'hdfc-salary',
    bankAccountName: 'HDFC Salary',
  );

  /// Active sources only; these are the ones offered for new entries.
  static const _sources = [_salary, _sideHustle, _aqua105, _vr];

  static const _allSources = [..._sources, _oldFreelance];

  static const _categoryUsage = [
    CategoryUsage(
      category: Category(id: 'housing', name: 'Housing', kind: TxType.expense),
      entryCount: 12,
    ),
    CategoryUsage(
      category: Category(
        id: 'groceries',
        name: 'Groceries',
        kind: TxType.expense,
      ),
      entryCount: 28,
    ),
    CategoryUsage(
      category: Category(
        id: 'utilities',
        name: 'Utilities',
        kind: TxType.expense,
      ),
      entryCount: 14,
    ),
    CategoryUsage(
      category: Category(
        id: 'property-upkeep',
        name: 'Property upkeep',
        kind: TxType.expense,
      ),
      entryCount: 6,
    ),
    CategoryUsage(
      category: Category(id: 'other', name: 'Other', kind: TxType.expense),
      entryCount: 9,
    ),
    CategoryUsage(
      category: Category(
        id: 'mutual-funds',
        name: 'Mutual funds',
        kind: TxType.investment,
      ),
      entryCount: 11,
    ),
    CategoryUsage(
      category: Category(
        id: 'fixed-deposit',
        name: 'Fixed deposit',
        kind: TxType.savings,
      ),
      entryCount: 5,
    ),
    CategoryUsage(
      category: Category(
        id: 'partner-allowance',
        name: 'Partner allowance',
        kind: TxType.partner,
      ),
      entryCount: 0,
    ),
  ];

  static const _categories = [
    Category(id: 'housing', name: 'Housing', kind: TxType.expense),
    Category(id: 'groceries', name: 'Groceries', kind: TxType.expense),
    Category(id: 'utilities', name: 'Utilities', kind: TxType.expense),
    Category(
      id: 'property-upkeep',
      name: 'Property upkeep',
      kind: TxType.expense,
    ),
    Category(id: 'other', name: 'Other', kind: TxType.expense),
    Category(id: 'mutual-funds', name: 'Mutual funds', kind: TxType.investment),
    Category(id: 'fixed-deposit', name: 'Fixed deposit', kind: TxType.savings),
    Category(
      id: 'partner-allowance',
      name: 'Partner allowance',
      kind: TxType.partner,
    ),
  ];

  static const _summaries = [
    SourceSummary(
      source: _salary,
      income: 120000,
      expense: 47800,
      invested: 20000,
      saved: 6000,
      partner: 8000,
      closing: 53200,
      investedSavedToDate: 410000,
      monthOpening: 15000,
    ),
    SourceSummary(
      source: _sideHustle,
      income: 35000,
      expense: 8600,
      invested: 10000,
      saved: 0,
      closing: 22400,
      investedSavedToDate: 60000,
      monthOpening: 6000,
    ),
    SourceSummary(
      source: _aqua105,
      income: 45000,
      expense: 12000,
      invested: 0,
      saved: 10000,
      closing: 31000,
      investedSavedToDate: 180000,
      monthOpening: 8000,
    ),
    SourceSummary(
      source: _vr,
      income: 28000,
      expense: 6200,
      invested: 0,
      saved: 0,
      closing: 25800,
      investedSavedToDate: 0,
      monthOpening: 4000,
    ),
  ];

  static final _transactions = <Transaction>[
    Transaction(
      id: 't1',
      date: DateTime(2026, 11, 25),
      type: TxType.expense,
      sourceId: 'salary',
      categoryId: 'housing',
      amount: 32000,
      description: 'Home EMI',
    ),
    Transaction(
      id: 't2',
      date: DateTime(2026, 11, 25),
      type: TxType.expense,
      sourceId: 'salary',
      categoryId: 'groceries',
      amount: 4200,
      description: 'Groceries',
    ),
    Transaction(
      id: 't3',
      date: DateTime(2026, 11, 24),
      type: TxType.investment,
      sourceId: 'salary',
      categoryId: 'mutual-funds',
      amount: 20000,
      description: 'SIP: index fund',
    ),
    Transaction(
      id: 't4',
      date: DateTime(2026, 11, 22),
      type: TxType.income,
      sourceId: 'aqua-105',
      amount: 45000,
      description: 'Rent received',
    ),
    Transaction(
      id: 't5',
      date: DateTime(2026, 11, 22),
      type: TxType.income,
      sourceId: 'vr',
      amount: 28000,
      description: 'Rent received',
    ),
    Transaction(
      id: 't6',
      date: DateTime(2026, 11, 20),
      type: TxType.expense,
      sourceId: 'vr',
      categoryId: 'utilities',
      amount: 2400,
      description: 'Electricity bill',
    ),
    Transaction(
      id: 't7',
      date: DateTime(2026, 11, 18),
      type: TxType.income,
      sourceId: 'side-hustle',
      amount: 35000,
      description: 'Client payout',
    ),
    Transaction(
      id: 't8',
      date: DateTime(2026, 11, 15),
      type: TxType.savings,
      sourceId: 'aqua-105',
      categoryId: 'fixed-deposit',
      amount: 10000,
      description: 'Recurring deposit',
    ),
    Transaction(
      id: 't9',
      date: DateTime(2026, 11, 12),
      type: TxType.expense,
      sourceId: 'aqua-105',
      categoryId: 'property-upkeep',
      amount: 3600,
      description: 'Plumbing repair',
    ),
    Transaction(
      id: 't10',
      date: DateTime(2026, 11, 5),
      type: TxType.income,
      sourceId: 'salary',
      amount: 120000,
      description: 'Salary credited',
    ),
  ];

  static const _templates = [
    EntryTemplate(
      id: 'tp1',
      name: 'Home EMI',
      type: TxType.expense,
      sourceId: 'salary',
      categoryId: 'housing',
      amount: 32000,
      description: '',
    ),
    EntryTemplate(
      id: 'tp2',
      name: 'SIP: index fund',
      type: TxType.investment,
      sourceId: 'salary',
      categoryId: 'mutual-funds',
      amount: 20000,
      description: '',
    ),
    EntryTemplate(
      id: 'tp3',
      name: 'Rent received',
      type: TxType.income,
      sourceId: 'aqua-105',
      amount: 45000,
      description: '',
    ),
    EntryTemplate(
      id: 'tp4',
      name: 'Rent received',
      type: TxType.income,
      sourceId: 'vr',
      amount: 28000,
      description: '',
    ),
    EntryTemplate(
      id: 'tp5',
      name: 'Internet bill',
      type: TxType.expense,
      sourceId: 'vr',
      categoryId: 'utilities',
      description: '',
    ),
    EntryTemplate(
      id: 'tp6',
      name: 'Recurring deposit',
      type: TxType.savings,
      sourceId: 'aqua-105',
      categoryId: 'fixed-deposit',
      amount: 10000,
      description: '',
    ),
  ];

  static final _previousMonth = <Transaction>[
    Transaction(
      id: 'o1',
      date: DateTime(2026, 10, 5),
      type: TxType.expense,
      sourceId: 'salary',
      amount: 32000,
      description: 'Home EMI',
    ),
    Transaction(
      id: 'o2',
      date: DateTime(2026, 10, 5),
      type: TxType.investment,
      sourceId: 'salary',
      amount: 20000,
      description: 'SIP: index fund',
    ),
    Transaction(
      id: 'o3',
      date: DateTime(2026, 10, 22),
      type: TxType.income,
      sourceId: 'aqua-105',
      amount: 45000,
      description: 'Rent received',
    ),
    Transaction(
      id: 'o4',
      date: DateTime(2026, 10, 22),
      type: TxType.income,
      sourceId: 'vr',
      amount: 28000,
      description: 'Rent received',
    ),
    Transaction(
      id: 'o5',
      date: DateTime(2026, 10, 20),
      type: TxType.expense,
      sourceId: 'vr',
      amount: 2100,
      description: 'Electricity bill',
    ),
    Transaction(
      id: 'o6',
      date: DateTime(2026, 10, 15),
      type: TxType.savings,
      sourceId: 'aqua-105',
      amount: 10000,
      description: 'Recurring deposit',
    ),
  ];

  static const _expenseByCategory = [
    CategoryTotal(name: 'Housing', amount: 32000),
    CategoryTotal(name: 'Groceries', amount: 15000),
    CategoryTotal(name: 'Property upkeep', amount: 14600),
    CategoryTotal(name: 'Utilities', amount: 9000),
    CategoryTotal(name: 'Other', amount: 4000),
  ];

  static final _aquaMonths = <SourceMonthRow>[
    SourceMonthRow(
      month: DateTime(2026, 11),
      income: 45000,
      expense: 12000,
      investedSaved: 10000,
      closing: 31000,
    ),
    SourceMonthRow(
      month: DateTime(2026, 10),
      income: 45000,
      expense: 10500,
      investedSaved: 40000,
      closing: 8000,
    ),
    SourceMonthRow(
      month: DateTime(2026, 9),
      income: 45000,
      expense: 6000,
      investedSaved: 30000,
      partner: 5000,
      closing: 13500,
    ),
    SourceMonthRow(
      month: DateTime(2026, 8),
      income: 45000,
      expense: 8500,
      investedSaved: 35000,
      closing: 9500,
    ),
    SourceMonthRow(
      month: DateTime(2026, 7),
      income: 45000,
      expense: 14000,
      investedSaved: 25000,
      closing: 8000,
    ),
    SourceMonthRow(
      month: DateTime(2026, 6),
      income: 45000,
      expense: 9000,
      investedSaved: 40000,
      closing: 2000,
    ),
  ];

  List<EntryTemplate> _templatesById(List<String> ids) => [
    for (final id in ids) _templates.firstWhere((t) => t.id == id),
  ];

  @override
  Future<List<Source>> sources() async =>
      _currentSources.where((s) => s.isActive).toList();

  @override
  Future<List<Source>> allSources() async => _currentSources;

  @override
  Future<List<CategoryUsage>> categoryUsage() async => [
    for (final u in _categoryUsage)
      CategoryUsage(
        category: _categoryNow(u.category),
        entryCount: u.entryCount,
      ),
    for (final c in _addedCategories)
      CategoryUsage(category: _categoryNow(c), entryCount: 0),
  ];

  /// The `closing` value from the source summaries; 0 for any other id
  /// (including the archived `old-freelance`).
  @override
  Future<double> sourceBalance(String sourceId) async {
    for (final s in _summariesNow) {
      if (s.source.id == sourceId) return s.closing;
    }
    return 0;
  }

  @override
  Future<List<Category>> categories() async =>
      _currentCategories.where((c) => c.isActive).toList();

  @override
  Future<List<Category>> allCategories() async => _currentCategories;

  @override
  Future<List<BankAccount>> bankAccounts() async =>
      _currentAccounts.where((a) => a.isActive).toList();

  @override
  Future<List<BankAccount>> allBankAccounts() async => _currentAccounts;

  @override
  Future<List<BankAccountUsage>> bankAccountUsage() async => [
    for (final a in _currentAccounts)
      BankAccountUsage(
        account: a,
        activeSourceCount: _currentSources
            .where((s) => s.isActive && s.bankAccountId == a.id)
            .length,
      ),
  ];

  /// The sum of the closing balances of the account's sources in the mock
  /// summaries, plus the opening balance of sources added in memory.
  double _sourcesTotal(String accountId) {
    var total = 0.0;
    for (final s in _summariesNow) {
      if (s.source.bankAccountId == accountId) total += s.closing;
    }
    for (final s in _addedSources) {
      if (s.bankAccountId == accountId) total += s.openingBalance;
    }
    return total;
  }

  @override
  Future<BankReconciliation> reconciliation() async => BankReconciliation([
    for (final a in _currentAccounts)
      if (a.isActive || _sourcesTotal(a.id) != 0)
        BankAccountReconciliation(
          account: a,
          sourcesTotal: _sourcesTotal(a.id),
          bankBalance: _bankBalances[a.id]?.balance,
          asOf: _bankBalances[a.id]?.asOf,
        ),
  ]);

  @override
  Future<List<SourceSummary>> sourceSummaries(DateTime month) async =>
      _summariesNow;

  @override
  Future<List<Transaction>> recentTransactions() async => [
    for (final id in const ['t1', 't3', 't4', 't6', 't7', 't8'])
      _transactions.firstWhere((t) => t.id == id),
  ];

  @override
  Future<TransactionPage> transactions({
    DateTime? month,
    String? sourceId,
    TxType? type,
    String query = '',
    int page = 1,
  }) async =>
      TransactionPage(items: _transactions, total: 38, page: 1, pageCount: 4);

  @override
  Future<List<EntryTemplate>> templates() async => _templates;

  @override
  Future<List<EntryTemplate>> quickAddTemplates() async =>
      _templatesById(const ['tp1', 'tp2', 'tp3', 'tp5']);

  @override
  Future<List<Transaction>> previousMonthEntries(DateTime month) async =>
      _previousMonth;

  @override
  Future<MonthlyReport> monthlyReport(DateTime month) async => MonthlyReport(
    bySource: _summariesNow,
    expenseByCategory: _expenseByCategory,
  );

  @override
  Future<SourceReport> sourceReport(String sourceId) async => SourceReport(
    source: _currentSources.firstWhere(
      (s) => s.id == sourceId,
      orElse: () => _sourceNow(_aqua105),
    ),
    balanceToday: 31000,
    incomeThisMonth: 45000,
    expenseThisMonth: 12000,
    investedSavedToDate: 180000,
    months: _aquaMonths,
  );

  @override
  Future<void> addEntry(EntryInput input) async {}

  @override
  Future<void> updateEntry(String id, EntryInput input) async {}

  @override
  Future<void> deleteEntry(String id) async {}

  @override
  Future<void> addTemplate(TemplateInput input) async {}

  @override
  Future<void> addEntries(List<EntryInput> inputs) async {}

  @override
  Future<void> setBankBalance(
    String bankAccountId,
    double balance,
    DateTime asOf,
  ) async {
    _bankBalances[bankAccountId] = (balance: balance, asOf: asOf);
  }

  @override
  Future<void> addBankAccount(String name) async {
    _addedAccounts.add(
      BankAccount(id: 'new-${_nextNewId++}', name: name.trim()),
    );
  }

  @override
  Future<void> setBankAccountActive(String id, bool active) async {
    _accountActive[id] = active;
  }

  @override
  Future<void> addSource(SourceInput input) async {
    _addedSources.add(
      Source(
        id: 'new-${_nextNewId++}',
        name: input.name.trim(),
        kind: input.kind,
        openingBalance: input.openingBalance,
        openingDate: input.openingDate,
        bankAccountId: input.bankAccountId,
        bankAccountName: _currentAccounts
            .where((a) => a.id == input.bankAccountId)
            .map((a) => a.name)
            .firstOrNull,
      ),
    );
  }

  @override
  Future<void> setSourceActive(String id, bool active) async {
    _sourceActive[id] = active;
  }

  @override
  Future<void> addCategory(CategoryInput input) async {
    _addedCategories.add(
      Category(
        id: 'new-${_nextNewId++}',
        name: input.name.trim(),
        kind: input.kind,
      ),
    );
  }

  @override
  Future<void> setCategoryActive(String id, bool active) async {
    _categoryActive[id] = active;
  }

  @override
  Future<void> updateSource(String id, SourceInput input) async {
    final current = _currentSources.where((s) => s.id == id).firstOrNull;
    if (current == null) throw StateError('Not found');
    final updated = Source(
      id: id,
      name: input.name.trim(),
      kind: input.kind,
      openingBalance: input.openingBalance,
      isActive: current.isActive,
      openingDate: input.openingDate,
      bankAccountId: input.bankAccountId,
      bankAccountName: _accountName(input.bankAccountId),
    );
    final i = _addedSources.indexWhere((s) => s.id == id);
    if (i >= 0) {
      _addedSources[i] = updated;
    } else {
      _sourceEdits[id] = updated;
    }
  }

  @override
  Future<void> renameBankAccount(String id, String name) async {
    _accountNames[id] = name.trim();
  }
}

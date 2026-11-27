import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/data/supabase/row_mappers.dart';
import 'package:finance_tracker/core/models/bank_reconciliation.dart';
import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/category_usage.dart';
import 'package:finance_tracker/core/models/entry_input.dart';
import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/monthly_report.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/source_report.dart';
import 'package:finance_tracker/core/models/source_summary.dart';
import 'package:finance_tracker/core/models/template_input.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/models/transaction_page.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/utils/sql_date.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide toDouble;

class SupabaseFinanceRepository implements FinanceRepository {
  SupabaseFinanceRepository(this._client);

  final SupabaseClient _client;

  List<Map<String, dynamic>> _rows(Object? data) =>
      List<Map<String, dynamic>>.from(data as List);

  @override
  Future<List<Source>> sources() async {
    final data = await _client
        .from('sources')
        .select()
        .eq('is_active', true)
        .order('created_at');
    return _rows(data).map(sourceFromRow).toList();
  }

  @override
  Future<List<Source>> allSources() async {
    final data = await _client.from('sources').select().order('created_at');
    return _rows(data).map(sourceFromRow).toList();
  }

  @override
  Future<List<Category>> categories() async {
    final data = await _client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('created_at');
    return _rows(data).map(categoryFromRow).toList();
  }

  @override
  Future<List<Category>> allCategories() async {
    final data = await _client.from('categories').select().order('created_at');
    return _rows(data).map(categoryFromRow).toList();
  }

  @override
  Future<List<CategoryUsage>> categoryUsage() async {
    final data = await _client.rpc('category_usage');
    return _rows(data).map(categoryUsageFromRow).toList();
  }

  @override
  Future<double> sourceBalance(String sourceId) async {
    final data = await _client.rpc(
      'source_balance',
      params: {'p_source': sourceId},
    );
    return data == null ? 0 : toDouble(data);
  }

  @override
  Future<List<EntryTemplate>> templates() async {
    final data = await _client
        .from('entry_templates')
        .select()
        .order('sort_order')
        .order('created_at');
    return _rows(data).map(templateFromRow).toList();
  }

  @override
  Future<List<EntryTemplate>> quickAddTemplates() async {
    final data = await _client
        .from('entry_templates')
        .select()
        .eq('quick_add', true)
        .order('sort_order')
        .order('created_at');
    return _rows(data).map(templateFromRow).toList();
  }

  @override
  Future<List<Transaction>> previousMonthEntries(DateTime month) async {
    final from = DateTime(month.year, month.month);
    final to = DateTime(month.year, month.month + 1);
    final data = await _client
        .from('transactions')
        .select()
        .gte('tx_date', sqlDate(from))
        .lt('tx_date', sqlDate(to))
        .order('tx_date')
        .order('created_at');
    return _rows(data).map(transactionFromRow).toList();
  }

  @override
  Future<BankReconciliation> reconciliation() async {
    final data = await _client.rpc('current_reconciliation');
    return reconciliationFromRow(_rows(data).first);
  }

  @override
  Future<List<SourceSummary>> sourceSummaries(DateTime month) async {
    final data = await _client.rpc(
      'source_summaries',
      params: {'p_month': sqlDate(month)},
    );
    return _rows(data).map(sourceSummaryFromRow).toList();
  }

  @override
  Future<List<Transaction>> recentTransactions() async {
    final data = await _client
        .from('transactions')
        .select()
        .order('tx_date', ascending: false)
        .order('created_at', ascending: false)
        .limit(6);
    return _rows(data).map(transactionFromRow).toList();
  }

  @override
  Future<TransactionPage> transactions({
    DateTime? month,
    String? sourceId,
    TxType? type,
    String query = '',
    int page = 1,
  }) async {
    var q = _client
        .from('transactions')
        .select(
          'id, tx_date, type, source_id, category_id, amount, description',
        );
    if (month != null) {
      final from = DateTime(month.year, month.month);
      final to = DateTime(month.year, month.month + 1);
      q = q.gte('tx_date', sqlDate(from)).lt('tx_date', sqlDate(to));
    }
    if (sourceId != null) q = q.eq('source_id', sourceId);
    if (type != null) q = q.eq('type', type.name);
    final text = query.trim();
    if (text.isNotEmpty) {
      final escaped = text
          .replaceAll(r'\', r'\\')
          .replaceAll('%', r'\%')
          .replaceAll('_', r'\_');
      q = q.ilike('description', '%$escaped%');
    }
    final response = await q
        .order('tx_date', ascending: false)
        .order('created_at', ascending: false)
        .range((page - 1) * kPageSize, page * kPageSize - 1)
        .count(CountOption.exact);
    final total = response.count;
    final pageCount = total == 0 ? 1 : (total / kPageSize).ceil();
    return TransactionPage(
      items: _rows(response.data).map(transactionFromRow).toList(),
      total: total,
      page: page,
      pageCount: pageCount,
    );
  }

  @override
  Future<MonthlyReport> monthlyReport(DateTime month) async {
    final results = await Future.wait<Object?>([
      sourceSummaries(month),
      _client.rpc('expense_by_category', params: {'p_month': sqlDate(month)}),
    ]);
    final summaries = results[0] as List<SourceSummary>;
    final rows = _rows(results[1]);
    return MonthlyReport(
      bySource: summaries,
      expenseByCategory: [
        for (final r in rows)
          CategoryTotal(
            name: r['category'] as String,
            amount: toDouble(r['amount']),
          ),
      ],
    );
  }

  @override
  Future<SourceReport> sourceReport(String sourceId) async {
    final all = await allSources();
    final source = all.firstWhere(
      (s) => s.id == sourceId,
      orElse: () => throw StateError('Source not found'),
    );
    final summaries = await sourceSummaries(appMonth());
    SourceSummary? thisMonth;
    for (final s in summaries) {
      if (s.source.id == sourceId) thisMonth = s;
    }
    final balance = await sourceBalance(sourceId);
    final data = await _client.rpc(
      'source_month_rows',
      params: {
        'p_source': sourceId,
        'p_end_month': sqlDate(appToday()),
        'p_months': 6,
      },
    );
    return SourceReport(
      source: source,
      balanceToday: balance,
      incomeThisMonth: thisMonth?.income ?? 0,
      expenseThisMonth: thisMonth?.expense ?? 0,
      investedSavedToDate: thisMonth?.investedSavedToDate ?? 0,
      months: _rows(data).map(sourceMonthRowFromRow).toList(),
    );
  }

  Map<String, dynamic> _entryRow(EntryInput input) => {
    'tx_date': sqlDate(input.date),
    'type': input.type.name,
    'source_id': input.sourceId,
    'category_id': input.categoryId,
    'amount': input.amount,
    'description': input.description.trim(),
  };

  @override
  Future<void> addEntry(EntryInput input) async {
    // user_id is filled by the database default.
    await _client.from('transactions').insert(_entryRow(input));
  }

  @override
  Future<void> updateEntry(String id, EntryInput input) async {
    final rows = await _client
        .from('transactions')
        .update(_entryRow(input))
        .eq('id', id)
        .select('id');
    // A row you cannot see is treated as missing.
    if (rows.isEmpty) throw StateError('Entry not found');
  }

  @override
  Future<void> deleteEntry(String id) async {
    final rows = await _client
        .from('transactions')
        .delete()
        .eq('id', id)
        .select('id');
    if (rows.isEmpty) throw StateError('Entry not found');
  }

  @override
  Future<void> addTemplate(TemplateInput input) async {
    await _client.from('entry_templates').insert({
      'name': input.name.trim(),
      'type': input.type.name,
      'source_id': input.sourceId,
      'category_id': input.categoryId,
      'amount': input.amount,
      'description': input.description.trim(),
      'quick_add': input.quickAdd,
      'sort_order': input.sortOrder,
    });
  }

  @override
  Future<void> addEntries(List<EntryInput> inputs) async {
    if (inputs.isEmpty) return;
    await _client.from('transactions').insert(inputs.map(_entryRow).toList());
  }
}

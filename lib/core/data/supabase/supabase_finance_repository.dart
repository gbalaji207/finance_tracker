import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/data/supabase/row_mappers.dart';
import 'package:finance_tracker/core/models/bank_reconciliation.dart';
import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/category_usage.dart';
import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/monthly_report.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/source_report.dart';
import 'package:finance_tracker/core/models/source_summary.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/models/transaction_page.dart';
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
  Future<BankReconciliation> reconciliation() =>
      throw UnimplementedError('B05');

  @override
  Future<List<SourceSummary>> sourceSummaries(DateTime month) =>
      throw UnimplementedError('B05');

  @override
  Future<List<Transaction>> recentTransactions() =>
      throw UnimplementedError('B05');

  @override
  Future<TransactionPage> transactions({int page = 1}) =>
      throw UnimplementedError('B07');

  @override
  Future<MonthlyReport> monthlyReport(DateTime month) =>
      throw UnimplementedError('B06');

  @override
  Future<SourceReport> sourceReport(String sourceId) =>
      throw UnimplementedError('B06');
}

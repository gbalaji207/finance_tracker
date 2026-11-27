import 'package:finance_tracker/core/models/bank_account.dart';
import 'package:finance_tracker/core/models/bank_reconciliation.dart';
import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/category_usage.dart';
import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/source_report.dart';
import 'package:finance_tracker/core/models/source_summary.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/models/tx_type.dart';

/// Money and counts arrive as a JSON number or as a string such as "32000.00".
double toDouble(Object? v) => v is num ? v.toDouble() : double.parse('$v');

int _toInt(Object? v) => v is num ? v.toInt() : int.parse('$v');

Source sourceFromRow(Map<String, dynamic> r) => Source(
  id: r['id'] as String,
  name: r['name'] as String,
  kind: r['kind'] as String,
  openingBalance: toDouble(r['opening_balance']),
  isActive: r['is_active'] as bool,
  openingDate: r['opening_date'] == null
      ? null
      : DateTime.parse(r['opening_date'] as String),
  bankAccountId: r['bank_account_id'] as String?,
  // Present when the query embeds the account: select('*, bank_accounts(name)').
  bankAccountName: (r['bank_accounts'] as Map?)?['name'] as String?,
);

Category categoryFromRow(Map<String, dynamic> r) => Category(
  id: r['id'] as String,
  name: r['name'] as String,
  kind: TxType.values.byName(r['kind'] as String),
  isActive: r['is_active'] as bool,
);

CategoryUsage categoryUsageFromRow(Map<String, dynamic> r) => CategoryUsage(
  category: Category(
    id: r['category_id'] as String,
    name: r['name'] as String,
    kind: TxType.values.byName(r['kind'] as String),
    isActive: r['is_active'] as bool,
  ),
  entryCount: _toInt(r['entry_count']),
);

EntryTemplate templateFromRow(Map<String, dynamic> r) => EntryTemplate(
  id: r['id'] as String,
  name: r['name'] as String,
  type: TxType.values.byName(r['type'] as String),
  sourceId: r['source_id'] as String,
  categoryId: r['category_id'] as String?,
  amount: r['amount'] == null ? null : toDouble(r['amount']),
  description: (r['description'] as String?) ?? '',
  sortOrder: (r['sort_order'] as num?)?.toInt() ?? 0,
);

Transaction transactionFromRow(Map<String, dynamic> r) => Transaction(
  id: r['id'] as String,
  date: DateTime.parse(r['tx_date'] as String),
  type: TxType.values.byName(r['type'] as String),
  sourceId: r['source_id'] as String,
  categoryId: r['category_id'] as String?,
  amount: toDouble(r['amount']),
  description: (r['description'] as String?) ?? '',
);

SourceSummary sourceSummaryFromRow(Map<String, dynamic> r) => SourceSummary(
  source: Source(
    id: r['source_id'] as String,
    name: r['name'] as String,
    kind: r['kind'] as String,
    openingBalance: toDouble(r['opening_balance']),
    isActive: r['is_active'] as bool,
    bankAccountId: r['bank_account_id'] as String?,
    bankAccountName: r['bank_account_name'] as String?,
  ),
  monthOpening: toDouble(r['month_opening']),
  income: toDouble(r['income']),
  expense: toDouble(r['expense']),
  invested: toDouble(r['invested']),
  saved: toDouble(r['saved']),
  closing: toDouble(r['closing']),
  investedSavedToDate: toDouble(r['invested_saved_to_date']),
);

SourceMonthRow sourceMonthRowFromRow(Map<String, dynamic> r) => SourceMonthRow(
  month: DateTime.parse(r['month'] as String),
  income: toDouble(r['income']),
  expense: toDouble(r['expense']),
  investedSaved: toDouble(r['invested_saved']),
  closing: toDouble(r['closing']),
);

BankAccount bankAccountFromRow(Map<String, dynamic> r) => BankAccount(
  id: r['id'] as String,
  name: r['name'] as String,
  isActive: r['is_active'] as bool,
);

BankAccountUsage bankAccountUsageFromRow(Map<String, dynamic> r) =>
    BankAccountUsage(
      account: BankAccount(
        id: r['bank_account_id'] as String,
        name: r['name'] as String,
        isActive: r['is_active'] as bool,
      ),
      activeSourceCount: _toInt(r['active_source_count']),
    );

BankAccountReconciliation bankAccountReconciliationFromRow(
  Map<String, dynamic> r,
) => BankAccountReconciliation(
  account: BankAccount(
    id: r['bank_account_id'] as String,
    name: r['name'] as String,
    isActive: r['is_active'] as bool,
  ),
  sourcesTotal: toDouble(r['sources_total']),
  bankBalance: r['bank_balance'] == null ? null : toDouble(r['bank_balance']),
  asOf: r['as_of'] == null ? null : DateTime.parse(r['as_of'] as String),
);

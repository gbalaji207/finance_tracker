import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/models/account_ledger.dart';
import 'package:finance_tracker/core/models/bank_account.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/tx_type.dart';

class AccountsReportState extends Equatable {
  AccountsReportState({
    this.status = LoadStatus.loading,
    this.bankAccounts = const [],
    this.sources = const [],
    DateTime? from,
    DateTime? to,
    this.bankAccountFilter,
    this.sourceFilter,
    this.typeFilter,
    this.ledger,
    this.errorMessage,
    this.listLoading = false,
    this.actionError,
  }) : from = from ?? appMonth(),
       to = to ?? _endOfMonth(appMonth());

  final LoadStatus status;

  /// Active and archived, so an archived account can still be chosen.
  final List<BankAccount> bankAccounts;

  /// Active and archived, so an archived source can still be chosen.
  final List<Source> sources;

  /// Both inclusive. Default: the first and last day of the current month.
  final DateTime from;
  final DateTime to;

  /// Bank account id; null means all bank accounts.
  final String? bankAccountFilter;

  /// Source id; null means all sources (of the chosen bank account).
  final String? sourceFilter;

  /// Null means all types.
  final TxType? typeFilter;
  final AccountLedger? ledger;
  final String? errorMessage;

  /// True while the ledger is being reloaded (the old data stays visible).
  final bool listLoading;

  /// One-shot message for the page to show as a SnackBar, then clear.
  final String? actionError;

  static DateTime _endOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);

  /// The sources the Source filter offers: those of the chosen bank account,
  /// or all of them.
  List<Source> get sourcesForFilter => [
    for (final s in sources)
      if (bankAccountFilter == null || s.bankAccountId == bankAccountFilter) s,
  ];

  /// The three filters can be null, so `copyWith` has explicit "clear" flags.
  AccountsReportState copyWith({
    LoadStatus? status,
    List<BankAccount>? bankAccounts,
    List<Source>? sources,
    DateTime? from,
    DateTime? to,
    String? bankAccountFilter,
    bool clearBankAccountFilter = false,
    String? sourceFilter,
    bool clearSourceFilter = false,
    TxType? typeFilter,
    bool clearTypeFilter = false,
    AccountLedger? ledger,
    String? errorMessage,
    bool clearError = false,
    bool? listLoading,
    String? actionError,
    bool clearActionError = false,
  }) => AccountsReportState(
    status: status ?? this.status,
    bankAccounts: bankAccounts ?? this.bankAccounts,
    sources: sources ?? this.sources,
    from: from ?? this.from,
    to: to ?? this.to,
    bankAccountFilter: clearBankAccountFilter
        ? null
        : (bankAccountFilter ?? this.bankAccountFilter),
    sourceFilter: clearSourceFilter
        ? null
        : (sourceFilter ?? this.sourceFilter),
    typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
    ledger: ledger ?? this.ledger,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    listLoading: listLoading ?? this.listLoading,
    actionError: clearActionError ? null : (actionError ?? this.actionError),
  );

  @override
  List<Object?> get props => [
    status,
    bankAccounts,
    sources,
    from,
    to,
    bankAccountFilter,
    sourceFilter,
    typeFilter,
    ledger,
    errorMessage,
    listLoading,
    actionError,
  ];
}

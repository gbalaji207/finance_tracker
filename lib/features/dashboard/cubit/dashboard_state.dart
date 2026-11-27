import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/models/bank_reconciliation.dart';
import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/source_summary.dart';
import 'package:finance_tracker/core/models/transaction.dart';

class DashboardState extends Equatable {
  DashboardState({
    this.status = LoadStatus.loading,
    DateTime? month,
    this.sources = const [],
    this.reconciliation,
    this.summaries = const [],
    this.recent = const [],
    this.quickAdd = const [],
    this.errorMessage,
    this.actionError,
  }) : month = month ?? appMonth();

  final LoadStatus status;
  final DateTime month;
  final List<Source> sources;
  final BankReconciliation? reconciliation;
  final List<SourceSummary> summaries;
  final List<Transaction> recent;
  final List<EntryTemplate> quickAdd;
  final String? errorMessage;

  /// One-shot message for the page to show as a SnackBar, then clear.
  final String? actionError;

  List<Source> get activeSources => sources.where((s) => s.isActive).toList();

  /// The source name for [id], or [id] itself if the source is unknown.
  String sourceName(String id) {
    for (final s in sources) {
      if (s.id == id) return s.name;
    }
    return id;
  }

  DashboardState copyWith({
    LoadStatus? status,
    DateTime? month,
    List<Source>? sources,
    BankReconciliation? reconciliation,
    List<SourceSummary>? summaries,
    List<Transaction>? recent,
    List<EntryTemplate>? quickAdd,
    String? errorMessage,
    bool clearError = false,
    String? actionError,
    bool clearActionError = false,
  }) => DashboardState(
    status: status ?? this.status,
    month: month ?? this.month,
    sources: sources ?? this.sources,
    reconciliation: reconciliation ?? this.reconciliation,
    summaries: summaries ?? this.summaries,
    recent: recent ?? this.recent,
    quickAdd: quickAdd ?? this.quickAdd,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    actionError: clearActionError ? null : (actionError ?? this.actionError),
  );

  @override
  List<Object?> get props => [
    status,
    month,
    sources,
    reconciliation,
    summaries,
    recent,
    quickAdd,
    errorMessage,
    actionError,
  ];
}

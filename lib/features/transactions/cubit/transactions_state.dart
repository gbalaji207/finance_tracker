import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/models/transaction_page.dart';
import 'package:finance_tracker/core/models/tx_type.dart';

class TransactionsState extends Equatable {
  TransactionsState({
    this.status = LoadStatus.loading,
    this.page,
    this.sources = const [],
    this.categories = const [],
    this.templates = const [],
    DateTime? month,
    this.sourceFilter,
    this.typeFilter,
    this.query = '',
    this.selectedId,
  }) : month = month ?? appMonth();

  final LoadStatus status;
  final TransactionPage? page;
  final List<Source> sources;
  final List<Category> categories;
  final List<EntryTemplate> templates;
  final DateTime month;

  /// Source id; null means all sources.
  final String? sourceFilter;

  /// Null means all types.
  final TxType? typeFilter;
  final String query;

  /// Id of the entry being edited; null when adding a new entry.
  final String? selectedId;

  /// The entry being edited, or null when adding a new entry.
  Transaction? get selected {
    final id = selectedId;
    if (id == null) return null;
    for (final t in page?.items ?? const <Transaction>[]) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// The source name for [id], or [id] itself if the source is unknown.
  String sourceName(String id) {
    for (final s in sources) {
      if (s.id == id) return s.name;
    }
    return id;
  }

  /// The category name for [id], or an em dash when [id] is null or unknown.
  String categoryName(String? id) {
    if (id == null) return '—';
    for (final c in categories) {
      if (c.id == id) return c.name;
    }
    return '—';
  }

  /// Filters use `copyWith` with explicit "clear" flags, because null is a
  /// valid filter value (all sources / all types).
  TransactionsState copyWith({
    LoadStatus? status,
    TransactionPage? page,
    List<Source>? sources,
    List<Category>? categories,
    List<EntryTemplate>? templates,
    DateTime? month,
    String? sourceFilter,
    bool clearSourceFilter = false,
    TxType? typeFilter,
    bool clearTypeFilter = false,
    String? query,
    String? selectedId,
    bool clearSelected = false,
  }) => TransactionsState(
    status: status ?? this.status,
    page: page ?? this.page,
    sources: sources ?? this.sources,
    categories: categories ?? this.categories,
    templates: templates ?? this.templates,
    month: month ?? this.month,
    sourceFilter: clearSourceFilter
        ? null
        : (sourceFilter ?? this.sourceFilter),
    typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
    query: query ?? this.query,
    selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
  );

  @override
  List<Object?> get props => [
    status,
    page,
    sources,
    categories,
    templates,
    month,
    sourceFilter,
    typeFilter,
    query,
    selectedId,
  ];
}

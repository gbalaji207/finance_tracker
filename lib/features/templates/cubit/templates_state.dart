import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/transaction.dart';

class TemplatesState extends Equatable {
  const TemplatesState({
    this.status = LoadStatus.loading,
    this.sources = const [],
    this.categories = const [],
    this.templates = const [],
    this.previousEntries = const [],
    this.selectedIds = const {},
    this.errorMessage,
  });

  final LoadStatus status;
  final List<Source> sources;
  final List<Category> categories;
  final List<EntryTemplate> templates;
  final List<Transaction> previousEntries;
  final Set<String> selectedIds;
  final String? errorMessage;

  int get selectedCount => selectedIds.length;

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

  TemplatesState copyWith({
    LoadStatus? status,
    List<Source>? sources,
    List<Category>? categories,
    List<EntryTemplate>? templates,
    List<Transaction>? previousEntries,
    Set<String>? selectedIds,
    String? errorMessage,
    bool clearError = false,
  }) => TemplatesState(
    status: status ?? this.status,
    sources: sources ?? this.sources,
    categories: categories ?? this.categories,
    templates: templates ?? this.templates,
    previousEntries: previousEntries ?? this.previousEntries,
    selectedIds: selectedIds ?? this.selectedIds,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [
    status,
    sources,
    categories,
    templates,
    previousEntries,
    selectedIds,
    errorMessage,
  ];
}

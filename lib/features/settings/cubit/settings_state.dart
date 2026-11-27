import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/category_usage.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/source.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.status = LoadStatus.loading,
    this.sources = const [],
    this.categoryUsage = const [],
    this.errorMessage,
  });

  final LoadStatus status;

  /// Active and archived.
  final List<Source> sources;
  final List<CategoryUsage> categoryUsage;
  final String? errorMessage;

  SettingsState copyWith({
    LoadStatus? status,
    List<Source>? sources,
    List<CategoryUsage>? categoryUsage,
    String? errorMessage,
    bool clearError = false,
  }) => SettingsState(
    status: status ?? this.status,
    sources: sources ?? this.sources,
    categoryUsage: categoryUsage ?? this.categoryUsage,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [status, sources, categoryUsage, errorMessage];
}

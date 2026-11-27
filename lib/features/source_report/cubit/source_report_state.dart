import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/source_report.dart';

class SourceReportState extends Equatable {
  const SourceReportState({
    this.status = LoadStatus.loading,
    this.selectedSourceId,
    this.sources = const [],
    this.report,
    this.errorMessage,
    this.actionError,
  });

  final LoadStatus status;
  final String? selectedSourceId;

  /// Active and archived.
  final List<Source> sources;
  final SourceReport? report;
  final String? errorMessage;

  /// One-shot message for the page to show as a SnackBar, then clear.
  final String? actionError;

  SourceReportState copyWith({
    LoadStatus? status,
    String? selectedSourceId,
    List<Source>? sources,
    SourceReport? report,
    bool clearReport = false,
    String? errorMessage,
    bool clearError = false,
    String? actionError,
    bool clearActionError = false,
  }) => SourceReportState(
    status: status ?? this.status,
    selectedSourceId: selectedSourceId ?? this.selectedSourceId,
    sources: sources ?? this.sources,
    report: clearReport ? null : (report ?? this.report),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    actionError: clearActionError ? null : (actionError ?? this.actionError),
  );

  @override
  List<Object?> get props => [
    status,
    selectedSourceId,
    sources,
    report,
    errorMessage,
    actionError,
  ];
}

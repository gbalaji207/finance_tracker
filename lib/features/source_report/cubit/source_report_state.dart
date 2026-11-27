import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/source_report.dart';

class SourceReportState extends Equatable {
  const SourceReportState({
    this.status = LoadStatus.loading,
    this.selectedSourceId = 'aqua-105',
    this.report,
    this.errorMessage,
  });

  final LoadStatus status;
  final String selectedSourceId;
  final SourceReport? report;
  final String? errorMessage;

  SourceReportState copyWith({
    LoadStatus? status,
    String? selectedSourceId,
    SourceReport? report,
    String? errorMessage,
    bool clearError = false,
  }) => SourceReportState(
    status: status ?? this.status,
    selectedSourceId: selectedSourceId ?? this.selectedSourceId,
    report: report ?? this.report,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [status, selectedSourceId, report, errorMessage];
}

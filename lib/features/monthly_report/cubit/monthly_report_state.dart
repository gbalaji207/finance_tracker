import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/monthly_report.dart';

class MonthlyReportState extends Equatable {
  MonthlyReportState({
    this.status = LoadStatus.loading,
    DateTime? month,
    this.report,
    this.errorMessage,
  }) : month = month ?? appMonth();

  final LoadStatus status;
  final DateTime month;
  final MonthlyReport? report;
  final String? errorMessage;

  MonthlyReportState copyWith({
    LoadStatus? status,
    DateTime? month,
    MonthlyReport? report,
    String? errorMessage,
    bool clearError = false,
  }) => MonthlyReportState(
    status: status ?? this.status,
    month: month ?? this.month,
    report: report ?? this.report,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [status, month, report, errorMessage];
}

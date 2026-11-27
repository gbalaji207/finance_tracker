import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/monthly_report.dart';

class MonthlyReportState extends Equatable {
  MonthlyReportState({
    this.status = LoadStatus.loading,
    DateTime? month,
    this.report,
  }) : month = month ?? appMonth();

  final LoadStatus status;
  final DateTime month;
  final MonthlyReport? report;

  MonthlyReportState copyWith({
    LoadStatus? status,
    DateTime? month,
    MonthlyReport? report,
  }) =>
      MonthlyReportState(
        status: status ?? this.status,
        month: month ?? this.month,
        report: report ?? this.report,
      );

  @override
  List<Object?> get props => [status, month, report];
}

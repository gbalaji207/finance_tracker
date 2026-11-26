import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/features/monthly_report/cubit/monthly_report_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MonthlyReportCubit extends Cubit<MonthlyReportState> {
  MonthlyReportCubit(this._repo) : super(MonthlyReportState());

  final FinanceRepository _repo;

  Future<void> load() async {
    final report = await _repo.monthlyReport(state.month);
    emit(state.copyWith(status: LoadStatus.loaded, report: report));
  }

  /// Only the month changes in this phase; the data stays the same.
  void changeMonth(DateTime month) => emit(state.copyWith(month: month));
}

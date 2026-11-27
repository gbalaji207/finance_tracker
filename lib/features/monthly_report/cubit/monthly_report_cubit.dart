import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/utils/error_message.dart';
import 'package:finance_tracker/features/monthly_report/cubit/monthly_report_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MonthlyReportCubit extends Cubit<MonthlyReportState> {
  MonthlyReportCubit(this._repo) : super(MonthlyReportState());

  final FinanceRepository _repo;
  int _request = 0;

  Future<void> load() async {
    final request = ++_request;
    emit(state.copyWith(status: LoadStatus.loading, clearError: true));
    try {
      final report = await _repo.monthlyReport(state.month);
      if (request != _request || isClosed) return;
      emit(state.copyWith(status: LoadStatus.loaded, report: report));
    } catch (e) {
      if (request != _request || isClosed) return;
      emit(
        state.copyWith(
          status: LoadStatus.error,
          errorMessage: friendlyError(e),
        ),
      );
    }
  }

  /// Keeps the old report on screen until the new one arrives. A failure goes
  /// back to the previous month and shows a SnackBar.
  Future<void> changeMonth(DateTime month) async {
    final previous = state.month;
    final request = ++_request;
    emit(state.copyWith(month: month));
    try {
      final report = await _repo.monthlyReport(month);
      if (request != _request || isClosed) return;
      emit(state.copyWith(report: report));
    } catch (e) {
      if (request != _request || isClosed) return;
      emit(state.copyWith(month: previous, actionError: friendlyError(e)));
    }
  }

  void clearActionError() => emit(state.copyWith(clearActionError: true));
}

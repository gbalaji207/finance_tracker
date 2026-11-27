import 'package:finance_tracker/core/utils/error_message.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/features/dashboard/cubit/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repo) : super(DashboardState());

  final FinanceRepository _repo;
  int _monthRequest = 0;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, clearError: true));
    try {
      final sources = await _repo.allSources();
      final reconciliation = await _repo.reconciliation();
      final summaries = await _repo.sourceSummaries(state.month);
      final recent = await _repo.recentTransactions();
      final quickAdd = await _repo.quickAddTemplates();
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          sources: sources,
          reconciliation: reconciliation,
          summaries: summaries,
          recent: recent,
          quickAdd: quickAdd,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LoadStatus.error,
          errorMessage: friendlyError(e),
        ),
      );
    }
  }

  /// Saves the bank balance of [accountId] for [asOf], then reloads the
  /// reconciliation. Returns an error message, or null on success.
  Future<String?> updateBankBalance(
    String accountId,
    double balance,
    DateTime asOf,
  ) async {
    try {
      await _repo.setBankBalance(accountId, balance, asOf);
      final reconciliation = await _repo.reconciliation();
      if (!isClosed) emit(state.copyWith(reconciliation: reconciliation));
      return null;
    } catch (e) {
      return friendlyError(e);
    }
  }

  /// Reloads only the source cards for [month]; the rest of the page stays.
  Future<void> changeMonth(DateTime month) async {
    final previous = state.month;
    final request = ++_monthRequest;
    emit(state.copyWith(month: month));
    try {
      final summaries = await _repo.sourceSummaries(month);
      if (request != _monthRequest || isClosed) return;
      emit(state.copyWith(summaries: summaries));
    } catch (e) {
      if (request != _monthRequest || isClosed) return;
      emit(state.copyWith(month: previous, actionError: friendlyError(e)));
    }
  }

  void clearActionError() => emit(state.copyWith(clearActionError: true));
}

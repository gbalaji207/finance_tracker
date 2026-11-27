import 'package:finance_tracker/core/utils/error_message.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/bank_reconciliation.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/features/dashboard/cubit/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repo) : super(DashboardState());

  final FinanceRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, clearError: true));
    try {
      final sources = await _repo.sources();
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

  /// Replaces the bank balance and its date. In memory only: reloading the
  /// page resets it. The sum of source balances is unchanged.
  void updateBankBalance(double balance, DateTime asOf) {
    final current = state.reconciliation;
    if (current == null) return;
    emit(
      state.copyWith(
        reconciliation: BankReconciliation(
          sourcesTotal: current.sourcesTotal,
          bankBalance: balance,
          asOf: asOf,
        ),
      ),
    );
  }

  /// Only the month changes in this phase; the data stays the same.
  void changeMonth(DateTime month) => emit(state.copyWith(month: month));
}

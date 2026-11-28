import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/account_ledger.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/utils/error_message.dart';
import 'package:finance_tracker/features/accounts_report/cubit/accounts_report_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountsReportCubit extends Cubit<AccountsReportState> {
  AccountsReportCubit(this._repo) : super(AccountsReportState());

  final FinanceRepository _repo;

  /// Only the response to the latest request is used.
  int _request = 0;

  Future<AccountLedger> _fetch(int page) => _repo.accountLedger(
    from: state.from,
    to: state.to,
    bankAccountId: state.bankAccountFilter,
    sourceId: state.sourceFilter,
    type: state.typeFilter,
    page: page,
  );

  Future<void> load() async {
    final request = ++_request;
    emit(state.copyWith(status: LoadStatus.loading, clearError: true));
    try {
      final bankAccounts = await _repo.allBankAccounts();
      final sources = await _repo.allSources();
      final ledger = await _fetch(1);
      if (request != _request || isClosed) return;
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          bankAccounts: bankAccounts,
          sources: sources,
          ledger: ledger,
          listLoading: false,
        ),
      );
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

  /// Reloads the ledger with the current filters. The old data stays visible
  /// meanwhile; a failure keeps it and reports through [actionError].
  Future<void> _loadList(int page) async {
    final request = ++_request;
    emit(state.copyWith(listLoading: true));
    try {
      final ledger = await _fetch(page);
      if (request != _request || isClosed) return;
      emit(state.copyWith(ledger: ledger, listLoading: false));
    } catch (e) {
      if (request != _request || isClosed) return;
      emit(state.copyWith(listLoading: false, actionError: friendlyError(e)));
    }
  }

  void setRange(DateTime from, DateTime to) {
    emit(state.copyWith(from: from, to: to));
    _loadList(1);
  }

  /// Pass null for all bank accounts. A chosen source that belongs to another
  /// account is cleared, because it could not match anything.
  void setBankAccountFilter(String? bankAccountId) {
    final chosen = state.sourceFilter;
    var clearSource = false;
    if (chosen != null && bankAccountId != null) {
      final source = state.sources.where((s) => s.id == chosen).firstOrNull;
      clearSource = source?.bankAccountId != bankAccountId;
    }
    emit(
      state.copyWith(
        bankAccountFilter: bankAccountId,
        clearBankAccountFilter: bankAccountId == null,
        clearSourceFilter: clearSource,
      ),
    );
    _loadList(1);
  }

  /// Pass null for all sources.
  void setSourceFilter(String? sourceId) {
    emit(
      state.copyWith(
        sourceFilter: sourceId,
        clearSourceFilter: sourceId == null,
      ),
    );
    _loadList(1);
  }

  /// Pass null for all types.
  void setTypeFilter(TxType? type) {
    emit(state.copyWith(typeFilter: type, clearTypeFilter: type == null));
    _loadList(1);
  }

  void goToPage(int page) => _loadList(page);

  void clearActionError() => emit(state.copyWith(clearActionError: true));
}

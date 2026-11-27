import 'dart:async';

import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/entry_input.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/transaction_page.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/utils/error_message.dart';
import 'package:finance_tracker/features/transactions/cubit/transactions_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit(this._repo) : super(TransactionsState(month: appMonth()));

  final FinanceRepository _repo;
  int _request = 0;
  Timer? _debounce;

  Future<TransactionPage> _fetch(int page) => _repo.transactions(
    month: state.month,
    sourceId: state.sourceFilter,
    type: state.typeFilter,
    query: state.query,
    page: page,
  );

  Future<void> load() async {
    final request = ++_request;
    emit(state.copyWith(status: LoadStatus.loading, clearError: true));
    try {
      final sources = await _repo.allSources();
      final categories = await _repo.allCategories();
      final templates = await _repo.templates();
      final page = await _fetch(1);
      if (request != _request || isClosed) return;
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          sources: sources,
          categories: categories,
          templates: templates,
          page: page,
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

  /// Reloads the list with the current filters. The old page stays visible
  /// meanwhile, and a response that is not the latest request is ignored.
  Future<void> _loadList(int page) async {
    final request = ++_request;
    emit(state.copyWith(listLoading: true));
    try {
      var result = await _fetch(page);
      // After deletions the requested page can be past the end.
      if (result.items.isEmpty && result.total > 0 && page > 1) {
        if (request != _request || isClosed) return;
        result = await _fetch(result.pageCount);
      }
      if (request != _request || isClosed) return;
      emit(state.copyWith(page: result, listLoading: false));
    } catch (e) {
      if (request != _request || isClosed) return;
      emit(state.copyWith(listLoading: false, actionError: friendlyError(e)));
    }
  }

  /// Reloads the current page with the current filters.
  Future<void> reloadList() => _loadList(state.page?.page ?? 1);

  /// Pass null for all months.
  void setMonth(DateTime? month) {
    emit(state.copyWith(month: month, clearMonth: month == null));
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

  /// The field keeps what is typed at once; the list reloads after 300 ms of
  /// no typing.
  void setQuery(String query) {
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _loadList(1));
  }

  void goToPage(int page) => _loadList(page);

  /// Runs a write, then reloads the list. Returns an error message, or null
  /// on success.
  Future<String?> _write(
    Future<void> Function() action, {
    required bool firstPage,
  }) async {
    emit(state.copyWith(saving: true));
    try {
      await action();
      if (isClosed) return null;
      await (firstPage ? _loadList(1) : reloadList());
      if (!isClosed) emit(state.copyWith(saving: false));
      return null;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(saving: false));
      return friendlyError(e);
    }
  }

  Future<String?> addEntry(EntryInput input) =>
      _write(() => _repo.addEntry(input), firstPage: true);

  Future<String?> updateEntry(String id, EntryInput input) =>
      _write(() => _repo.updateEntry(id, input), firstPage: false);

  Future<String?> deleteEntry(String id) =>
      _write(() => _repo.deleteEntry(id), firstPage: false);

  /// Selects the entry being edited; null leaves edit mode.
  void select(String? id) =>
      emit(state.copyWith(selectedId: id, clearSelected: id == null));

  void clearActionError() => emit(state.copyWith(clearActionError: true));

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

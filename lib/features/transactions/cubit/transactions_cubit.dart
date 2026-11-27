import 'package:finance_tracker/core/utils/error_message.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/features/transactions/cubit/transactions_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit(this._repo) : super(TransactionsState());

  final FinanceRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, clearError: true));
    try {
      final sources = await _repo.allSources();
      final categories = await _repo.allCategories();
      final templates = await _repo.templates();
      final page = await _repo.transactions();
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          sources: sources,
          categories: categories,
          templates: templates,
          page: page,
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

  // Filters are visual only in this phase: the list does not change.

  void setMonth(DateTime month) => emit(state.copyWith(month: month));

  /// Pass null for all sources.
  void setSourceFilter(String? sourceId) => emit(
    state.copyWith(sourceFilter: sourceId, clearSourceFilter: sourceId == null),
  );

  /// Pass null for all types.
  void setTypeFilter(TxType? type) =>
      emit(state.copyWith(typeFilter: type, clearTypeFilter: type == null));

  void setQuery(String query) => emit(state.copyWith(query: query));

  /// Selects the entry being edited; null leaves edit mode.
  void select(String? id) =>
      emit(state.copyWith(selectedId: id, clearSelected: id == null));
}

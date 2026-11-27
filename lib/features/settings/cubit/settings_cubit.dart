import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/category_input.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/source_input.dart';
import 'package:finance_tracker/core/utils/error_message.dart';
import 'package:finance_tracker/features/settings/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repo) : super(const SettingsState());

  final FinanceRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, clearError: true));
    try {
      final sources = await _repo.allSources();
      final usage = await _repo.categoryUsage();
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          sources: sources,
          categoryUsage: usage,
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

  /// Runs a write, then reloads the sources and category usage (without the
  /// page spinner). Returns an error message, or null on success.
  Future<String?> _write(Future<void> Function() action) async {
    try {
      await action();
      final sources = await _repo.allSources();
      final usage = await _repo.categoryUsage();
      if (!isClosed) {
        emit(state.copyWith(sources: sources, categoryUsage: usage));
      }
      return null;
    } catch (e) {
      return friendlyError(e);
    }
  }

  Future<String?> addSource(SourceInput input) =>
      _write(() => _repo.addSource(input));

  Future<String?> addCategory(CategoryInput input) =>
      _write(() => _repo.addCategory(input));

  /// Archives an active source or restores an archived one.
  Future<String?> toggleSourceActive(String id) {
    final source = state.sources.firstWhere((s) => s.id == id);
    return _write(() => _repo.setSourceActive(id, !source.isActive));
  }

  /// Archives an active category or restores an archived one.
  Future<String?> toggleCategoryActive(String id) {
    final category = state.categoryUsage
        .firstWhere((u) => u.category.id == id)
        .category;
    return _write(() => _repo.setCategoryActive(id, !category.isActive));
  }
}

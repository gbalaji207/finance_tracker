import 'package:finance_tracker/core/utils/error_message.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/features/templates/cubit/templates_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TemplatesCubit extends Cubit<TemplatesState> {
  TemplatesCubit(this._repo) : super(const TemplatesState());

  final FinanceRepository _repo;

  /// The entry that starts unchecked in the sample data (electricity bill).
  static const _initiallyUnchecked = 'o5';

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, clearError: true));
    try {
      final sources = await _repo.allSources();
      final categories = await _repo.allCategories();
      final templates = await _repo.templates();
      final previous = await _repo.previousMonthEntries(
        DateTime(appMonth().year, appMonth().month - 1),
      );
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          sources: sources,
          categories: categories,
          templates: templates,
          previousEntries: previous,
          selectedIds: {
            for (final e in previous)
              if (e.id != _initiallyUnchecked) e.id,
          },
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

  void toggleEntry(String id) {
    final next = {...state.selectedIds};
    if (!next.remove(id)) next.add(id);
    emit(state.copyWith(selectedIds: next));
  }
}

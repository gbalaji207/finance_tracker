import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/data/mock_clock.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/features/templates/cubit/templates_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TemplatesCubit extends Cubit<TemplatesState> {
  TemplatesCubit(this._repo) : super(const TemplatesState());

  final FinanceRepository _repo;

  /// The entry that starts unchecked in the sample data (electricity bill).
  static const _initiallyUnchecked = 'o5';

  Future<void> load() async {
    final sources = await _repo.sources();
    final categories = await _repo.categories();
    final templates = await _repo.templates();
    final previous = await _repo.previousMonthEntries(
      DateTime(mockMonth.year, mockMonth.month - 1),
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
  }

  void toggleEntry(String id) {
    final next = {...state.selectedIds};
    if (!next.remove(id)) next.add(id);
    emit(state.copyWith(selectedIds: next));
  }
}

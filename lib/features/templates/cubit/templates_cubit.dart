import 'dart:math' as math;

import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/entry_input.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/template_input.dart';
import 'package:finance_tracker/core/utils/error_message.dart';
import 'package:finance_tracker/features/templates/cubit/preselect.dart';
import 'package:finance_tracker/features/templates/cubit/templates_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TemplatesCubit extends Cubit<TemplatesState> {
  TemplatesCubit(this._repo) : super(const TemplatesState());

  final FinanceRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, clearError: true));
    try {
      final sources = await _repo.allSources();
      final categories = await _repo.allCategories();
      final templates = await _repo.templates();
      final now = appMonth();
      final previous = await _repo.previousMonthEntries(
        DateTime(now.year, now.month - 1),
      );
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          sources: sources,
          categories: categories,
          templates: templates,
          previousEntries: previous,
          selectedIds: preselectedIds(previous, templates),
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

  /// Saves a template, then reloads the list. Returns an error message, or
  /// null on success.
  Future<String?> addTemplate(TemplateInput input) async {
    emit(state.copyWith(saving: true));
    try {
      await _repo.addTemplate(input);
      final templates = await _repo.templates();
      if (isClosed) return null;
      emit(state.copyWith(templates: templates, saving: false));
      return null;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(saving: false));
      return friendlyError(e);
    }
  }

  /// Creates one entry in the current month for each ticked entry of last
  /// month, on the same day of the month (clamped to the month's last day).
  /// Returns an error message, or null on success.
  Future<String?> copySelected() async {
    final month = appMonth();
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final inputs = [
      for (final e in state.previousEntries)
        if (state.selectedIds.contains(e.id))
          EntryInput(
            date: DateTime(
              month.year,
              month.month,
              math.min(e.date.day, lastDay),
            ),
            type: e.type,
            sourceId: e.sourceId,
            categoryId: e.categoryId,
            amount: e.amount,
            description: e.description,
          ),
    ];
    if (inputs.isEmpty) return null;
    emit(state.copyWith(saving: true));
    try {
      await _repo.addEntries(inputs);
      if (!isClosed) emit(state.copyWith(saving: false));
      return null;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(saving: false));
      return friendlyError(e);
    }
  }
}

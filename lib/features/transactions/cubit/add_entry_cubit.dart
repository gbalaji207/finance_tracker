import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/features/transactions/cubit/add_entry_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEntryCubit extends Cubit<AddEntryState> {
  AddEntryCubit({required this.categories, required this.sources})
    : super(_initial(sources, categories));

  final List<Category> categories;
  final List<Source> sources;

  /// Expense and today. Source and category are left empty on purpose: a
  /// preselected first item led to entries on the wrong source or category,
  /// so the user must choose both (the form validates before saving).
  static AddEntryState _initial(
    List<Source> sources,
    List<Category> categories,
  ) => AddEntryState();

  /// The categories belong to one kind each, so a category chosen for the old
  /// type is dropped and has to be chosen again.
  void selectType(TxType type) =>
      emit(state.copyWith(type: type, clearCategory: true));

  void selectSource(String sourceId) =>
      emit(state.copyWith(sourceId: sourceId));

  void selectCategory(String? categoryId) => emit(
    state.copyWith(categoryId: categoryId, clearCategory: categoryId == null),
  );

  void selectDate(DateTime date) => emit(state.copyWith(date: date));

  /// Fills type, source and category from [template]; a template without a
  /// category leaves it to be chosen. The widget fills the amount and
  /// description fields from the returned template.
  EntryTemplate applyTemplate(EntryTemplate template) {
    final categoryId = template.type == TxType.income
        ? null
        : template.categoryId;
    emit(
      state.copyWith(
        type: template.type,
        sourceId: template.sourceId,
        categoryId: categoryId,
        clearCategory: categoryId == null,
      ),
    );
    return template;
  }

  /// Fills the form from an existing entry and enters edit mode.
  void startEdit(Transaction t) => emit(
    AddEntryState(
      type: t.type,
      sourceId: t.sourceId,
      categoryId: t.type == TxType.income ? null : t.categoryId,
      date: t.date,
      editingId: t.id,
    ),
  );

  /// Back to the defaults; also leaves edit mode.
  void reset() => emit(_initial(sources, categories));
}

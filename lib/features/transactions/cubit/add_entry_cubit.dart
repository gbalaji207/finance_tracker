import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/features/transactions/cubit/add_entry_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEntryCubit extends Cubit<AddEntryState> {
  AddEntryCubit({required this.categories, required this.sources})
      : super(AddEntryState());

  final List<Category> categories;
  final List<Source> sources;

  /// Income has no category; otherwise the first category of that kind.
  String? _defaultCategory(TxType type) {
    if (type == TxType.income) return null;
    for (final c in categories) {
      if (c.kind == type) return c.id;
    }
    return null;
  }

  void selectType(TxType type) {
    final categoryId = _defaultCategory(type);
    emit(
      state.copyWith(
        type: type,
        categoryId: categoryId,
        clearCategory: categoryId == null,
      ),
    );
  }

  void selectSource(String sourceId) =>
      emit(state.copyWith(sourceId: sourceId));

  void selectCategory(String? categoryId) => emit(
        state.copyWith(
          categoryId: categoryId,
          clearCategory: categoryId == null,
        ),
      );

  void selectDate(DateTime date) => emit(state.copyWith(date: date));

  /// Fills type, source and category from [template]. The widget fills the
  /// amount and description fields from the returned template.
  EntryTemplate applyTemplate(EntryTemplate template) {
    final categoryId = template.type == TxType.income
        ? null
        : (template.categoryId ?? _defaultCategory(template.type));
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

  void reset() => emit(AddEntryState());
}

import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/transaction.dart';

/// Ids of the entries that start ticked in "Copy from last month": those that
/// match a template with the same name as the entry's description, the same
/// source and the same type.
Set<String> preselectedIds(
  List<Transaction> entries,
  List<EntryTemplate> templates,
) {
  return {
    for (final e in entries)
      if (templates.any(
        (t) =>
            t.name == e.description &&
            t.sourceId == e.sourceId &&
            t.type == e.type,
      ))
        e.id,
  };
}

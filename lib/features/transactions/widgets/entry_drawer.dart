import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/widgets/info_box.dart';
import 'package:finance_tracker/core/widgets/side_drawer.dart';
import 'package:finance_tracker/features/transactions/cubit/add_entry_cubit.dart';
import 'package:finance_tracker/features/transactions/cubit/transactions_cubit.dart';
import 'package:finance_tracker/features/transactions/cubit/transactions_state.dart';
import 'package:finance_tracker/features/transactions/widgets/entry_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens the entry form in a side drawer. The page's two cubits are passed on,
/// because the drawer is a separate route.
///
/// [editing] is fixed for as long as the drawer is open: null adds a new
/// entry. The future completes when the drawer closes, however it closed.
Future<void> showEntryDrawer(
  BuildContext context, {
  required Future<bool> Function(Transaction entry) onDelete,
  Transaction? editing,
  EntryTemplate? initialTemplate,
}) {
  final transactions = context.read<TransactionsCubit>();
  final form = context.read<AddEntryCubit>();
  return showSideDrawer<void>(
    context,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: transactions),
        BlocProvider.value(value: form),
      ],
      child: EntryDrawer(
        editing: editing,
        initialTemplate: initialTemplate,
        onDelete: onDelete,
      ),
    ),
  );
}

class EntryDrawer extends StatelessWidget {
  const EntryDrawer({
    super.key,
    required this.onDelete,
    this.editing,
    this.initialTemplate,
  });

  final Transaction? editing;
  final EntryTemplate? initialTemplate;
  final Future<bool> Function(Transaction entry) onDelete;

  @override
  Widget build(BuildContext context) {
    return SideDrawer(
      child: BlocBuilder<TransactionsCubit, TransactionsState>(
        builder: (context, state) {
          if (state.activeSources.isEmpty) {
            return const InfoBox(
              child: Text('Add a source in Settings before adding entries.'),
            );
          }
          return EntryPanel(
            key: ValueKey(editing?.id ?? 'new'),
            editing: editing,
            templates: state.templates,
            initialTemplate: initialTemplate,
            sourceName: state.sourceName,
            sources: [
              for (final s in state.sources)
                if (s.isActive || s.id == editing?.sourceId) s,
            ],
            categories: [
              for (final c in state.categories)
                if (c.isActive || c.id == editing?.categoryId) c,
            ],
            onDelete: onDelete,
            onClose: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }
}

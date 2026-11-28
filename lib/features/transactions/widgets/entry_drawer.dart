import 'dart:math' as math;

import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/widgets/info_box.dart';
import 'package:finance_tracker/features/transactions/cubit/add_entry_cubit.dart';
import 'package:finance_tracker/features/transactions/cubit/transactions_cubit.dart';
import 'package:finance_tracker/features/transactions/cubit/transactions_state.dart';
import 'package:finance_tracker/features/transactions/widgets/entry_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens the entry form in a drawer that slides in from the right. The page's
/// two cubits are passed on, because the drawer is a separate route.
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
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: AppColors.scrim.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: transactions),
        BlocProvider.value(value: form),
      ],
      child: Align(
        alignment: Alignment.centerRight,
        child: EntryDrawer(
          editing: editing,
          initialTemplate: initialTemplate,
          onDelete: onDelete,
        ),
      ),
    ),
    transitionBuilder: (context, animation, _, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
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

  static const double _maxWidth = 480;

  final Transaction? editing;
  final EntryTemplate? initialTemplate;
  final Future<bool> Function(Transaction entry) onDelete;

  @override
  Widget build(BuildContext context) {
    final width = math.min(_maxWidth, MediaQuery.sizeOf(context).width);
    return Material(
      color: AppColors.surface,
      elevation: 8,
      child: Container(
        width: width,
        height: double.infinity,
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.cardBorder)),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: BlocBuilder<TransactionsCubit, TransactionsState>(
                builder: (context, state) {
                  if (state.activeSources.isEmpty) {
                    return const InfoBox(
                      child: Text(
                        'Add a source in Settings before adding entries.',
                      ),
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
            ),
            Positioned(
              top: AppSpacing.s12,
              right: AppSpacing.s12,
              child: IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

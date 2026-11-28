import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/utils/error_message.dart';
import 'package:finance_tracker/core/widgets/app_snack.dart';
import 'package:finance_tracker/core/widgets/error_view.dart';
import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/page_header.dart';
import 'package:finance_tracker/features/transactions/cubit/add_entry_cubit.dart';
import 'package:finance_tracker/features/transactions/cubit/transactions_cubit.dart';
import 'package:finance_tracker/features/transactions/cubit/transactions_state.dart';
import 'package:finance_tracker/features/transactions/widgets/delete_entry_dialog.dart';
import 'package:finance_tracker/features/transactions/widgets/entry_drawer.dart';
import 'package:finance_tracker/features/transactions/widgets/transactions_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key, this.templateId});

  /// A template to pre-fill the entry form with (from `?template=<id>`).
  final String? templateId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => TransactionsCubit(c.read<FinanceRepository>())..load(),
      child: _TransactionsView(templateId: templateId),
    );
  }
}

class _TransactionsView extends StatefulWidget {
  const _TransactionsView({this.templateId});

  final String? templateId;

  @override
  State<_TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<_TransactionsView> {
  /// The template is applied once per page instance.
  bool _templateApplied = false;

  /// Reads the source balance, then asks for confirmation.
  Future<bool> _confirmDelete(
    BuildContext context,
    TransactionsState state,
    Transaction entry,
  ) async {
    final double balance;
    try {
      balance = await context.read<FinanceRepository>().sourceBalance(
        entry.sourceId,
      );
    } catch (e) {
      if (context.mounted) AppSnack.error(context, friendlyError(e));
      return false;
    }
    if (!context.mounted) return false;
    final confirmed = await showDeleteEntryDialog(
      context,
      entry: entry,
      sourceName: state.sourceName(entry.sourceId),
      categoryName: state.categoryName(entry.categoryId),
      balanceBefore: balance,
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionsCubit, TransactionsState>(
      listenWhen: (p, c) => c.actionError != null && p.actionError == null,
      listener: (context, state) {
        AppSnack.error(context, state.actionError!);
        context.read<TransactionsCubit>().clearActionError();
      },
      builder: (context, state) {
        if (state.status == LoadStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == LoadStatus.error) {
          return ErrorView(
            message: state.errorMessage ?? '',
            onRetry: context.read<TransactionsCubit>().load,
          );
        }
        final cubit = context.read<TransactionsCubit>();
        EntryTemplate? initialTemplate;
        if (!_templateApplied && widget.templateId != null) {
          initialTemplate = state.templates
              .where((t) => t.id == widget.templateId)
              .firstOrNull;
          _templateApplied = true;
        }
        // The AddEntryCubit sits above the whole page: the list and the
        // header button start the form, and the drawer shows it.
        return BlocProvider(
          create: (_) => AddEntryCubit(
            categories: state.activeCategories,
            sources: state.activeSources,
          ),
          child: Builder(
            builder: (context) {
              if (initialTemplate != null) {
                final template = initialTemplate;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _openDrawer(context, template: template);
                });
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.s20,
                children: [
                  PageHeader(
                    title: 'Transactions',
                    subtitle: AppConfig.useSupabase
                        ? 'Your entries'
                        : 'Sample data',
                    actions: [
                      AppButton(
                        label: 'Copy from last month',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => context.go(AppRoutes.templates),
                      ),
                      AppButton(
                        label: 'New entry',
                        onPressed: () => _openDrawer(context),
                      ),
                    ],
                  ),
                  TransactionsListCard(
                    page: state.page!,
                    sources: state.sources,
                    month: state.month,
                    listLoading: state.listLoading,
                    sourceFilter: state.sourceFilter,
                    typeFilter: state.typeFilter,
                    sourceName: state.sourceName,
                    categoryName: state.categoryName,
                    onMonthChanged: cubit.setMonth,
                    onSourceChanged: cubit.setSourceFilter,
                    onTypeChanged: cubit.setTypeFilter,
                    onQueryChanged: cubit.setQuery,
                    onPageChanged: cubit.goToPage,
                    selectedId: state.selectedId,
                    onEdit: (t) => _openDrawer(context, editing: t),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Opens the entry drawer: add mode, or edit mode for [editing]. When the
  /// drawer closes without finishing (Esc, the backdrop, the X) any edit is
  /// dropped.
  Future<void> _openDrawer(
    BuildContext context, {
    Transaction? editing,
    EntryTemplate? template,
  }) async {
    final cubit = context.read<TransactionsCubit>();
    final form = context.read<AddEntryCubit>();
    if (editing == null) {
      cubit.select(null);
      form.reset();
    } else {
      cubit.select(editing.id);
      form.startEdit(editing);
    }
    await showEntryDrawer(
      context,
      editing: editing,
      initialTemplate: template,
      // Read the state when asked, not when the drawer opened.
      onDelete: (entry) => _confirmDelete(context, cubit.state, entry),
    );
    if (!mounted) return;
    if (cubit.state.selectedId != null) cubit.select(null);
    form.reset();
  }
}

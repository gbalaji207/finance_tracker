import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/page_header.dart';
import 'package:finance_tracker/core/widgets/two_pane.dart';
import 'package:finance_tracker/features/transactions/cubit/add_entry_cubit.dart';
import 'package:finance_tracker/features/transactions/cubit/transactions_cubit.dart';
import 'package:finance_tracker/features/transactions/cubit/transactions_state.dart';
import 'package:finance_tracker/features/transactions/widgets/entry_panel.dart';
import 'package:finance_tracker/features/transactions/widgets/transactions_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => TransactionsCubit(c.read<FinanceRepository>())..load(),
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
        if (state.status == LoadStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final cubit = context.read<TransactionsCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s20,
          children: [
            PageHeader(
              title: 'Transactions',
              subtitle: 'Sample data',
              actions: [
                AppButton(
                  label: 'Copy from last month',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.go(AppRoutes.templates),
                ),
              ],
            ),
            // The AddEntryCubit sits above both panes: the list starts edits
            // and the panel shows them.
            BlocProvider(
              create: (_) => AddEntryCubit(
                categories: state.categories,
                sources: state.sources,
              ),
              child: Builder(
                builder: (context) => TwoPane(
                  primaryMin: 560,
                  secondaryWidth: 340,
                  primary: TransactionsListCard(
                    page: state.page!,
                    sources: state.sources,
                    month: state.month,
                    sourceFilter: state.sourceFilter,
                    typeFilter: state.typeFilter,
                    sourceName: state.sourceName,
                    categoryName: state.categoryName,
                    onMonthChanged: cubit.setMonth,
                    onSourceChanged: cubit.setSourceFilter,
                    onTypeChanged: cubit.setTypeFilter,
                    onQueryChanged: cubit.setQuery,
                    selectedId: state.selectedId,
                    onEdit: (t) {
                      cubit.select(t.id);
                      context.read<AddEntryCubit>().startEdit(t);
                    },
                  ),
                  secondary: EntryPanel(
                    key: ValueKey(state.selected?.id ?? 'new'),
                    editing: state.selected,
                    templates: state.templates,
                    sourceName: state.sourceName,
                    sources: state.sources,
                    categories: state.categories,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

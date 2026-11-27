import 'package:finance_tracker/core/widgets/app_snack.dart';
import 'package:finance_tracker/core/widgets/empty_note.dart';
import 'package:finance_tracker/core/widgets/error_view.dart';
import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/month_selector.dart';
import 'package:finance_tracker/core/widgets/page_header.dart';
import 'package:finance_tracker/core/widgets/two_pane.dart';
import 'package:finance_tracker/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:finance_tracker/features/dashboard/cubit/dashboard_state.dart';
import 'package:finance_tracker/features/dashboard/widgets/bank_balance_dialog.dart';
import 'package:finance_tracker/features/dashboard/widgets/quick_add_card.dart';
import 'package:finance_tracker/features/dashboard/widgets/recent_entries_card.dart';
import 'package:finance_tracker/features/dashboard/widgets/reconciliation_strip.dart';
import 'package:finance_tracker/features/dashboard/widgets/source_cards_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => DashboardCubit(c.read<FinanceRepository>())..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  /// Opens the dialog with the current values; a result updates the strip.
  Future<void> _updateBankBalance(BuildContext context) async {
    final cubit = context.read<DashboardCubit>();
    final current = cubit.state.reconciliation;
    if (current == null) return;
    final result = await showBankBalanceDialog(
      context,
      sourcesTotal: current.sourcesTotal,
      currentBankBalance: current.bankBalance ?? current.sourcesTotal,
      asOf: current.asOf ?? appToday(),
    );
    if (result != null) cubit.updateBankBalance(result.balance, result.asOf);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listenWhen: (p, c) => c.actionError != null && p.actionError == null,
      listener: (context, state) {
        AppSnack.error(context, state.actionError!);
        context.read<DashboardCubit>().clearActionError();
      },
      builder: (context, state) {
        if (state.status == LoadStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == LoadStatus.error) {
          return ErrorView(
            message: state.errorMessage ?? '',
            onRetry: context.read<DashboardCubit>().load,
          );
        }
        final cubit = context.read<DashboardCubit>();
        final now = appMonth();
        final isCurrentMonth =
            state.month.year == now.year && state.month.month == now.month;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s24,
          children: [
            PageHeader(
              title: 'Dashboard',
              subtitle: AppConfig.useSupabase
                  ? 'Balances as on ${AppDates.dayMonthYear(appToday())}'
                  : 'Sample data · balances as on '
                        '${AppDates.dayMonthYear(appToday())}',
              actions: [
                MonthSelector(month: state.month, onChanged: cubit.changeMonth),
                AppButton(
                  label: '+ New entry',
                  onPressed: () => context.go(AppRoutes.transactions),
                ),
              ],
            ),
            ReconciliationStrip(
              data: state.reconciliation!,
              onUpdateBankBalance: () => _updateBankBalance(context),
            ),
            if (state.summaries.isEmpty)
              const EmptyNote('No sources yet. Add one in Settings.')
            else
              SourceCardsSection(
                summaries: state.summaries,
                balanceLabel: isCurrentMonth
                    ? 'Balance as on today'
                    : 'Balance at end of ${AppDates.monthYear(state.month)}',
                monthLabel: isCurrentMonth
                    ? 'This month'
                    : AppDates.monthYear(state.month),
              ),
            TwoPane(
              primary: RecentEntriesCard(
                entries: state.recent,
                sourceName: state.sourceName,
                onViewAll: () => context.go(AppRoutes.transactions),
              ),
              secondary: QuickAddCard(
                templates: state.quickAdd,
                sourceName: state.sourceName,
                onUse: (t) =>
                    context.go('${AppRoutes.transactions}?template=${t.id}'),
                onManage: () => context.go(AppRoutes.templates),
                onCopyLastMonth: () => context.go(AppRoutes.templates),
              ),
            ),
          ],
        );
      },
    );
  }
}

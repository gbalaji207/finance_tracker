import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/data/mock_clock.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/month_selector.dart';
import 'package:finance_tracker/core/widgets/page_header.dart';
import 'package:finance_tracker/core/widgets/section_placeholder.dart';
import 'package:finance_tracker/core/widgets/two_pane.dart';
import 'package:finance_tracker/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:finance_tracker/features/dashboard/cubit/dashboard_state.dart';
import 'package:finance_tracker/features/dashboard/widgets/reconciliation_strip.dart';
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

  void _notWired(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Not wired yet (sample data)')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.status == LoadStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final cubit = context.read<DashboardCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s24,
          children: [
            PageHeader(
              title: 'Dashboard',
              subtitle: 'Sample data · balances as on '
                  '${AppDates.dayMonthYear(mockToday)}',
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
              onUpdateBankBalance: () => _notWired(context),
            ),
            const SectionPlaceholder(name: 'Source balance cards', height: 300),
            const TwoPane(
              primary: SectionPlaceholder(name: 'Recent entries', height: 360),
              secondary: SectionPlaceholder(name: 'Quick add', height: 360),
            ),
          ],
        );
      },
    );
  }
}

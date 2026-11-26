import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/month_selector.dart';
import 'package:finance_tracker/core/widgets/page_header.dart';
import 'package:finance_tracker/core/widgets/section_placeholder.dart';
import 'package:finance_tracker/features/monthly_report/cubit/monthly_report_cubit.dart';
import 'package:finance_tracker/features/monthly_report/cubit/monthly_report_state.dart';
import 'package:finance_tracker/features/monthly_report/widgets/by_source_card.dart';
import 'package:finance_tracker/features/monthly_report/widgets/report_kpis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MonthlyReportPage extends StatelessWidget {
  const MonthlyReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => MonthlyReportCubit(c.read<FinanceRepository>())..load(),
      child: const _MonthlyReportView(),
    );
  }
}

class _MonthlyReportView extends StatelessWidget {
  const _MonthlyReportView();

  void _notWired(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Not wired yet (sample data)')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthlyReportCubit, MonthlyReportState>(
      builder: (context, state) {
        if (state.status == LoadStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final cubit = context.read<MonthlyReportCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s24,
          children: [
            PageHeader(
              title: 'Monthly report',
              subtitle:
                  'Sample data · all sources together, then split by source',
              actions: [
                MonthSelector(month: state.month, onChanged: cubit.changeMonth),
                AppButton(
                  label: 'Export CSV',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => _notWired(context),
                ),
              ],
            ),
            ReportKpis(report: state.report!),
            BySourceCard(report: state.report!),
            const SectionPlaceholder(name: 'Expenses by category', height: 260),
          ],
        );
      },
    );
  }
}

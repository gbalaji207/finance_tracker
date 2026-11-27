import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_snack.dart';
import 'package:finance_tracker/core/widgets/empty_note.dart';
import 'package:finance_tracker/core/widgets/error_view.dart';
import 'package:finance_tracker/core/widgets/page_header.dart';
import 'package:finance_tracker/features/source_report/cubit/source_report_cubit.dart';
import 'package:finance_tracker/features/source_report/cubit/source_report_state.dart';
import 'package:finance_tracker/features/source_report/widgets/income_vs_spend_card.dart';
import 'package:finance_tracker/features/source_report/widgets/month_by_month_card.dart';
import 'package:finance_tracker/features/source_report/widgets/source_summary_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SourceReportPage extends StatelessWidget {
  const SourceReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => SourceReportCubit(c.read<FinanceRepository>())..load(),
      child: const _SourceReportView(),
    );
  }
}

class _SourceReportView extends StatelessWidget {
  const _SourceReportView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SourceReportCubit, SourceReportState>(
      listenWhen: (p, c) => c.actionError != null && p.actionError == null,
      listener: (context, state) {
        AppSnack.error(context, state.actionError!);
        context.read<SourceReportCubit>().clearActionError();
      },
      builder: (context, state) {
        if (state.status == LoadStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == LoadStatus.error) {
          return ErrorView(
            message: state.errorMessage ?? '',
            onRetry: context.read<SourceReportCubit>().load,
          );
        }
        final cubit = context.read<SourceReportCubit>();
        final report = state.report;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s24,
          children: [
            PageHeader(
              title: 'Source-wise report',
              subtitle: AppConfig.useSupabase
                  ? 'One source over time'
                  : 'Sample data · one source over time',
              crossAlignment: WrapCrossAlignment.end,
              actions: [
                SizedBox(
                  width: 180,
                  child: AppDropdown<String>(
                    label: 'Source',
                    items: [
                      for (final s in state.sources)
                        AppDropdownItem(
                          s.id,
                          s.isActive ? s.name : '${s.name} (archived)',
                        ),
                    ],
                    value: state.selectedSourceId,
                    onChanged: (id) {
                      if (id != null) cubit.select(id);
                    },
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: AppDropdown<String>(
                    label: 'Period',
                    items: const [AppDropdownItem('6m', 'Last 6 months')],
                    value: '6m',
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
            if (report == null)
              const EmptyNote('No sources yet. Add one in Settings.')
            else ...[
              SourceSummaryTiles(report: report),
              IncomeVsSpendCard(months: report.months),
              MonthByMonthCard(months: report.months),
            ],
          ],
        );
      },
    );
  }
}

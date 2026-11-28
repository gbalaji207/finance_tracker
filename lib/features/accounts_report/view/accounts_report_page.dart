import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/widgets/app_snack.dart';
import 'package:finance_tracker/core/widgets/error_view.dart';
import 'package:finance_tracker/core/widgets/page_header.dart';
import 'package:finance_tracker/features/accounts_report/cubit/accounts_report_cubit.dart';
import 'package:finance_tracker/features/accounts_report/cubit/accounts_report_state.dart';
import 'package:finance_tracker/features/accounts_report/widgets/ledger_summary.dart';
import 'package:finance_tracker/features/accounts_report/widgets/ledger_table_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountsReportPage extends StatelessWidget {
  const AccountsReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => AccountsReportCubit(c.read<FinanceRepository>())..load(),
      child: const _AccountsReportView(),
    );
  }
}

class _AccountsReportView extends StatelessWidget {
  const _AccountsReportView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountsReportCubit, AccountsReportState>(
      listenWhen: (p, c) => c.actionError != null && p.actionError == null,
      listener: (context, state) {
        AppSnack.error(context, state.actionError!);
        context.read<AccountsReportCubit>().clearActionError();
      },
      builder: (context, state) {
        if (state.status == LoadStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final ledger = state.ledger;
        if (state.status == LoadStatus.error || ledger == null) {
          return ErrorView(
            message: state.errorMessage ?? '',
            onRetry: context.read<AccountsReportCubit>().load,
          );
        }
        final cubit = context.read<AccountsReportCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s20,
          children: [
            PageHeader(
              title: 'Accounts report',
              subtitle: AppConfig.useSupabase
                  ? 'Every credit and debit with a running balance'
                  : 'Sample data · every credit and debit with a running '
                        'balance',
            ),
            LedgerSummary(
              ledger: ledger,
              typeFiltered: state.typeFilter != null,
            ),
            LedgerTableCard(
              ledger: ledger,
              bankAccounts: state.bankAccounts,
              sources: state.sourcesForFilter,
              from: state.from,
              to: state.to,
              bankAccountFilter: state.bankAccountFilter,
              sourceFilter: state.sourceFilter,
              typeFilter: state.typeFilter,
              listLoading: state.listLoading,
              onRangeChanged: cubit.setRange,
              onBankAccountChanged: cubit.setBankAccountFilter,
              onSourceChanged: cubit.setSourceFilter,
              onTypeChanged: cubit.setTypeFilter,
              onPageChanged: cubit.goToPage,
            ),
          ],
        );
      },
    );
  }
}

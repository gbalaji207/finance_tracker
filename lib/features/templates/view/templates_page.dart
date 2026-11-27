import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/widgets/app_snack.dart';
import 'package:finance_tracker/core/widgets/error_view.dart';
import 'package:finance_tracker/core/widgets/page_header.dart';
import 'package:finance_tracker/core/widgets/two_pane.dart';
import 'package:finance_tracker/features/templates/cubit/templates_cubit.dart';
import 'package:finance_tracker/features/templates/cubit/templates_state.dart';
import 'package:finance_tracker/features/templates/widgets/copy_last_month_card.dart';
import 'package:finance_tracker/features/templates/widgets/new_template_card.dart';
import 'package:finance_tracker/features/templates/widgets/templates_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => TemplatesCubit(c.read<FinanceRepository>())..load(),
      child: const _TemplatesView(),
    );
  }
}

class _TemplatesView extends StatelessWidget {
  const _TemplatesView();

  void _notWired(BuildContext context) =>
      AppSnack.info(context, 'Not wired yet (sample data)');

  Future<void> _copy(BuildContext context, TemplatesState state) async {
    final count = state.selectedCount;
    final monthName = AppDates.monthName(appMonth());
    final error = await context.read<TemplatesCubit>().copySelected();
    if (!context.mounted) return;
    if (error != null) {
      AppSnack.error(context, error);
      return;
    }
    AppSnack.info(
      context,
      AppConfig.note(
        'Copied $count ${count == 1 ? 'entry' : 'entries'} to $monthName',
      ),
    );
    context.go(AppRoutes.transactions);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemplatesCubit, TemplatesState>(
      builder: (context, state) {
        if (state.status == LoadStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == LoadStatus.error) {
          return ErrorView(
            message: state.errorMessage ?? '',
            onRetry: context.read<TemplatesCubit>().load,
          );
        }
        final thisMonth = appMonth();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s24,
          children: [
            PageHeader(
              title: 'Templates and copy last month',
              subtitle: AppConfig.useSupabase
                  ? 'Nothing is created automatically; '
                        'these only pre-fill the entry form'
                  : 'Sample data · nothing is created automatically; '
                        'these only pre-fill the entry form',
            ),
            TwoPane(
              primaryMin: 560,
              secondaryWidth: 340,
              primary: TemplatesListCard(
                templates: state.templates,
                sourceName: state.sourceName,
                categoryName: state.categoryName,
                onUse: (t) =>
                    context.go('${AppRoutes.transactions}?template=${t.id}'),
                onEdit: (_) => _notWired(context),
              ),
              secondary: NewTemplateCard(
                sources: state.activeSources,
                categories: state.activeCategories,
                nextSortOrder: state.nextSortOrder,
                onSave: context.read<TemplatesCubit>().addTemplate,
              ),
            ),
            CopyLastMonthCard(
              entries: state.previousEntries,
              selectedIds: state.selectedIds,
              sourceName: state.sourceName,
              previousMonth: DateTime(thisMonth.year, thisMonth.month - 1),
              thisMonth: thisMonth,
              saving: state.saving,
              onToggle: context.read<TemplatesCubit>().toggleEntry,
              onCopy: () => _copy(context, state),
            ),
          ],
        );
      },
    );
  }
}

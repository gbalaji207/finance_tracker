import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
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

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _notWired(BuildContext context) =>
      _showMessage(context, 'Not wired yet (sample data)');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemplatesCubit, TemplatesState>(
      builder: (context, state) {
        if (state.status == LoadStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
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
                onUse: (_) => context.go(AppRoutes.transactions),
                onEdit: (_) => _notWired(context),
              ),
              secondary: NewTemplateCard(
                sources: state.sources,
                categories: state.categories,
                onSave: () => _notWired(context),
              ),
            ),
            CopyLastMonthCard(
              entries: state.previousEntries,
              selectedIds: state.selectedIds,
              sourceName: state.sourceName,
              onToggle: context.read<TemplatesCubit>().toggleEntry,
              onCopy: () => _showMessage(
                context,
                'Copied ${state.selectedCount} entries '
                '(sample data, nothing is created yet)',
              ),
            ),
          ],
        );
      },
    );
  }
}

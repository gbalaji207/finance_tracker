import 'package:finance_tracker/core/widgets/error_view.dart';
import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/widgets/page_header.dart';
import 'package:finance_tracker/core/widgets/two_pane.dart';
import 'package:finance_tracker/features/auth/cubit/auth_cubit.dart';
import 'package:finance_tracker/features/settings/cubit/settings_cubit.dart';
import 'package:finance_tracker/features/settings/cubit/settings_state.dart';
import 'package:finance_tracker/features/settings/widgets/account_card.dart';
import 'package:finance_tracker/features/settings/widgets/categories_card.dart';
import 'package:finance_tracker/features/settings/widgets/new_category_card.dart';
import 'package:finance_tracker/features/settings/widgets/new_source_card.dart';
import 'package:finance_tracker/features/settings/widgets/sources_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => SettingsCubit(c.read<FinanceRepository>())..load(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  void _notWired(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Not wired yet (sample data)')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state.status == LoadStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == LoadStatus.error) {
          return ErrorView(
            message: state.errorMessage ?? '',
            onRetry: context.read<SettingsCubit>().load,
          );
        }
        final cubit = context.read<SettingsCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s24,
          children: [
            const PageHeader(
              title: 'Settings',
              subtitle: AppConfig.useSupabase
                  ? 'Sources, categories and your account'
                  : 'Sample data · sources, categories and your account',
            ),
            TwoPane(
              primaryMin: 560,
              secondaryWidth: 340,
              primary: SourcesCard(
                sources: state.sources,
                onEdit: (_) => _notWired(context),
                onToggleActive: (s) => cubit.toggleSourceActive(s.id),
              ),
              secondary: NewSourceCard(onSave: () => _notWired(context)),
            ),
            TwoPane(
              primaryMin: 560,
              secondaryWidth: 340,
              primary: CategoriesCard(
                categories: state.categoryUsage,
                onEdit: (_) => _notWired(context),
                onArchive: (_) => _notWired(context),
              ),
              secondary: NewCategoryCard(onSave: () => _notWired(context)),
            ),
            AccountCard(
              email: context.watch<AuthCubit>().state.email,
              onChangePassword: () => _notWired(context),
              onSignOut: () {
                context.read<AuthCubit>().signOut();
                context.go(AppRoutes.login);
              },
            ),
          ],
        );
      },
    );
  }
}

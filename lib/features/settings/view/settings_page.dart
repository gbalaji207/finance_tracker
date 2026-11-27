import 'package:finance_tracker/core/widgets/app_snack.dart';
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
import 'package:finance_tracker/features/settings/widgets/bank_account_form_card.dart';
import 'package:finance_tracker/features/settings/widgets/bank_accounts_card.dart';
import 'package:finance_tracker/features/settings/widgets/categories_card.dart';
import 'package:finance_tracker/features/settings/widgets/new_category_card.dart';
import 'package:finance_tracker/features/settings/widgets/source_form_card.dart';
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

  void _notWired(BuildContext context) =>
      AppSnack.info(context, 'Not wired yet (sample data)');

  /// Shows a SnackBar when [action] resolves to an error message.
  Future<void> _report(BuildContext context, Future<String?> action) async {
    final error = await action;
    if (error != null && context.mounted) AppSnack.error(context, error);
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
                  ? 'Bank accounts, sources, categories and your account'
                  : 'Sample data · bank accounts, sources, categories and '
                        'your account',
            ),
            TwoPane(
              primaryMin: 560,
              secondaryWidth: 340,
              primary: BankAccountsCard(
                accounts: state.bankAccounts,
                editingId: state.editingBankAccountId,
                onEdit: (a) => cubit.startEditBankAccount(a.id),
                onToggleActive: (a) =>
                    _report(context, cubit.toggleBankAccountActive(a.id)),
              ),
              secondary: BankAccountFormCard(
                key: ValueKey(state.editingBankAccountId ?? 'new'),
                editing: state.editingBankAccount,
                onSave: state.editingBankAccount == null
                    ? cubit.addBankAccount
                    : (name) => cubit.renameBankAccount(
                        state.editingBankAccount!.id,
                        name,
                      ),
                onCancel: cubit.cancelEdit,
              ),
            ),
            TwoPane(
              primaryMin: 560,
              secondaryWidth: 340,
              primary: SourcesCard(
                sources: state.sources,
                editingId: state.editingSourceId,
                onEdit: (s) => cubit.startEditSource(s.id),
                onToggleActive: (s) =>
                    _report(context, cubit.toggleSourceActive(s.id)),
              ),
              secondary: SourceFormCard(
                key: ValueKey(state.editingSourceId ?? 'new'),
                bankAccounts: state.accountsForSourceForm,
                editing: state.editingSource,
                onSave: state.editingSource == null
                    ? cubit.addSource
                    : (input) =>
                          cubit.updateSource(state.editingSource!.id, input),
                onCancel: cubit.cancelEdit,
              ),
            ),
            TwoPane(
              primaryMin: 560,
              secondaryWidth: 340,
              primary: CategoriesCard(
                categories: state.categoryUsage,
                onEdit: (_) => _notWired(context),
                onToggleActive: (c) =>
                    _report(context, cubit.toggleCategoryActive(c.id)),
              ),
              secondary: NewCategoryCard(onSave: cubit.addCategory),
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

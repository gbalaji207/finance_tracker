import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/bank_account.dart';
import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/widgets/app_snack.dart';
import 'package:finance_tracker/core/widgets/app_tab_bar.dart';
import 'package:finance_tracker/core/widgets/error_view.dart';
import 'package:finance_tracker/core/widgets/page_header.dart';
import 'package:finance_tracker/core/widgets/side_drawer.dart';
import 'package:finance_tracker/features/auth/cubit/auth_cubit.dart';
import 'package:finance_tracker/features/settings/cubit/settings_cubit.dart';
import 'package:finance_tracker/features/settings/cubit/settings_state.dart';
import 'package:finance_tracker/features/settings/widgets/account_card.dart';
import 'package:finance_tracker/features/settings/widgets/bank_account_form.dart';
import 'package:finance_tracker/features/settings/widgets/bank_accounts_card.dart';
import 'package:finance_tracker/features/settings/widgets/categories_card.dart';
import 'package:finance_tracker/features/settings/widgets/category_form.dart';
import 'package:finance_tracker/features/settings/widgets/source_form.dart';
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

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  static const _tabs = ['Bank accounts', 'Sources', 'Categories', 'Account'];

  int _tab = 0;

  void _notWired(BuildContext context) =>
      AppSnack.info(context, 'Not wired yet (sample data)');

  /// Shows a SnackBar when [action] resolves to an error message.
  Future<void> _report(BuildContext context, Future<String?> action) async {
    final error = await action;
    if (error != null && context.mounted) AppSnack.error(context, error);
  }

  /// Runs [open] (which shows a drawer) and, once the drawer is closed in any
  /// way, leaves edit mode so the highlighted row clears.
  Future<void> _whileEditing(
    SettingsCubit cubit,
    Future<void> Function() open,
  ) async {
    await open();
    if (mounted && !cubit.isClosed) cubit.cancelEdit();
  }

  Future<void> _openBankAccount(BuildContext context, {BankAccount? editing}) {
    final cubit = context.read<SettingsCubit>();
    if (editing != null) cubit.startEditBankAccount(editing.id);
    return _whileEditing(
      cubit,
      () => showSideDrawer<void>(
        context,
        builder: (ctx) => SideDrawer(
          child: BankAccountForm(
            editing: editing,
            onSave: editing == null
                ? cubit.addBankAccount
                : (name) => cubit.renameBankAccount(editing.id, name),
            onClose: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }

  Future<void> _openSource(BuildContext context, {Source? editing}) {
    final cubit = context.read<SettingsCubit>();
    if (editing != null) cubit.startEditSource(editing.id);
    // Read after startEditSource: the list includes the edited source's
    // current account even if it is archived.
    final accounts = cubit.state.accountsForSourceForm;
    return _whileEditing(
      cubit,
      () => showSideDrawer<void>(
        context,
        builder: (ctx) => SideDrawer(
          child: SourceForm(
            bankAccounts: accounts,
            editing: editing,
            onSave: editing == null
                ? cubit.addSource
                : (input) => cubit.updateSource(editing.id, input),
            onClose: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }

  Future<void> _openCategory(BuildContext context, {Category? editing}) {
    final cubit = context.read<SettingsCubit>();
    if (editing != null) cubit.startEditCategory(editing.id);
    return _whileEditing(
      cubit,
      () => showSideDrawer<void>(
        context,
        builder: (ctx) => SideDrawer(
          child: CategoryForm(
            editing: editing,
            onSave: editing == null
                ? cubit.addCategory
                : (input) => cubit.renameCategory(editing.id, input.name),
            onClose: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }

  Widget _tabBody(BuildContext context, SettingsState state) {
    final cubit = context.read<SettingsCubit>();
    switch (_tab) {
      case 0:
        return BankAccountsCard(
          accounts: state.bankAccounts,
          editingId: state.editingBankAccountId,
          onAdd: () => _openBankAccount(context),
          onEdit: (a) => _openBankAccount(context, editing: a),
          onToggleActive: (a) =>
              _report(context, cubit.toggleBankAccountActive(a.id)),
        );
      case 1:
        return SourcesCard(
          sources: state.sources,
          editingId: state.editingSourceId,
          onAdd: () => _openSource(context),
          onEdit: (s) => _openSource(context, editing: s),
          onToggleActive: (s) =>
              _report(context, cubit.toggleSourceActive(s.id)),
        );
      case 2:
        return CategoriesCard(
          categories: state.categoryUsage,
          editingId: state.editingCategoryId,
          onAdd: () => _openCategory(context),
          onEdit: (c) => _openCategory(context, editing: c),
          onToggleActive: (c) =>
              _report(context, cubit.toggleCategoryActive(c.id)),
        );
      default:
        return AccountCard(
          email: context.watch<AuthCubit>().state.email,
          onChangePassword: () => _notWired(context),
          onSignOut: () {
            context.read<AuthCubit>().signOut();
            context.go(AppRoutes.login);
          },
        );
    }
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s20,
          children: [
            const PageHeader(
              title: 'Settings',
              subtitle: AppConfig.useSupabase
                  ? 'Bank accounts, sources, categories and your account'
                  : 'Sample data · bank accounts, sources, categories and '
                        'your account',
            ),
            AppTabBar(
              tabs: _tabs,
              selected: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            _tabBody(context, state),
          ],
        );
      },
    );
  }
}

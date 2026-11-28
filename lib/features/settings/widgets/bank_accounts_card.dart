import 'package:finance_tracker/core/models/bank_account.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_badge.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:finance_tracker/features/settings/widgets/list_card_header.dart';
import 'package:flutter/material.dart';

class BankAccountsCard extends StatelessWidget {
  const BankAccountsCard({
    super.key,
    required this.accounts,
    required this.onAdd,
    required this.onEdit,
    this.editingId,
    required this.onToggleActive,
  });

  final List<BankAccountUsage> accounts;
  final VoidCallback onAdd;
  final ValueChanged<BankAccount> onEdit;

  /// The account being renamed; its row is highlighted.
  final String? editingId;

  /// Archives an active account or restores an archived one.
  final ValueChanged<BankAccount> onToggleActive;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListCardHeader(
            title: 'Bank accounts',
            subtitle:
                'Each source belongs to one bank account. The dashboard '
                "compares each account's statement balance with the balances "
                'of its sources.',
            addLabel: 'Add bank account',
            onAdd: onAdd,
          ),
          const SizedBox(height: AppSpacing.s16),
          AppTable(
            minWidth: 480,
            columns: const [
              AppTableColumn('Name', flex: 1.2),
              AppTableColumn(
                'Active sources',
                width: 110,
                align: TextAlign.right,
              ),
              AppTableColumn(
                'Status',
                width: 96,
                mobile: AppTableMobile.trailing,
              ),
              AppTableColumn(
                'Actions',
                width: 130,
                align: TextAlign.right,
                mobile: AppTableMobile.action,
              ),
            ],
            rows: [
              for (final u in accounts)
                AppTableRow(
                  background: u.account.id == editingId
                      ? AppColors.rowSelected
                      : null,
                  [
                    Text(u.account.name, style: AppTextStyles.bodyStrong),
                    AppTableText('${u.activeSourceCount}'),
                    u.account.isActive
                        ? const AppBadge(
                            text: 'Active',
                            background: AppColors.incomeBg,
                            foreground: AppColors.income,
                          )
                        : const AppBadge(
                            text: 'Archived',
                            background: AppColors.neutralBg,
                            foreground: AppColors.neutralFg,
                          ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppSpacing.s16,
                      children: [
                        AppTextLink(
                          label: 'Edit',
                          onPressed: () => onEdit(u.account),
                        ),
                        AppTextLink(
                          label: u.account.isActive ? 'Archive' : 'Restore',
                          onPressed: () => onToggleActive(u.account),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

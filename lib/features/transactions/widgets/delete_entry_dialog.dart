import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/utils/balance_math.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/amount_text.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_dialog.dart';
import 'package:finance_tracker/core/widgets/info_box.dart';
import 'package:flutter/material.dart';

/// Asks the user to confirm deleting [entry]. Completes with `true` when the
/// entry should be deleted, `false` on Cancel, and null when dismissed.
Future<bool?> showDeleteEntryDialog(
  BuildContext context, {
  required Transaction entry,
  required String sourceName,
  required String categoryName,
  required double balanceBefore,
}) {
  return showAppDialog<bool>(
    context,
    (_) => DeleteEntryDialog(
      entry: entry,
      sourceName: sourceName,
      categoryName: categoryName,
      balanceBefore: balanceBefore,
    ),
  );
}

class DeleteEntryDialog extends StatelessWidget {
  const DeleteEntryDialog({
    super.key,
    required this.entry,
    required this.sourceName,
    required this.categoryName,
    required this.balanceBefore,
  });

  final Transaction entry;
  final String sourceName;

  /// "—" when the entry has no category.
  final String categoryName;
  final double balanceBefore;

  @override
  Widget build(BuildContext context) {
    final balanceAfter = BalanceMath.afterDeleting(entry, balanceBefore);
    return AppDialog(
      title: 'Delete this entry?',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s16,
        children: [
          InfoBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: AppSpacing.s12,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.description, style: AppTextStyles.bodyStrong),
                      const SizedBox(height: 2),
                      Text(
                        '${AppDates.dayMonthYear(entry.date)} · '
                        '$sourceName · $categoryName',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                AmountText(amount: entry.amount, type: entry.type),
              ],
            ),
          ),
          Text(
            'Deleting this entry changes the $sourceName balance. '
            'This cannot be undone.',
            style: AppTextStyles.bodySecondary,
          ),
          InfoBox(
            bordered: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: AppSpacing.s12,
              children: [
                Flexible(
                  child: Text(
                    '$sourceName balance',
                    style: AppTextStyles.rowLabel,
                  ),
                ),
                Text(
                  '${Money.plain(balanceBefore)} → ${Money.plain(balanceAfter)}',
                  style: AppTextStyles.rowValue,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.large,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: 'Delete entry',
          variant: AppButtonVariant.danger,
          size: AppButtonSize.large,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

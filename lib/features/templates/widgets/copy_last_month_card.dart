import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/widgets/amount_text.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/empty_note.dart';
import 'package:finance_tracker/core/widgets/labeled_checkbox.dart';
import 'package:flutter/material.dart';

class CopyLastMonthCard extends StatelessWidget {
  const CopyLastMonthCard({
    super.key,
    required this.entries,
    required this.selectedIds,
    required this.sourceName,
    required this.previousMonth,
    required this.thisMonth,
    required this.onToggle,
    required this.onCopy,
    this.saving = false,
  });

  final List<Transaction> entries;
  final Set<String> selectedIds;
  final String Function(String sourceId) sourceName;

  /// First day of the month the entries come from, and of the current month.
  final DateTime previousMonth;
  final DateTime thisMonth;
  final ValueChanged<String> onToggle;
  final VoidCallback onCopy;

  /// True while the copy is running; the button is disabled meanwhile.
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final fromLabel = AppDates.monthYear(previousMonth);
    final toLabel = AppDates.monthName(thisMonth);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.s12,
            runSpacing: AppSpacing.s12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Copy from $fromLabel',
                    style: AppTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'Tick the entries to re-create in $toLabel. '
                    'You can edit amounts after copying.',
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ),
              AppButton(
                label: 'Copy ${selectedIds.length} selected to $toLabel',
                size: AppButtonSize.large,
                onPressed: selectedIds.isEmpty || saving ? null : onCopy,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          if (entries.isEmpty) const EmptyNote('No entries last month.'),
          for (final e in entries)
            Container(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.controlHeight,
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                spacing: AppSpacing.s12,
                children: [
                  Expanded(
                    child: LabeledCheckbox(
                      value: selectedIds.contains(e.id),
                      onChanged: (_) => onToggle(e.id),
                      label: Text(
                        e.description,
                        style: AppTextStyles.bodyStrong,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      sourceName(e.sourceId),
                      style: AppTextStyles.body,
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: AmountText(amount: e.amount, type: e.type),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

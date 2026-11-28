import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:flutter/material.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.month,
    required this.onChanged,
  });

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.controlBorder),
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _arrow(
            icon: Icons.chevron_left,
            tooltip: 'Previous month',
            onPressed: () => onChanged(DateTime(month.year, month.month - 1)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
            child: Text(
              AppDates.monthYear(month),
              style: AppTextStyles.bodyStrong,
            ),
          ),
          _arrow(
            icon: Icons.chevron_right,
            tooltip: 'Next month',
            onPressed: () => onChanged(DateTime(month.year, month.month + 1)),
          ),
        ],
      ),
    );
  }

  Widget _arrow({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) => SizedBox(
    width: AppSpacing.controlHeight,
    height: AppSpacing.controlHeight,
    child: IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 22, color: AppColors.textPrimary),
    ),
  );
}

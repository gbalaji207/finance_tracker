import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class TypeSelector extends StatelessWidget {
  const TypeSelector({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
  });

  final String? label;
  final TxType value;
  final ValueChanged<TxType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.s6),
        ],
        Row(
          spacing: AppSpacing.s6,
          children: [
            for (final type in TxType.values)
              Expanded(
                child: _TypeButton(
                  type: type,
                  selected: type == value,
                  onTap: () => onChanged(type),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final TxType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.radiusControl);
    return Semantics(
      selected: selected,
      button: true,
      child: SizedBox(
        height: AppSpacing.controlHeight,
        child: OutlinedButton(
          onPressed: onTap,
          style: ButtonStyle(
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            ),
            minimumSize: const WidgetStatePropertyAll(Size.zero),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: radius),
            ),
            backgroundColor: WidgetStatePropertyAll(
              selected ? AppColors.primaryTint : AppColors.surface,
            ),
            side: WidgetStatePropertyAll(
              selected
                  ? const BorderSide(color: AppColors.primary, width: 1.5)
                  : const BorderSide(color: AppColors.inputBorder),
            ),
            mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              type.label,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

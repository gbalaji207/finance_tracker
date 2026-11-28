import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/field_frame.dart';
import 'package:flutter/material.dart';

class AppDropdownItem<T> {
  const AppDropdownItem(this.value, this.label);

  final T value;
  final String label;
}

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    this.label,
    required this.items,
    this.value,
    this.hintText,
    this.onChanged,
    this.helperText,
  });

  final String? label;
  final List<AppDropdownItem<T>> items;
  final T? value;
  final String? hintText;
  final ValueChanged<T?>? onChanged;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return FieldFrame(
      label: label,
      helperText: helperText,
      child: DropdownButtonFormField<T>(
        // Rebuild when the selected value changes from outside.
        key: ValueKey(value),
        initialValue: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        dropdownColor: AppColors.surface,
        style: AppTextStyles.body,
        decoration: FieldFrame.decoration(hintText: hintText),
        items: [
          for (final item in items)
            DropdownMenuItem<T>(
              value: item.value,
              child: Text(
                item.label,
                style: AppTextStyles.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

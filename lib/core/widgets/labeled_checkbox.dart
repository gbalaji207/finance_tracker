import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      mouseCursor: SystemMouseCursors.click,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.controlHeight),
        child: Row(
          spacing: AppSpacing.s12,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            Expanded(child: label),
          ],
        ),
      ),
    );
  }
}

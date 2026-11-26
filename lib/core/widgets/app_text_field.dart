import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/field_frame.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.controller,
    this.keyboardType,
    this.onChanged,
  });

  final String? label;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return FieldFrame(
      label: label,
      helperText: helperText,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: AppTextStyles.body,
        textAlignVertical: TextAlignVertical.center,
        decoration: FieldFrame.decoration(hintText: hintText),
      ),
    );
  }
}

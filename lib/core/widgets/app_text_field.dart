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
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
    this.focusNode,
  });

  final String? label;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return FieldFrame(
      label: label,
      helperText: helperText,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        onChanged: onChanged,
        obscureText: obscureText,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        autofillHints: autofillHints,
        style: AppTextStyles.body,
        textAlignVertical: TextAlignVertical.center,
        decoration: FieldFrame.decoration(hintText: hintText),
      ),
    );
  }
}

import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppSnack {
  static void info(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static void error(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      );
  }
}

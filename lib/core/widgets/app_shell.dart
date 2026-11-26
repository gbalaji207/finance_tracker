import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/widgets/app_sidebar.dart';
import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.location,
    required this.onNavigate,
    required this.child,
  });

  final String location;
  final ValueChanged<String> onNavigate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSidebar(location: location, onNavigate: onNavigate),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.pageV,
                horizontal: AppSpacing.pageH,
              ),
              child: SizedBox(width: double.infinity, child: child),
            ),
          ),
        ],
      ),
    );
  }
}

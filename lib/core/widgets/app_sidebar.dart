import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.location,
    required this.onNavigate,
  });

  final String location;
  final ValueChanged<String> onNavigate;

  static const _items = <(String, String)>[
    ('Dashboard', AppRoutes.dashboard),
    ('Transactions', AppRoutes.transactions),
    ('Monthly report', AppRoutes.monthlyReport),
    ('Source report', AppRoutes.sourceReport),
    ('Accounts report', AppRoutes.accountsReport),
    ('Templates', AppRoutes.templates),
    ('Settings', AppRoutes.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.sidebarWidth,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.s24,
        horizontal: AppSpacing.s16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s4,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s12,
              0,
              AppSpacing.s12,
              AppSpacing.s20,
            ),
            child: Text('Money Tracker', style: AppTextStyles.brand),
          ),
          for (final (label, route) in _items)
            _NavItem(
              label: label,
              active: location.startsWith(route),
              onTap: () => onNavigate(route),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.radiusControl);
    return Semantics(
      selected: active,
      button: true,
      child: Material(
        color: active ? AppColors.primaryTint : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          mouseCursor: SystemMouseCursors.click,
          hoverColor: active ? Colors.transparent : AppColors.navHover,
          child: Container(
            constraints:
                const BoxConstraints(minHeight: AppSpacing.controlHeight),
            padding: const EdgeInsets.all(AppSpacing.s12),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: active
                  ? AppTextStyles.navItemActive
                  : AppTextStyles.navItem,
            ),
          ),
        ),
      ),
    );
  }
}

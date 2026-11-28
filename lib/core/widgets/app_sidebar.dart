import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

const _navItems = <(String, String, IconData)>[
  ('Dashboard', AppRoutes.dashboard, Icons.dashboard_outlined),
  ('Transactions', AppRoutes.transactions, Icons.receipt_long_outlined),
  ('Monthly report', AppRoutes.monthlyReport, Icons.calendar_month_outlined),
  ('Source report', AppRoutes.sourceReport, Icons.pie_chart_outline),
  ('Accounts report', AppRoutes.accountsReport, Icons.account_balance_outlined),
  ('Templates', AppRoutes.templates, Icons.content_copy_outlined),
  ('Settings', AppRoutes.settings, Icons.settings_outlined),
];

/// Permanent sidebar for wide screens. Expanded (labels) or collapsed to an
/// icon rail; [onToggleCollapsed] flips between the two.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.location,
    required this.onNavigate,
    this.collapsed = false,
    this.onToggleCollapsed,
  });

  final String location;
  final ValueChanged<String> onNavigate;
  final bool collapsed;
  final VoidCallback? onToggleCollapsed;

  @override
  Widget build(BuildContext context) {
    final width = collapsed
        ? AppSpacing.sidebarRailWidth
        : AppSpacing.sidebarWidth;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: width,
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.s24,
        horizontal: collapsed ? AppSpacing.s12 : AppSpacing.s16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.cardBorder)),
      ),
      // The content is laid out for the final width so labels never wrap
      // mid-animation; the container clips the overflow.
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: 0,
        maxWidth: collapsed
            ? AppSpacing.sidebarRailWidth - AppSpacing.s12 * 2
            : AppSpacing.sidebarWidth - AppSpacing.s16 * 2,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.s4,
            children: [
              _Header(
                collapsed: collapsed,
                onToggleCollapsed: onToggleCollapsed,
              ),
              for (final (label, route, icon) in _navItems)
                NavItem(
                  label: label,
                  icon: icon,
                  active: location.startsWith(route),
                  collapsed: collapsed,
                  onTap: () => onNavigate(route),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-text menu used inside the mobile drawer.
class AppNavDrawer extends StatelessWidget {
  const AppNavDrawer({
    super.key,
    required this.location,
    required this.onNavigate,
  });

  final String location;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.s24,
            horizontal: AppSpacing.s16,
          ),
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
            for (final (label, route, icon) in _navItems)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s4),
                child: NavItem(
                  label: label,
                  icon: icon,
                  active: location.startsWith(route),
                  onTap: () {
                    Navigator.of(context).pop();
                    onNavigate(route);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.collapsed, required this.onToggleCollapsed});

  final bool collapsed;
  final VoidCallback? onToggleCollapsed;

  @override
  Widget build(BuildContext context) {
    final toggle = onToggleCollapsed == null
        ? null
        : IconButton(
            tooltip: collapsed ? 'Expand menu' : 'Collapse menu',
            onPressed: onToggleCollapsed,
            icon: Icon(
              collapsed ? Icons.chevron_right : Icons.chevron_left,
              color: AppColors.textSecondary,
            ),
          );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: collapsed
          ? Center(child: toggle)
          : Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.s12),
                    child: Text(
                      'Money Tracker',
                      style: AppTextStyles.brand,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                ?toggle,
              ],
            ),
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.collapsed = false,
  });

  final String label;
  final IconData icon;
  final bool active;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.radiusControl);
    final style = active ? AppTextStyles.navItemActive : AppTextStyles.navItem;
    final item = Semantics(
      selected: active,
      button: true,
      label: label,
      child: Material(
        color: active ? AppColors.primaryTint : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          mouseCursor: SystemMouseCursors.click,
          hoverColor: active ? Colors.transparent : AppColors.navHover,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.controlHeight,
            ),
            padding: const EdgeInsets.all(AppSpacing.s12),
            alignment: Alignment.centerLeft,
            child: collapsed
                ? Center(child: Icon(icon, size: 20, color: style.color))
                : Row(
                    children: [
                      Icon(icon, size: 20, color: style.color),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          label,
                          style: style,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
    return collapsed ? Tooltip(message: label, child: item) : item;
  }
}

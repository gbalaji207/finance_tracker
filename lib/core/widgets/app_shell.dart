import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wide screens get a permanent sidebar that can collapse to an icon rail
/// (remembered across visits); narrow screens get an app bar and a drawer.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.location,
    required this.onNavigate,
    required this.child,
  });

  final String location;
  final ValueChanged<String> onNavigate;
  final Widget child;

  @visibleForTesting
  static const collapsedPrefKey = 'sidebar_collapsed';

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _loadCollapsed();
  }

  Future<void> _loadCollapsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(AppShell.collapsedPrefKey) ?? false;
      if (mounted && saved != _collapsed) setState(() => _collapsed = saved);
    } catch (_) {
      // Storage unavailable: stay expanded.
    }
  }

  Future<void> _toggleCollapsed() async {
    final next = !_collapsed;
    setState(() => _collapsed = next);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppShell.collapsedPrefKey, next);
    } catch (_) {
      // Not persisted; the toggle still works for this session.
    }
  }

  @override
  Widget build(BuildContext context) {
    final narrow =
        MediaQuery.sizeOf(context).width < AppSpacing.mobileBreakpoint;

    if (narrow) {
      return Scaffold(
        backgroundColor: AppColors.pageBg,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          shape: const Border(bottom: BorderSide(color: AppColors.cardBorder)),
          title: Text('Money Tracker', style: AppTextStyles.brand),
        ),
        drawer: AppNavDrawer(
          location: widget.location,
          onNavigate: widget.onNavigate,
        ),
        // The page scrolls itself (see PageBody); the shell only bounds it.
        body: widget.child,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSidebar(
            location: widget.location,
            onNavigate: widget.onNavigate,
            collapsed: _collapsed,
            onToggleCollapsed: _toggleCollapsed,
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

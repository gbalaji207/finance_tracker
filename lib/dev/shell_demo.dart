import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/widgets/app_shell.dart';
import 'package:finance_tracker/core/widgets/month_selector.dart';
import 'package:finance_tracker/core/widgets/page_header.dart';
import 'package:flutter/material.dart';

/// Temporary demo of the layout components.
class ShellDemo extends StatefulWidget {
  const ShellDemo({super.key});

  @override
  State<ShellDemo> createState() => _ShellDemoState();
}

class _ShellDemoState extends State<ShellDemo> {
  String _location = AppRoutes.dashboard;
  DateTime _month = DateTime(2026, 11);

  @override
  Widget build(BuildContext context) {
    return AppShell(
      location: _location,
      onNavigate: (route) => setState(() => _location = route),
      child: PageHeader(
        title: 'Dashboard',
        subtitle: 'Sample data',
        actions: [
          MonthSelector(
            month: _month,
            onChanged: (m) => setState(() => _month = m),
          ),
        ],
      ),
    );
  }
}

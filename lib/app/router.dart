import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/widgets/app_shell.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:finance_tracker/dev/component_gallery.dart';
import 'package:finance_tracker/dev/design_system_preview.dart';
import 'package:finance_tracker/features/dashboard/view/dashboard_page.dart';
import 'package:finance_tracker/features/monthly_report/view/monthly_report_page.dart';
import 'package:finance_tracker/features/settings/view/settings_page.dart';
import 'package:finance_tracker/features/source_report/view/source_report_page.dart';
import 'package:finance_tracker/features/templates/view/templates_page.dart';
import 'package:finance_tracker/features/transactions/view/transactions_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter() {
  GoRoute page(String path, Widget Function() build) => GoRoute(
        path: path,
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: build()),
      );

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) =>
        state.uri.path == '/' ? AppRoutes.dashboard : null,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          location: state.uri.path,
          onNavigate: (path) => context.go(path),
          child: child,
        ),
        routes: [
          page(AppRoutes.dashboard, DashboardPage.new),
          page(AppRoutes.transactions, TransactionsPage.new),
          page(AppRoutes.monthlyReport, MonthlyReportPage.new),
          page(AppRoutes.sourceReport, SourceReportPage.new),
          page(AppRoutes.templates, TemplatesPage.new),
          page(AppRoutes.settings, SettingsPage.new),
        ],
      ),
      if (kDebugMode) ...[
        GoRoute(
          path: '/dev/design-system',
          builder: (context, state) =>
              const Scaffold(body: DesignSystemPreview()),
        ),
        GoRoute(
          path: '/dev/gallery',
          builder: (context, state) =>
              const Scaffold(body: ComponentGallery()),
        ),
      ],
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            const Text('Page not found'),
            AppTextLink(
              label: 'Go to dashboard',
              onPressed: () => context.go(AppRoutes.dashboard),
            ),
          ],
        ),
      ),
    ),
  );
}

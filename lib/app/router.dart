import 'dart:async';

import 'package:finance_tracker/app/auth_config.dart';
import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/widgets/app_shell.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:finance_tracker/core/widgets/page_body.dart';
import 'package:finance_tracker/dev/component_gallery.dart';
import 'package:finance_tracker/dev/design_system_preview.dart';
import 'package:finance_tracker/dev/supabase_check_page.dart';
import 'package:finance_tracker/features/auth/cubit/auth_cubit.dart';
import 'package:finance_tracker/features/auth/cubit/auth_state.dart';
import 'package:finance_tracker/features/auth/view/login_page.dart';
import 'package:finance_tracker/features/dashboard/view/dashboard_page.dart';
import 'package:finance_tracker/features/monthly_report/view/monthly_report_page.dart';
import 'package:finance_tracker/features/settings/view/settings_page.dart';
import 'package:finance_tracker/features/source_report/view/source_report_page.dart';
import 'package:finance_tracker/features/templates/view/templates_page.dart';
import 'package:finance_tracker/features/transactions/view/transactions_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Notifies the router on every [AuthCubit] state change so redirects re-run.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthCubit auth) {
  GoRoute page(String path, Widget Function(GoRouterState state) build) =>
      GoRoute(
        path: path,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: PageBody(child: build(state)),
        ),
      );

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: _AuthRefresh(auth.stream),
    redirect: (context, state) {
      final path = state.uri.path;
      if (kRequireLogin) {
        final signedIn = auth.state.status == AuthStatus.signedIn;
        if (!signedIn && path != AppRoutes.login) return AppRoutes.login;
        if (signedIn && path == AppRoutes.login) return AppRoutes.dashboard;
      }
      return path == '/' ? AppRoutes.dashboard : null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: const LoginPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          location: state.uri.path,
          onNavigate: (path) => context.go(path),
          child: child,
        ),
        routes: [
          page(AppRoutes.dashboard, (_) => const DashboardPage()),
          page(
            AppRoutes.transactions,
            (state) => TransactionsPage(
              templateId: state.uri.queryParameters['template'],
            ),
          ),
          page(AppRoutes.monthlyReport, (_) => const MonthlyReportPage()),
          page(AppRoutes.sourceReport, (_) => const SourceReportPage()),
          page(AppRoutes.templates, (_) => const TemplatesPage()),
          page(AppRoutes.settings, (_) => const SettingsPage()),
        ],
      ),
      if (kDebugMode) ...[
        GoRoute(
          path: '/dev/design-system',
          builder: (context, state) =>
              const Scaffold(body: DesignSystemPreview()),
        ),
        GoRoute(
          path: '/dev/supabase',
          builder: (context, state) => const SupabaseCheckPage(),
        ),
        GoRoute(
          path: '/dev/gallery',
          builder: (context, state) => const Scaffold(body: ComponentGallery()),
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

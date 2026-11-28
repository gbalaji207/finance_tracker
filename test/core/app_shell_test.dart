import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/widgets/app_shell.dart';
import 'package:finance_tracker/core/widgets/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app({required ValueChanged<String> onNavigate}) => MaterialApp(
      home: AppShell(
        location: AppRoutes.dashboard,
        onNavigate: onNavigate,
        child: const Text('page'),
      ),
    );

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('wide: sidebar collapses to a rail and remembers it',
      (tester) async {
    await _setSize(tester, const Size(1000, 800));
    await tester.pumpWidget(_app(onNavigate: (_) {}));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(
      tester.getSize(find.byType(AppSidebar)).width,
      AppSpacing.sidebarWidth,
    );

    await tester.tap(find.byTooltip('Collapse menu'));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(AppSidebar)).width,
      AppSpacing.sidebarRailWidth,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(AppShell.collapsedPrefKey), isTrue);
  });

  testWidgets('wide: restores the collapsed state', (tester) async {
    SharedPreferences.setMockInitialValues({AppShell.collapsedPrefKey: true});
    await _setSize(tester, const Size(1000, 800));
    await tester.pumpWidget(_app(onNavigate: (_) {}));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(AppSidebar)).width,
      AppSpacing.sidebarRailWidth,
    );
  });

  testWidgets('narrow: app bar + drawer, item navigates and closes',
      (tester) async {
    await _setSize(tester, const Size(400, 800));
    String? navigated;
    await tester.pumpWidget(_app(onNavigate: (r) => navigated = r));
    await tester.pumpAndSettle();

    expect(find.byType(AppSidebar), findsNothing);
    expect(find.byType(AppBar), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Transactions'), findsOneWidget);

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(navigated, AppRoutes.transactions);
    expect(find.text('Transactions'), findsNothing);
  });
}

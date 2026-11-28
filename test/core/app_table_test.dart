import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(double width, {VoidCallback? onEdit}) => MaterialApp(
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: width,
        child: AppTable(
          minWidth: 700,
          columns: const [
            AppTableColumn('Description'),
            AppTableColumn('Source', width: 120),
            AppTableColumn(
              'Amount',
              width: 100,
              align: TextAlign.right,
              mobile: AppTableMobile.trailing,
            ),
            AppTableColumn('', width: 60, mobile: AppTableMobile.action),
          ],
          rows: [
            AppTableRow([
              const AppTableText('Rent', maxLines: 1),
              const AppTableText('Salary'),
              const AppTableText('1,000'),
              TextButton(onPressed: onEdit, child: const Text('Edit')),
            ], background: Colors.yellow),
          ],
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('wide: header and columns', (tester) async {
    await tester.pumpWidget(_host(900));
    expect(find.text('Source'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
  });

  testWidgets('narrow: stacked card with labels and a working action', (
    tester,
  ) async {
    var edited = false;
    await tester.pumpWidget(_host(360, onEdit: () => edited = true));
    expect(find.text('Description'), findsNothing); // no header row
    expect(find.text('Source'), findsOneWidget); // detail label
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('1,000'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Edit'));
    expect(edited, isTrue);
  });
}

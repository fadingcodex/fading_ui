import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

class _TableRow {
  const _TableRow(this.node, this.throughput, this.status);

  final String node;
  final int throughput;
  final String status;
}

void main() {
  final List<_TableRow> rows = <_TableRow>[
    const _TableRow('Kite', 58, 'Stable'),
    const _TableRow('Aster', 72, 'Stable'),
    const _TableRow('Pyre', 90, 'Critical'),
  ];

  List<FadingDataColumn<_TableRow>> buildColumns() {
    return <FadingDataColumn<_TableRow>>[
      FadingDataColumn<_TableRow>(
        label: 'Node',
        cellBuilder: (BuildContext context, _TableRow row) {
          final FadingThemeData theme = FadingThemeScope.of(context);
          return Text(row.node, style: theme.bodyMedium);
        },
        sortComparator: (a, b) => a.node.compareTo(b.node),
      ),
      FadingDataColumn<_TableRow>(
        label: 'Throughput',
        numeric: true,
        cellBuilder: (BuildContext context, _TableRow row) {
          final FadingThemeData theme = FadingThemeScope.of(context);
          return Text('${row.throughput}', style: theme.bodyMedium);
        },
        sortComparator: (a, b) => a.throughput.compareTo(b.throughput),
      ),
      FadingDataColumn<_TableRow>(
        label: 'Status',
        cellBuilder: (BuildContext context, _TableRow row) {
          final FadingThemeData theme = FadingThemeScope.of(context);
          return Text(row.status, style: theme.bodyMedium);
        },
      ),
    ];
  }

  testWidgets('data table renders headers and rows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(FadingDataTable<_TableRow>(rows: rows, columns: buildColumns())),
    );

    expect(find.text('Node'), findsOneWidget);
    expect(find.text('Throughput'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Aster'), findsOneWidget);
    expect(find.text('Pyre'), findsOneWidget);
  });

  testWidgets('data table sorts internally when header tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(FadingDataTable<_TableRow>(rows: rows, columns: buildColumns())),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-data-table-header-1')),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('fading-data-table-row-0')),
        matching: find.text('58'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-data-table-header-1')),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('fading-data-table-row-0')),
        matching: find.text('90'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('data table emits controlled sort changes', (
    WidgetTester tester,
  ) async {
    int? emittedColumn;
    bool? emittedAscending;

    await tester.pumpWidget(
      buildApp(
        FadingDataTable<_TableRow>(
          rows: rows,
          columns: buildColumns(),
          sortColumnIndex: 0,
          sortAscending: true,
          onSortChanged: (int column, bool ascending) {
            emittedColumn = column;
            emittedAscending = ascending;
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-data-table-header-0')),
    );
    await tester.pumpAndSettle();

    expect(emittedColumn, 0);
    expect(emittedAscending, false);
  });

  testWidgets('data table emits tapped row', (WidgetTester tester) async {
    int? emittedIndex;
    _TableRow? emittedRow;

    await tester.pumpWidget(
      buildApp(
        FadingDataTable<_TableRow>(
          rows: rows,
          columns: buildColumns(),
          onRowTap: (int index, _TableRow row) {
            emittedIndex = index;
            emittedRow = row;
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-data-table-row-1')),
    );
    await tester.pumpAndSettle();

    expect(emittedIndex, 1);
    expect(emittedRow?.node, 'Aster');
  });

  testWidgets('disabled data table ignores sort and row taps', (
    WidgetTester tester,
  ) async {
    int sortCalls = 0;
    int rowCalls = 0;

    await tester.pumpWidget(
      buildApp(
        FadingDataTable<_TableRow>(
          rows: rows,
          columns: buildColumns(),
          enabled: false,
          onSortChanged: (_, _) {
            sortCalls += 1;
          },
          onRowTap: (_, _) {
            rowCalls += 1;
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-data-table-header-0')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('fading-data-table-row-0')),
    );
    await tester.pumpAndSettle();

    expect(sortCalls, 0);
    expect(rowCalls, 0);
  });

  testWidgets('data table renders empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(
        FadingDataTable<_TableRow>(
          rows: const <_TableRow>[],
          columns: buildColumns(),
          emptyLabel: 'Nothing to display',
        ),
      ),
    );

    expect(find.text('Nothing to display'), findsOneWidget);
  });
}

import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('empty state renders title and message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        const FadingEmptyState(
          title: 'Nothing here yet',
          message: 'Create an item to get started.',
        ),
      ),
    );

    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('Create an item to get started.'), findsOneWidget);
  });

  testWidgets('empty state renders the default icon for each tone', (
    WidgetTester tester,
  ) async {
    const Map<FadingEmptyStateTone, IconData> toneIcons =
        <FadingEmptyStateTone, IconData>{
          FadingEmptyStateTone.neutral: Icons.inbox_outlined,
          FadingEmptyStateTone.success: Icons.check_circle_outline,
          FadingEmptyStateTone.warning: Icons.error_outline,
          FadingEmptyStateTone.critical:
              Icons.report_gmailerrorred_outlined,
        };

    for (final MapEntry<FadingEmptyStateTone, IconData> entry
        in toneIcons.entries) {
      await tester.pumpWidget(
        buildApp(FadingEmptyState(title: 'Empty', tone: entry.key)),
      );
      expect(find.byIcon(entry.value), findsOneWidget);
    }
  });

  testWidgets('custom icon overrides the tone default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        const FadingEmptyState(
          title: 'No favorites',
          tone: FadingEmptyStateTone.critical,
          icon: Icons.favorite_border,
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.report_gmailerrorred_outlined), findsNothing);
  });

  testWidgets('illustration overrides the configured icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        const FadingEmptyState(
          title: 'No results',
          icon: Icons.search,
          illustration: Text('Custom illustration'),
        ),
      ),
    );

    expect(find.text('Custom illustration'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsNothing);
  });

  testWidgets('empty state triggers both action callbacks', (
    WidgetTester tester,
  ) async {
    bool primaryCalled = false;
    bool secondaryCalled = false;

    await tester.pumpWidget(
      buildApp(
        FadingEmptyState(
          title: 'No projects',
          primaryAction: FadingButton(
            label: 'Create project',
            onPressed: () => primaryCalled = true,
          ),
          secondaryAction: FadingButton(
            label: 'Import',
            onPressed: () => secondaryCalled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Create project'));
    await tester.pump();
    await tester.tap(find.text('Import'));
    await tester.pump();

    expect(primaryCalled, isTrue);
    expect(secondaryCalled, isTrue);
  });

  testWidgets('title-only empty state renders without errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(const FadingEmptyState(title: 'No notifications')),
    );

    expect(find.text('No notifications'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state handles long content in a narrow layout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        const SizedBox(
          width: 220,
          child: FadingEmptyState(
            title: 'No matching activity was found',
            message:
                'Try changing the selected filters or broadening the date range to find more activity.',
            primaryAction: Text('Clear all filters'),
            secondaryAction: Text('Change date range'),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact empty state is shorter than the default', (
    WidgetTester tester,
  ) async {
    const Key defaultKey = Key('default');
    const Key compactKey = Key('compact');

    await tester.pumpWidget(
      buildApp(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FadingEmptyState(
              key: defaultKey,
              title: 'Default',
              message: 'No data available.',
            ),
            FadingEmptyState(
              key: compactKey,
              title: 'Compact',
              message: 'No data available.',
              compact: true,
            ),
          ],
        ),
      ),
    );

    final double defaultHeight = tester.getSize(find.byKey(defaultKey)).height;
    final double compactHeight = tester.getSize(find.byKey(compactKey)).height;
    expect(compactHeight, lessThan(defaultHeight));
  });
}

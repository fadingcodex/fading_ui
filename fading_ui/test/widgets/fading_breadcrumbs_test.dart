import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('breadcrumbs render labels and current item', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        FadingBreadcrumbs(
          items: const <String>['Home', 'Operations', 'Telemetry'],
          currentIndex: 2,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Operations'), findsOneWidget);
    expect(find.text('Telemetry'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('fading-breadcrumbs-item-2')),
      findsOneWidget,
    );
  });

  testWidgets('breadcrumbs emit tapped index', (WidgetTester tester) async {
    int? emitted;

    await tester.pumpWidget(
      buildApp(
        FadingBreadcrumbs(
          items: const <String>['Home', 'Operations', 'Telemetry'],
          currentIndex: 2,
          onChanged: (int index) {
            emitted = index;
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-breadcrumbs-item-1')),
    );
    await tester.pumpAndSettle();

    expect(emitted, 1);
  });

  testWidgets('breadcrumbs ignore taps on current item', (
    WidgetTester tester,
  ) async {
    int? emitted;

    await tester.pumpWidget(
      buildApp(
        FadingBreadcrumbs(
          items: const <String>['Home', 'Operations', 'Telemetry'],
          currentIndex: 2,
          onChanged: (int index) {
            emitted = index;
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-breadcrumbs-item-2')),
    );
    await tester.pumpAndSettle();

    expect(emitted, isNull);
  });

  testWidgets('disabled breadcrumbs ignore interactions', (
    WidgetTester tester,
  ) async {
    int? emitted;

    await tester.pumpWidget(
      buildApp(
        FadingBreadcrumbs(
          items: const <String>['Home', 'Operations', 'Telemetry'],
          currentIndex: 1,
          enabled: false,
          onChanged: (int index) {
            emitted = index;
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-breadcrumbs-item-0')),
    );
    await tester.pumpAndSettle();

    expect(emitted, isNull);
  });

  testWidgets('breadcrumbs require valid currentIndex', (_) async {
    expect(
      () => FadingBreadcrumbs(
        items: const <String>['Home', 'Operations'],
        currentIndex: 2,
        onChanged: (_) {},
      ),
      throwsAssertionError,
    );

    expect(
      () => FadingBreadcrumbs(
        items: const <String>[],
        currentIndex: 0,
        onChanged: (_) {},
      ),
      throwsAssertionError,
    );
  });
}

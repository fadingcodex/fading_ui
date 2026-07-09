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

  testWidgets('breadcrumbs render rich item leading widgets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        FadingBreadcrumbs(
          items: <Object>[
            const FadingBreadcrumbItem(
              label: 'Home',
              leading: SizedBox(
                key: ValueKey<String>('crumb-leading-home'),
                width: 8,
                height: 8,
              ),
            ),
            const FadingBreadcrumbItem(
              label: 'Operations',
              leading: SizedBox(
                key: ValueKey<String>('crumb-leading-ops'),
                width: 8,
                height: 8,
              ),
            ),
            const FadingBreadcrumbItem(label: 'Telemetry'),
          ],
          currentIndex: 2,
          onChanged: (_) {},
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('crumb-leading-home')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('crumb-leading-ops')),
      findsOneWidget,
    );
  });

  testWidgets('disabled breadcrumb item ignores tap but enabled item emits', (
    WidgetTester tester,
  ) async {
    int? emitted;

    await tester.pumpWidget(
      buildApp(
        FadingBreadcrumbs(
          items: <Object>[
            const FadingBreadcrumbItem(label: 'Home'),
            const FadingBreadcrumbItem(label: 'Operations', enabled: false),
            const FadingBreadcrumbItem(label: 'Telemetry'),
          ],
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
    expect(emitted, isNull);

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-breadcrumbs-item-0')),
    );
    await tester.pumpAndSettle();
    expect(emitted, 0);
  });

  testWidgets('custom separator builder renders custom separators', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        FadingBreadcrumbs(
          items: const <String>['Home', 'Operations', 'Telemetry'],
          currentIndex: 2,
          onChanged: (_) {},
          separatorBuilder:
              (BuildContext context, int index, FadingThemeData _) {
                return Text(
                  '>',
                  key: ValueKey<String>('custom-separator-$index'),
                );
              },
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('custom-separator-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('custom-separator-2')),
      findsOneWidget,
    );
  });

  testWidgets('mixed string and rich item input is supported', (
    WidgetTester tester,
  ) async {
    int? emitted;

    await tester.pumpWidget(
      buildApp(
        FadingBreadcrumbs(
          items: <Object>[
            'Home',
            const FadingBreadcrumbItem(label: 'Operations'),
            'Telemetry',
          ],
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
}

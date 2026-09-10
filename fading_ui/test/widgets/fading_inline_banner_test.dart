import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('inline banner renders title and message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        const FadingInlineBanner(
          title: 'Heads up',
          message: 'Your sync is still running in the background.',
          tone: FadingInlineBannerTone.warning,
        ),
      ),
    );

    expect(find.text('Heads up'), findsOneWidget);
    expect(
      find.text('Your sync is still running in the background.'),
      findsOneWidget,
    );
  });

  testWidgets('inline banner triggers action and dismiss callbacks', (
    WidgetTester tester,
  ) async {
    bool actionCalled = false;
    bool dismissCalled = false;

    await tester.pumpWidget(
      buildApp(
        FadingInlineBanner(
          title: 'Sync failed',
          message: 'Retry the import.',
          tone: FadingInlineBannerTone.critical,
          action: FadingButton(
            label: 'Retry',
            onPressed: () => actionCalled = true,
          ),
          dismissible: true,
          onDismiss: () => dismissCalled = true,
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(actionCalled, isTrue);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(dismissCalled, isTrue);
  });

  testWidgets('inline banner handles long content without layout errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        const SizedBox(
          width: 220,
          child: FadingInlineBanner(
            title: 'System maintenance',
            message:
                'We will update the service window and may interrupt in-flight activity for a short period.',
            tone: FadingInlineBannerTone.success,
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

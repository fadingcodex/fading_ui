import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('modal shows content and dismisses on backdrop tap', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (BuildContext context) {
            return Center(
              child: FadingButton(
                label: 'Open modal',
                onPressed: () {
                  FadingModal.show(
                    context,
                    title: 'Confirm signal',
                    body: const Text('Dispatch the current command set?'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open modal'));
    await tester.pump();

    expect(find.text('Confirm signal'), findsOneWidget);
    expect(find.text('Dispatch the current command set?'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('Confirm signal'), findsNothing);
    await tester.pumpAndSettle();

    expect(find.text('Confirm signal'), findsNothing);
  });

  testWidgets('modal action invokes callback and dismisses', (
    WidgetTester tester,
  ) async {
    var confirmed = false;

    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (BuildContext context) {
            return Center(
              child: FadingButton(
                label: 'Open modal',
                onPressed: () {
                  FadingModal.show(
                    context,
                    title: 'Send command',
                    body: const Text('Confirm the command transmission.'),
                    actions: <FadingModalAction>[
                      const FadingModalAction(label: 'Cancel'),
                      FadingModalAction(
                        label: 'Confirm',
                        onPressed: () {
                          confirmed = true;
                        },
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open modal'));
    await tester.pump();

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
    expect(find.text('Send command'), findsNothing);
  });
}

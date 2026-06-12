import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('snackbar shows message and action', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (BuildContext context) {
            return Center(
              child: FadingButton(
                label: 'Show snackbar',
                onPressed: () {
                  FadingSnackbar.show(
                    context,
                    message: 'Telemetry route updated.',
                    action: const FadingSnackbarAction(label: 'Undo'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show snackbar'));
    await tester.pump();

    expect(find.text('Telemetry route updated.'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('snackbar action callback is invoked', (
    WidgetTester tester,
  ) async {
    var undone = false;

    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (BuildContext context) {
            return Center(
              child: FadingButton(
                label: 'Show snackbar',
                onPressed: () {
                  FadingSnackbar.show(
                    context,
                    message: 'Telemetry route updated.',
                    action: FadingSnackbarAction(
                      label: 'Undo',
                      onPressed: () {
                        undone = true;
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show snackbar'));
    await tester.pump();

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(undone, isTrue);
    expect(find.text('Telemetry route updated.'), findsNothing);
  });
}

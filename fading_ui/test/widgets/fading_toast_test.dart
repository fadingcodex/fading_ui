import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('toast shows the provided message', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (BuildContext context) {
            return FadingButton(
              label: 'Show toast',
              onPressed: () {
                FadingToast.show(context, message: 'Signal received.');
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show toast'));
    await tester.pump();

    expect(find.text('Signal received.'), findsOneWidget);
  });
}

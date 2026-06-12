import 'package:fading_ui/fading_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('button triggers callback when tapped', (
    WidgetTester tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      buildApp(FadingButton(label: 'Deploy', onPressed: null)),
    );

    await tester.pumpWidget(
      buildApp(
        FadingButton(
          label: 'Deploy',
          onPressed: () {
            tapped = true;
          },
        ),
      ),
    );

    await tester.tap(find.text('Deploy'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}

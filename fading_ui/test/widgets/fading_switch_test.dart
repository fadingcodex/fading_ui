import 'package:fading_ui/fading_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('switch emits toggled value on tap', (WidgetTester tester) async {
    bool? nextValue;

    await tester.pumpWidget(
      buildApp(
        FadingSwitch(
          label: 'Aux relay',
          value: false,
          onChanged: (bool value) {
            nextValue = value;
          },
        ),
      ),
    );

    await tester.tap(find.text('Aux relay'));
    await tester.pumpAndSettle();

    expect(nextValue, isTrue);
  });
}

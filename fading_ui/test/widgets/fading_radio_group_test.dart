import 'package:fading_ui/fading_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('radio group emits selected option', (WidgetTester tester) async {
    String? selected;

    await tester.pumpWidget(
      buildApp(
        FadingRadioGroup<String>(
          label: 'Broadcast channel',
          value: 'Alpha',
          onChanged: (String value) {
            selected = value;
          },
          options: const <FadingRadioOption<String>>[
            FadingRadioOption<String>(value: 'Alpha', label: 'Alpha'),
            FadingRadioOption<String>(value: 'Beta', label: 'Beta'),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();

    expect(selected, 'Beta');
  });
}

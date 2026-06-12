import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('text field forwards input changes', (WidgetTester tester) async {
    String value = '';

    await tester.pumpWidget(
      buildApp(
        FadingTextField(
          label: 'Signal',
          onChanged: (String text) => value = text,
        ),
      ),
    );

    await tester.tap(find.byType(EditableText));
    await tester.enterText(find.byType(EditableText), 'house li halan');
    await tester.pump();

    expect(value, 'house li halan');
  });
}

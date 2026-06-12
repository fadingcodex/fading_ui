import 'package:fading_ui/fading_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('progress indicator shows circular value label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        const FadingProgressIndicator(
          label: 'Orbital sync',
          value: 0.5,
          variant: FadingProgressVariant.circular,
        ),
      ),
    );

    expect(find.text('Orbital sync'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });
}

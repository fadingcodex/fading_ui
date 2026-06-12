import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('slider emits changed values when dragged', (
    WidgetTester tester,
  ) async {
    double nextValue = 10;

    await tester.pumpWidget(
      buildApp(
        FadingSlider(
          label: 'Drive intensity',
          min: 0,
          max: 100,
          value: 10,
          onChanged: (double value) {
            nextValue = value;
          },
        ),
      ),
    );

    final Finder sliderTrack = find.descendant(
      of: find.byType(FadingSlider),
      matching: find.byType(GestureDetector),
    );

    await tester.drag(sliderTrack, const Offset(160, 0));
    await tester.pumpAndSettle();

    expect(nextValue, greaterThan(10));
    expect(nextValue, lessThanOrEqualTo(100));
  });
}

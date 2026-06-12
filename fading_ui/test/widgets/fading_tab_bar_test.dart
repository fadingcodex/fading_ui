import 'package:fading_ui/fading_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('tab bar emits selected index', (WidgetTester tester) async {
    int? selectedIndex;

    await tester.pumpWidget(
      buildApp(
        FadingTabBar(
          tabs: const <String>['Signals', 'Telemetry', 'Archive'],
          selectedIndex: 0,
          onChanged: (int index) {
            selectedIndex = index;
          },
        ),
      ),
    );

    await tester.tap(find.text('Telemetry'));
    await tester.pumpAndSettle();

    expect(selectedIndex, 1);
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fading_ui/fading_ui.dart';

void main() {
  Widget buildApp(Widget child) {
    return WidgetsApp(
      color: FadingColors.midnight,
      debugShowCheckedModeBanner: false,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (BuildContext context, _, _) => builder(context),
        );
      },
      home: Directionality(textDirection: TextDirection.ltr, child: child),
    );
  }

  test('exposes the expected color tokens', () {
    expect(FadingColors.midnight, const Color(0xFF1A1824));
    expect(FadingColors.amberGlow, const Color(0xFFEC8A54));
  });

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

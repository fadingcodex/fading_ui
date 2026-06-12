import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

const ValueKey<String> _betaOptionKey = ValueKey<String>(
  'fading-select-option-Beta',
);
const ValueKey<String> _gammaOptionKey = ValueKey<String>(
  'fading-select-option-Gamma',
);
const ValueKey<String> _dismissAreaKey = ValueKey<String>(
  'fading-select-dismiss-area',
);

void main() {
  testWidgets('select toggles multiple options and emits ordered values', (
    WidgetTester tester,
  ) async {
    List<String> values = <String>['Alpha'];
    List<String>? emitted;

    await tester.pumpWidget(
      buildApp(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 320,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return FadingSelect<String>(
                  label: 'Dispatch channels',
                  values: values,
                  onChanged: (List<String> next) {
                    emitted = next;
                    setState(() {
                      values = next;
                    });
                  },
                  options: const <FadingSelectOption<String>>[
                    FadingSelectOption<String>(value: 'Alpha', label: 'Alpha'),
                    FadingSelectOption<String>(value: 'Beta', label: 'Beta'),
                    FadingSelectOption<String>(value: 'Gamma', label: 'Gamma'),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FadingSelect<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(_betaOptionKey));
    await tester.pumpAndSettle();
    expect(emitted, <String>['Alpha', 'Beta']);

    await tester.tap(find.byKey(_gammaOptionKey));
    await tester.pumpAndSettle();
    expect(emitted, <String>['Alpha', 'Beta', 'Gamma']);
  });

  testWidgets('single select emits chosen value and closes overlay', (
    WidgetTester tester,
  ) async {
    String? selected = 'Alpha';
    String? emitted;

    await tester.pumpWidget(
      buildApp(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 320,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return FadingSelect<String>.single(
                  label: 'Primary channel',
                  value: selected,
                  onValueChanged: (String? value) {
                    emitted = value;
                    setState(() {
                      selected = value;
                    });
                  },
                  options: const <FadingSelectOption<String>>[
                    FadingSelectOption<String>(value: 'Alpha', label: 'Alpha'),
                    FadingSelectOption<String>(value: 'Beta', label: 'Beta'),
                    FadingSelectOption<String>(value: 'Gamma', label: 'Gamma'),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FadingSelect<String>));
    await tester.pumpAndSettle();
    expect(find.byKey(_betaOptionKey), findsOneWidget);

    await tester.tap(find.byKey(_betaOptionKey));
    await tester.pumpAndSettle();

    expect(emitted, 'Beta');
    expect(find.byKey(_betaOptionKey), findsNothing);
  });

  testWidgets('select dismisses when tapping outside', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        Column(
          children: <Widget>[
            FadingSelect<String>(
              label: 'Dispatch channels',
              values: const <String>[],
              onChanged: (_) {},
              options: const <FadingSelectOption<String>>[
                FadingSelectOption<String>(value: 'Alpha', label: 'Alpha'),
                FadingSelectOption<String>(value: 'Beta', label: 'Beta'),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Outside area'),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(FadingSelect<String>));
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsOneWidget);

    await tester.tap(find.byKey(_dismissAreaKey));
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsNothing);
  });

  testWidgets('disabled select ignores taps', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(
        FadingSelect<String>(
          label: 'Dispatch channels',
          values: const <String>[],
          enabled: false,
          onChanged: (_) {},
          options: const <FadingSelectOption<String>>[
            FadingSelectOption<String>(value: 'Alpha', label: 'Alpha'),
            FadingSelectOption<String>(value: 'Beta', label: 'Beta'),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(FadingSelect<String>));
    await tester.pumpAndSettle();

    expect(find.text('Beta'), findsNothing);
  });

  testWidgets('select opens with Enter and closes with Escape', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        FadingSelect<String>(
          label: 'Dispatch channels',
          values: const <String>[],
          onChanged: (_) {},
          options: const <FadingSelectOption<String>>[
            FadingSelectOption<String>(value: 'Alpha', label: 'Alpha'),
            FadingSelectOption<String>(value: 'Beta', label: 'Beta'),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(FadingSelect<String>));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsNothing);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsOneWidget);
  });
}

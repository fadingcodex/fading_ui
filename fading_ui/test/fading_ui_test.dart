import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fading_ui/fading_ui.dart';

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

  testWidgets('checkbox emits toggled value on tap', (
    WidgetTester tester,
  ) async {
    bool? nextValue;

    await tester.pumpWidget(
      buildApp(
        FadingCheckbox(
          label: 'Enable pulse lock',
          value: false,
          onChanged: (bool value) {
            nextValue = value;
          },
        ),
      ),
    );

    await tester.tap(find.text('Enable pulse lock'));
    await tester.pumpAndSettle();

    expect(nextValue, isTrue);
  });

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

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
    expect(FadingColors.imperialGold, const Color(0xFFD1A446));
    expect(FadingColors.dreamCream, const Color(0xFFF5EBDD));
  });

  test('resolves built-in themes by name and group', () {
    expect(FadingThemeName.dawn.group, FadingThemeGroup.diaspora);
    expect(FadingThemeName.abyss.group, FadingThemeGroup.diaspora);
    expect(FadingThemeName.hope.group, FadingThemeGroup.imperium);
    expect(FadingThemeName.dream.group, FadingThemeGroup.imperium);
    expect(
      FadingThemeData.fromTheme(FadingThemeName.hope).accentStrong,
      FadingColors.imperialOchre,
    );
    expect(
      FadingThemeData.fromTheme(FadingThemeName.dream).backgroundStart,
      FadingColors.dreamWhite,
    );
  });

  testWidgets('theme scope falls back to abyss when no scope is present', (
    WidgetTester tester,
  ) async {
    late FadingThemeData resolvedTheme;
    late FadingThemeName resolvedName;

    await tester.pumpWidget(
      WidgetsApp(
        color: FadingColors.midnight,
        debugShowCheckedModeBanner: false,
        pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
          return PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (BuildContext context, _, _) => builder(context),
          );
        },
        home: Builder(
          builder: (BuildContext context) {
            resolvedTheme = FadingThemeScope.of(context);
            resolvedName = FadingThemeScope.themeOf(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(resolvedName, FadingThemeName.abyss);
    expect(
      resolvedTheme.backgroundStart,
      FadingThemeData.abyss.backgroundStart,
    );
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

  testWidgets('modal shows content and dismisses on backdrop tap', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (BuildContext context) {
            return Center(
              child: FadingButton(
                label: 'Open modal',
                onPressed: () {
                  FadingModal.show(
                    context,
                    title: 'Confirm signal',
                    body: const Text('Dispatch the current command set?'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open modal'));
    await tester.pump();

    expect(find.text('Confirm signal'), findsOneWidget);
    expect(find.text('Dispatch the current command set?'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('Confirm signal'), findsNothing);
    await tester.pumpAndSettle();

    expect(find.text('Confirm signal'), findsNothing);
  });

  testWidgets('modal action invokes callback and dismisses', (
    WidgetTester tester,
  ) async {
    var confirmed = false;

    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (BuildContext context) {
            return Center(
              child: FadingButton(
                label: 'Open modal',
                onPressed: () {
                  FadingModal.show(
                    context,
                    title: 'Send command',
                    body: const Text('Confirm the command transmission.'),
                    actions: <FadingModalAction>[
                      const FadingModalAction(label: 'Cancel'),
                      FadingModalAction(
                        label: 'Confirm',
                        onPressed: () {
                          confirmed = true;
                        },
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open modal'));
    await tester.pump();

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
    expect(find.text('Send command'), findsNothing);
  });

  testWidgets('snackbar shows message and action', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (BuildContext context) {
            return Center(
              child: FadingButton(
                label: 'Show snackbar',
                onPressed: () {
                  FadingSnackbar.show(
                    context,
                    message: 'Telemetry route updated.',
                    action: const FadingSnackbarAction(label: 'Undo'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show snackbar'));
    await tester.pump();

    expect(find.text('Telemetry route updated.'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('snackbar action callback is invoked', (WidgetTester tester) async {
    var undone = false;

    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (BuildContext context) {
            return Center(
              child: FadingButton(
                label: 'Show snackbar',
                onPressed: () {
                  FadingSnackbar.show(
                    context,
                    message: 'Telemetry route updated.',
                    action: FadingSnackbarAction(
                      label: 'Undo',
                      onPressed: () {
                        undone = true;
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show snackbar'));
    await tester.pump();

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(undone, isTrue);
    expect(find.text('Telemetry route updated.'), findsNothing);
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

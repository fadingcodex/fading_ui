import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

const ValueKey<String> _alphaOptionKey = ValueKey<String>(
  'fading-multi-select-option-Alpha',
);
const ValueKey<String> _betaOptionKey = ValueKey<String>(
  'fading-multi-select-option-Beta',
);
const ValueKey<String> _gammaOptionKey = ValueKey<String>(
  'fading-multi-select-option-Gamma',
);
const ValueKey<String> _dismissAreaKey = ValueKey<String>(
  'fading-multi-select-dismiss-area',
);

const List<FadingMultiSelectOption<String>> _options =
    <FadingMultiSelectOption<String>>[
      FadingMultiSelectOption<String>(value: 'Alpha', label: 'Alpha'),
      FadingMultiSelectOption<String>(value: 'Beta', label: 'Beta'),
      FadingMultiSelectOption<String>(value: 'Gamma', label: 'Gamma'),
    ];

void main() {
  testWidgets('shows placeholder when no values selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        FadingMultiSelect<String>(
          placeholder: 'Pick channels',
          values: const <String>[],
          onChanged: (_) {},
          options: _options,
        ),
      ),
    );

    expect(find.text('Pick channels'), findsOneWidget);
  });

  testWidgets('renders a chip per selected value', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(
        FadingMultiSelect<String>(
          values: const <String>['Alpha', 'Beta'],
          onChanged: (_) {},
          options: _options,
        ),
      ),
    );

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
  });

  testWidgets('tapping trigger opens overlay with option rows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        FadingMultiSelect<String>(
          values: const <String>['Alpha'],
          onChanged: (_) {},
          options: _options,
        ),
      ),
    );

    await tester.tap(find.byType(FadingMultiSelect<String>));
    await tester.pumpAndSettle();

    expect(find.byKey(_alphaOptionKey), findsOneWidget);
    expect(find.byKey(_betaOptionKey), findsOneWidget);
    expect(find.byKey(_gammaOptionKey), findsOneWidget);
  });

  testWidgets('selecting an option row adds it in options order', (
    WidgetTester tester,
  ) async {
    List<String> values = <String>['Alpha'];
    List<String>? emitted;

    await tester.pumpWidget(
      buildApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FadingMultiSelect<String>(
              values: values,
              onChanged: (List<String> next) {
                emitted = next;
                setState(() {
                  values = next;
                });
              },
              options: _options,
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(FadingMultiSelect<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(_gammaOptionKey));
    await tester.pumpAndSettle();
    expect(emitted, <String>['Alpha', 'Gamma']);

    await tester.tap(find.byKey(_betaOptionKey));
    await tester.pumpAndSettle();
    expect(emitted, <String>['Alpha', 'Beta', 'Gamma']);
  });

  testWidgets('tapping a selected option row removes it', (
    WidgetTester tester,
  ) async {
    List<String> values = <String>['Alpha', 'Beta'];
    List<String>? emitted;

    await tester.pumpWidget(
      buildApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FadingMultiSelect<String>(
              values: values,
              onChanged: (List<String> next) {
                emitted = next;
                setState(() {
                  values = next;
                });
              },
              options: _options,
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(FadingMultiSelect<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(_betaOptionKey));
    await tester.pumpAndSettle();
    expect(emitted, <String>['Alpha']);
  });

  testWidgets('tapping a chip remove button removes value without toggling '
      'overlay', (WidgetTester tester) async {
    List<String> values = <String>['Alpha', 'Beta'];
    List<String>? emitted;

    await tester.pumpWidget(
      buildApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FadingMultiSelect<String>(
              values: values,
              onChanged: (List<String> next) {
                emitted = next;
                setState(() {
                  values = next;
                });
              },
              options: _options,
            );
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-multi-select-remove-Alpha')),
    );
    await tester.pumpAndSettle();

    expect(emitted, <String>['Beta']);
    expect(find.byKey(_alphaOptionKey), findsNothing);
  });

  testWidgets('maxValues caps additional selections', (
    WidgetTester tester,
  ) async {
    List<String> values = <String>['Alpha', 'Beta'];
    List<String>? emitted;

    await tester.pumpWidget(
      buildApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FadingMultiSelect<String>(
              values: values,
              maxValues: 2,
              onChanged: (List<String> next) {
                emitted = next;
                setState(() {
                  values = next;
                });
              },
              options: _options,
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(FadingMultiSelect<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(_gammaOptionKey));
    await tester.pumpAndSettle();

    expect(emitted, isNull);
    expect(values, <String>['Alpha', 'Beta']);
  });

  testWidgets('disabled multi select ignores taps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        FadingMultiSelect<String>(
          values: const <String>[],
          enabled: false,
          onChanged: (_) {},
          options: _options,
        ),
      ),
    );

    await tester.tap(find.byType(FadingMultiSelect<String>));
    await tester.pumpAndSettle();

    expect(find.byKey(_betaOptionKey), findsNothing);
  });

  testWidgets('opens with Enter and closes with Escape', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        FadingMultiSelect<String>(
          values: const <String>[],
          onChanged: (_) {},
          options: _options,
        ),
      ),
    );

    await tester.tap(find.byType(FadingMultiSelect<String>));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(_betaOptionKey), findsNothing);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byKey(_betaOptionKey), findsOneWidget);
  });

  testWidgets('dismisses when tapping outside', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(
        Column(
          children: <Widget>[
            FadingMultiSelect<String>(
              values: const <String>[],
              onChanged: (_) {},
              options: _options,
            ),
            const SizedBox(height: 24),
            const Text('Outside area'),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(FadingMultiSelect<String>));
    await tester.pumpAndSettle();
    expect(find.byKey(_betaOptionKey), findsOneWidget);

    await tester.tap(find.byKey(_dismissAreaKey));
    await tester.pumpAndSettle();
    expect(find.byKey(_betaOptionKey), findsNothing);
  });
}

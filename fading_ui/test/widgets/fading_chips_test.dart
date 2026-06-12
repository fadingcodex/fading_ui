import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

const ValueKey<String> _chipsBetaOptionKey = ValueKey<String>(
  'fading-chips-option-Beta',
);
const ValueKey<String> _chipsGammaOptionKey = ValueKey<String>(
  'fading-chips-option-Gamma',
);
const ValueKey<String> _chipsInputKey = ValueKey<String>('fading-chips-input');
const ValueKey<String> _chipsRemoveBetaKey = ValueKey<String>(
  'fading-chips-remove-Beta',
);

void main() {
  testWidgets('chips toggles options and emits selected values', (
    WidgetTester tester,
  ) async {
    List<String> values = <String>[];
    List<String>? emitted;

    await tester.pumpWidget(
      buildApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FadingChips(
              label: 'Tags',
              values: values,
              onChanged: (List<String> next) {
                emitted = next;
                setState(() {
                  values = next;
                });
              },
              options: const <FadingChipsOption>[
                FadingChipsOption(value: 'Alpha', label: 'Alpha'),
                FadingChipsOption(value: 'Beta', label: 'Beta'),
                FadingChipsOption(value: 'Gamma', label: 'Gamma'),
              ],
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(_chipsBetaOptionKey));
    await tester.pumpAndSettle();
    expect(emitted, <String>['Beta']);

    await tester.tap(find.byKey(_chipsGammaOptionKey));
    await tester.pumpAndSettle();
    expect(emitted, <String>['Beta', 'Gamma']);

    await tester.tap(find.byKey(_chipsBetaOptionKey));
    await tester.pumpAndSettle();
    expect(emitted, <String>['Gamma']);
  });

  testWidgets('chips accepts input chips and deduplicates ignoring case', (
    WidgetTester tester,
  ) async {
    List<String> values = <String>[];
    List<String>? emitted;

    await tester.pumpWidget(
      buildApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FadingChips(
              label: 'Tags',
              values: values,
              onChanged: (List<String> next) {
                emitted = next;
                setState(() {
                  values = next;
                });
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(_chipsInputKey));
    await tester.enterText(find.byType(EditableText), 'Alpha,Beta,');
    await tester.pumpAndSettle();
    expect(emitted, <String>['Alpha', 'Beta']);

    await tester.tap(find.byKey(_chipsInputKey));
    await tester.enterText(find.byType(EditableText), 'alpha');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(emitted, <String>['Alpha', 'Beta']);
  });

  testWidgets('chips remove action and backspace remove selected chips', (
    WidgetTester tester,
  ) async {
    List<String> values = <String>['Alpha', 'Beta'];
    List<String>? emitted;

    await tester.pumpWidget(
      buildApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FadingChips(
              label: 'Tags',
              values: values,
              onChanged: (List<String> next) {
                emitted = next;
                setState(() {
                  values = next;
                });
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(_chipsRemoveBetaKey));
    await tester.pumpAndSettle();
    expect(emitted, <String>['Alpha']);

    await tester.tap(find.byKey(_chipsInputKey));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.backspace);
    await tester.pumpAndSettle();
    expect(emitted, <String>[]);
  });

  testWidgets('disabled chips ignores interactions', (
    WidgetTester tester,
  ) async {
    List<String>? emitted;

    await tester.pumpWidget(
      buildApp(
        FadingChips(
          label: 'Tags',
          enabled: false,
          values: const <String>['Alpha'],
          onChanged: (List<String> next) {
            emitted = next;
          },
          options: const <FadingChipsOption>[
            FadingChipsOption(value: 'Beta', label: 'Beta'),
          ],
        ),
      ),
    );

    await tester.tap(find.byKey(_chipsBetaOptionKey));
    await tester.pumpAndSettle();
    expect(emitted, isNull);
  });
}

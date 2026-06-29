import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

const ValueKey<String> _header0Key = ValueKey<String>(
  'fading-accordion-header-0',
);
const ValueKey<String> _header1Key = ValueKey<String>(
  'fading-accordion-header-1',
);

void main() {
  testWidgets('accordion renders headers and expanded content from state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        FadingAccordion(
          expandedIndex: 1,
          onChanged: (_) {},
          items: const <FadingAccordionItem>[
            FadingAccordionItem(title: 'One', content: Text('One content')),
            FadingAccordionItem(title: 'Two', content: Text('Two content')),
          ],
        ),
      ),
    );

    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('One content'), findsNothing);
    expect(find.text('Two content'), findsOneWidget);
  });

  testWidgets('accordion expands on header tap and emits index', (
    WidgetTester tester,
  ) async {
    int? expandedIndex;
    int? emitted;

    await tester.pumpWidget(
      buildApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FadingAccordion(
              expandedIndex: expandedIndex,
              onChanged: (int? value) {
                emitted = value;
                setState(() {
                  expandedIndex = value;
                });
              },
              items: const <FadingAccordionItem>[
                FadingAccordionItem(title: 'One', content: Text('One content')),
                FadingAccordionItem(title: 'Two', content: Text('Two content')),
              ],
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(_header0Key));
    await tester.pumpAndSettle();

    expect(emitted, 0);
    expect(find.text('One content'), findsOneWidget);
    expect(find.text('Two content'), findsNothing);
  });

  testWidgets('accordion collapses expanded item when tapped again', (
    WidgetTester tester,
  ) async {
    int? expandedIndex = 0;
    int? emitted;

    await tester.pumpWidget(
      buildApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FadingAccordion(
              expandedIndex: expandedIndex,
              onChanged: (int? value) {
                emitted = value;
                setState(() {
                  expandedIndex = value;
                });
              },
              items: const <FadingAccordionItem>[
                FadingAccordionItem(title: 'One', content: Text('One content')),
                FadingAccordionItem(title: 'Two', content: Text('Two content')),
              ],
            );
          },
        ),
      ),
    );

    expect(find.text('One content'), findsOneWidget);

    await tester.tap(find.byKey(_header0Key));
    await tester.pumpAndSettle();

    expect(emitted, isNull);
    expect(find.text('One content'), findsNothing);
  });

  testWidgets('accordion keeps single expanded section when switching', (
    WidgetTester tester,
  ) async {
    int? expandedIndex = 0;

    await tester.pumpWidget(
      buildApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FadingAccordion(
              expandedIndex: expandedIndex,
              onChanged: (int? value) {
                setState(() {
                  expandedIndex = value;
                });
              },
              items: const <FadingAccordionItem>[
                FadingAccordionItem(title: 'One', content: Text('One content')),
                FadingAccordionItem(title: 'Two', content: Text('Two content')),
              ],
            );
          },
        ),
      ),
    );

    expect(find.text('One content'), findsOneWidget);

    await tester.tap(find.byKey(_header1Key));
    await tester.pumpAndSettle();

    expect(find.text('One content'), findsNothing);
    expect(find.text('Two content'), findsOneWidget);
  });

  testWidgets('disabled accordion ignores taps', (WidgetTester tester) async {
    int? emitted;

    await tester.pumpWidget(
      buildApp(
        FadingAccordion(
          enabled: false,
          expandedIndex: null,
          onChanged: (int? value) {
            emitted = value;
          },
          items: const <FadingAccordionItem>[
            FadingAccordionItem(title: 'One', content: Text('One content')),
            FadingAccordionItem(title: 'Two', content: Text('Two content')),
          ],
        ),
      ),
    );

    await tester.tap(find.byKey(_header0Key));
    await tester.pumpAndSettle();

    expect(emitted, isNull);
    expect(find.text('One content'), findsNothing);
  });

  testWidgets('disabled item ignores taps while enabled item still works', (
    WidgetTester tester,
  ) async {
    int? expandedIndex;

    await tester.pumpWidget(
      buildApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FadingAccordion(
              expandedIndex: expandedIndex,
              onChanged: (int? value) {
                setState(() {
                  expandedIndex = value;
                });
              },
              items: const <FadingAccordionItem>[
                FadingAccordionItem(title: 'One', content: Text('One content')),
                FadingAccordionItem(
                  title: 'Two',
                  enabled: false,
                  content: Text('Two content'),
                ),
              ],
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(_header1Key));
    await tester.pumpAndSettle();
    expect(find.text('Two content'), findsNothing);

    await tester.tap(find.byKey(_header0Key));
    await tester.pumpAndSettle();
    expect(find.text('One content'), findsOneWidget);
  });
}

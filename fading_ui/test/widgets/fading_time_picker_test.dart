import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

const ValueKey<String> _triggerKey = ValueKey<String>(
  'fading-time-picker-trigger',
);
const ValueKey<String> _dismissAreaKey = ValueKey<String>(
  'fading-time-picker-dismiss-area',
);
const ValueKey<String> _minuteUpKey = ValueKey<String>(
  'fading-time-picker-minute-up',
);
const ValueKey<String> _meridiemToggleKey = ValueKey<String>(
  'fading-time-picker-meridiem-toggle',
);
const ValueKey<String> _confirmKey = ValueKey<String>(
  'fading-time-picker-confirm',
);

void main() {
  testWidgets('renders label and initial selected time', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        SizedBox(
          width: 320,
          child: FadingTimePicker(
            label: 'Launch time',
            selectedTime: const TimeOfDay(hour: 14, minute: 32),
            onChanged: _noopTimeChanged,
          ),
        ),
      ),
    );

    expect(find.text('Launch time'), findsOneWidget);
    expect(find.text('14:32'), findsOneWidget);
  });

  testWidgets('applies minute adjustments and updates trigger summary', (
    WidgetTester tester,
  ) async {
    TimeOfDay selected = const TimeOfDay(hour: 14, minute: 32);
    TimeOfDay? emitted;

    await tester.pumpWidget(
      buildApp(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 320,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return FadingTimePicker(
                  label: 'Launch time',
                  selectedTime: selected,
                  onChanged: (TimeOfDay value) {
                    emitted = value;
                    setState(() {
                      selected = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(_triggerKey));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(_minuteUpKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_confirmKey));
    await tester.pumpAndSettle();

    expect(emitted, isNotNull);
    expect(emitted!.hour, 14);
    expect(emitted!.minute, 33);
    expect(find.text('14:33'), findsOneWidget);
  });

  testWidgets('dismisses overlay when tapping outside', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        Column(
          children: <Widget>[
            FadingTimePicker(
              label: 'Launch time',
              selectedTime: const TimeOfDay(hour: 14, minute: 32),
              onChanged: _noopTimeChanged,
            ),
            const SizedBox(height: 24),
            const Text('Outside area'),
          ],
        ),
      ),
    );

    await tester.tap(find.byKey(_triggerKey));
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsOneWidget);

    await tester.tap(find.byKey(_dismissAreaKey));
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsNothing);
  });

  testWidgets('disabled picker ignores taps', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(
        FadingTimePicker(
          label: 'Launch time',
          selectedTime: const TimeOfDay(hour: 14, minute: 32),
          enabled: false,
          onChanged: _noopTimeChanged,
        ),
      ),
    );

    await tester.tap(find.byKey(_triggerKey));
    await tester.pumpAndSettle();

    expect(find.text('Apply'), findsNothing);
  });

  testWidgets('supports 12-hour display and meridiem changes', (
    WidgetTester tester,
  ) async {
    TimeOfDay selected = const TimeOfDay(hour: 14, minute: 5);

    await tester.pumpWidget(
      buildApp(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 320,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return FadingTimePicker(
                  label: 'Arrival time',
                  selectedTime: selected,
                  use24HourFormat: false,
                  onChanged: (TimeOfDay value) {
                    setState(() {
                      selected = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('2:05 PM'), findsOneWidget);

    await tester.tap(find.byKey(_triggerKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_meridiemToggleKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_confirmKey));
    await tester.pumpAndSettle();

    expect(find.text('2:05 AM'), findsOneWidget);
  });

  testWidgets('opens with Enter and closes with Escape', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        FadingTimePicker(
          label: 'Launch time',
          selectedTime: const TimeOfDay(hour: 14, minute: 32),
          onChanged: _noopTimeChanged,
        ),
      ),
    );

    await tester.tap(find.byKey(_triggerKey));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsNothing);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsOneWidget);
  });
}

void _noopTimeChanged(TimeOfDay value) {}

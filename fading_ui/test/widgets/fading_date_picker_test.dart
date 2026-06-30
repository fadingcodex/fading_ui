import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

const ValueKey<String> _previousMonthKey = ValueKey<String>(
  'fading-date-picker-prev-month',
);
const ValueKey<String> _nextMonthKey = ValueKey<String>(
  'fading-date-picker-next-month',
);
const ValueKey<String> _monthLabelKey = ValueKey<String>(
  'fading-date-picker-month-label',
);

String _monthLabelText(WidgetTester tester) {
  final Text label = tester.widget<Text>(find.byKey(_monthLabelKey));
  return label.data ?? '';
}

void main() {
  testWidgets('renders label and initial selected date', (
    WidgetTester tester,
  ) async {
    final DateTime selected = DateTime(2026, 6, 20);

    await tester.pumpWidget(
      buildApp(
        SizedBox(
          width: 360,
          child: FadingDatePicker(
            label: 'Mission date',
            selectedDate: selected,
            onChanged: _noopDateChanged,
          ),
        ),
      ),
    );

    expect(find.text('Mission date'), findsOneWidget);
    expect(find.byKey(ValueKey<String>(_dayKey(selected))), findsOneWidget);
  });

  testWidgets('tapping a valid day emits onChanged', (
    WidgetTester tester,
  ) async {
    DateTime? emitted;

    await tester.pumpWidget(
      buildApp(
        SizedBox(
          width: 360,
          child: FadingDatePicker(
            selectedDate: DateTime(2026, 6, 10),
            onChanged: (DateTime value) {
              emitted = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-date-picker-day-2026-06-15')),
    );
    await tester.pumpAndSettle();

    expect(emitted, DateTime(2026, 6, 15));
  });

  testWidgets('month navigation updates visible month label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        SizedBox(
          width: 360,
          child: FadingDatePicker(
            selectedDate: DateTime(2026, 6, 10),
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(_monthLabelText(tester), 'June 2026');

    await tester.tap(find.byKey(_nextMonthKey));
    await tester.pumpAndSettle();

    expect(_monthLabelText(tester), 'July 2026');

    await tester.tap(find.byKey(_previousMonthKey));
    await tester.pumpAndSettle();

    expect(_monthLabelText(tester), 'June 2026');
  });

  testWidgets('disabled picker ignores day taps', (WidgetTester tester) async {
    DateTime? emitted;

    await tester.pumpWidget(
      buildApp(
        SizedBox(
          width: 360,
          child: FadingDatePicker(
            selectedDate: DateTime(2026, 6, 10),
            enabled: false,
            onChanged: (DateTime value) {
              emitted = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-date-picker-day-2026-06-15')),
    );
    await tester.pumpAndSettle();

    expect(emitted, isNull);
  });

  testWidgets('respects firstDate and lastDate range constraints', (
    WidgetTester tester,
  ) async {
    DateTime? emitted;

    await tester.pumpWidget(
      buildApp(
        SizedBox(
          width: 360,
          child: FadingDatePicker(
            selectedDate: DateTime(2026, 6, 15),
            firstDate: DateTime(2026, 6, 10),
            lastDate: DateTime(2026, 6, 20),
            onChanged: (DateTime value) {
              emitted = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-date-picker-day-2026-06-05')),
    );
    await tester.pumpAndSettle();
    expect(emitted, isNull);

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-date-picker-day-2026-06-12')),
    );
    await tester.pumpAndSettle();
    expect(emitted, DateTime(2026, 6, 12));
  });
}

void _noopDateChanged(DateTime value) {}

String _dayKey(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return 'fading-date-picker-day-${value.year}-$month-$day';
}

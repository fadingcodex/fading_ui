import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('FadingRangeSlider', () {
    testWidgets('renders without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          FadingRangeSlider(
            startValue: 20,
            endValue: 80,
            min: 0,
            max: 100,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(FadingRangeSlider), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('displays label when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          FadingRangeSlider(
            startValue: 20,
            endValue: 80,
            min: 0,
            max: 100,
            label: 'Price Range',
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Price Range'), findsOneWidget);
    });

    testWidgets('emits changed values when start thumb is dragged left', (
      WidgetTester tester,
    ) async {
      RangeValues rangeValues = (start: 20, end: 80);

      await tester.pumpWidget(
        buildApp(
          FadingRangeSlider(
            startValue: rangeValues.start,
            endValue: rangeValues.end,
            min: 0,
            max: 100,
            onChanged: (RangeValues value) {
              rangeValues = value;
            },
          ),
        ),
      );

      final Finder sliderTrack = find.descendant(
        of: find.byType(FadingRangeSlider),
        matching: find.byType(GestureDetector),
      );

      final RenderBox box = tester.renderObject<RenderBox>(sliderTrack);
      final double width = box.size.width;
      final double startThumbX = (20 / 100) * width;

      await tester.dragFrom(
        box.localToGlobal(Offset(startThumbX, 14)),
        const Offset(-40, 0),
      );
      await tester.pumpAndSettle();

      expect(rangeValues.start, lessThan(20));
      expect(rangeValues.end, equals(80));
    });

    testWidgets('emits changed values when end thumb is dragged right', (
      WidgetTester tester,
    ) async {
      RangeValues rangeValues = (start: 20, end: 80);

      await tester.pumpWidget(
        buildApp(
          FadingRangeSlider(
            startValue: rangeValues.start,
            endValue: rangeValues.end,
            min: 0,
            max: 100,
            onChanged: (RangeValues value) {
              rangeValues = value;
            },
          ),
        ),
      );

      final Finder sliderTrack = find.descendant(
        of: find.byType(FadingRangeSlider),
        matching: find.byType(GestureDetector),
      );

      final RenderBox box = tester.renderObject<RenderBox>(sliderTrack);
      final double width = box.size.width;
      final double endThumbX = (80 / 100) * width;

      await tester.dragFrom(
        box.localToGlobal(Offset(endThumbX, 14)),
        const Offset(40, 0),
      );
      await tester.pumpAndSettle();

      expect(rangeValues.start, equals(20));
      expect(rangeValues.end, greaterThan(80));
    });

    testWidgets('respects min constraint', (WidgetTester tester) async {
      RangeValues rangeValues = (start: 20, end: 80);

      await tester.pumpWidget(
        buildApp(
          FadingRangeSlider(
            startValue: rangeValues.start,
            endValue: rangeValues.end,
            min: 0,
            max: 100,
            onChanged: (RangeValues value) {
              rangeValues = value;
            },
          ),
        ),
      );

      final Finder sliderTrack = find.descendant(
        of: find.byType(FadingRangeSlider),
        matching: find.byType(GestureDetector),
      );

      final RenderBox box = tester.renderObject<RenderBox>(sliderTrack);
      final double width = box.size.width;
      final double startThumbX = (20 / 100) * width;

      await tester.dragFrom(
        box.localToGlobal(Offset(startThumbX, 14)),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      expect(rangeValues.start, greaterThanOrEqualTo(0));
      expect(rangeValues.start, lessThanOrEqualTo(rangeValues.end));
    });

    testWidgets('respects max constraint', (WidgetTester tester) async {
      RangeValues rangeValues = (start: 20, end: 80);

      await tester.pumpWidget(
        buildApp(
          FadingRangeSlider(
            startValue: rangeValues.start,
            endValue: rangeValues.end,
            min: 0,
            max: 100,
            onChanged: (RangeValues value) {
              rangeValues = value;
            },
          ),
        ),
      );

      final Finder sliderTrack = find.descendant(
        of: find.byType(FadingRangeSlider),
        matching: find.byType(GestureDetector),
      );

      final RenderBox box = tester.renderObject<RenderBox>(sliderTrack);
      final double width = box.size.width;
      final double endThumbX = (80 / 100) * width;

      await tester.dragFrom(
        box.localToGlobal(Offset(endThumbX, 14)),
        const Offset(500, 0),
      );
      await tester.pumpAndSettle();

      expect(rangeValues.end, lessThanOrEqualTo(100));
      expect(rangeValues.start, lessThanOrEqualTo(rangeValues.end));
    });

    testWidgets('prevents start thumb from crossing end thumb', (
      WidgetTester tester,
    ) async {
      RangeValues rangeValues = (start: 20, end: 80);

      await tester.pumpWidget(
        buildApp(
          FadingRangeSlider(
            startValue: rangeValues.start,
            endValue: rangeValues.end,
            min: 0,
            max: 100,
            onChanged: (RangeValues value) {
              rangeValues = value;
            },
          ),
        ),
      );

      final Finder sliderTrack = find.descendant(
        of: find.byType(FadingRangeSlider),
        matching: find.byType(GestureDetector),
      );

      final RenderBox box = tester.renderObject<RenderBox>(sliderTrack);
      final double width = box.size.width;
      final double startThumbX = (20 / 100) * width;

      await tester.dragFrom(
        box.localToGlobal(Offset(startThumbX, 14)),
        const Offset(500, 0),
      );
      await tester.pumpAndSettle();

      expect(rangeValues.start, lessThanOrEqualTo(rangeValues.end));
    });

    testWidgets('prevents end thumb from crossing start thumb', (
      WidgetTester tester,
    ) async {
      RangeValues rangeValues = (start: 20, end: 80);

      await tester.pumpWidget(
        buildApp(
          FadingRangeSlider(
            startValue: rangeValues.start,
            endValue: rangeValues.end,
            min: 0,
            max: 100,
            onChanged: (RangeValues value) {
              rangeValues = value;
            },
          ),
        ),
      );

      final Finder sliderTrack = find.descendant(
        of: find.byType(FadingRangeSlider),
        matching: find.byType(GestureDetector),
      );

      final RenderBox box = tester.renderObject<RenderBox>(sliderTrack);
      final double width = box.size.width;
      final double endThumbX = (80 / 100) * width;

      await tester.dragFrom(
        box.localToGlobal(Offset(endThumbX, 14)),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      expect(rangeValues.end, greaterThanOrEqualTo(rangeValues.start));
    });

    testWidgets('allows thumbs to touch at same value', (
      WidgetTester tester,
    ) async {
      RangeValues rangeValues = (start: 20, end: 80);

      await tester.pumpWidget(
        buildApp(
          FadingRangeSlider(
            startValue: rangeValues.start,
            endValue: rangeValues.end,
            min: 0,
            max: 100,
            onChanged: (RangeValues value) {
              rangeValues = value;
            },
          ),
        ),
      );

      final Finder sliderTrack = find.descendant(
        of: find.byType(FadingRangeSlider),
        matching: find.byType(GestureDetector),
      );

      final RenderBox box = tester.renderObject<RenderBox>(sliderTrack);
      final double width = box.size.width;
      final double startThumbX = (20 / 100) * width;

      await tester.dragFrom(
        box.localToGlobal(Offset(startThumbX, 14)),
        Offset(width * 0.6, 0),
      );
      await tester.pumpAndSettle();

      expect(rangeValues.start, lessThanOrEqualTo(rangeValues.end));
    });

    testWidgets('does not emit when disabled', (WidgetTester tester) async {
      RangeValues rangeValues = (start: 20, end: 80);
      int changeCount = 0;

      await tester.pumpWidget(
        buildApp(
          FadingRangeSlider(
            startValue: rangeValues.start,
            endValue: rangeValues.end,
            min: 0,
            max: 100,
            enabled: false,
            onChanged: (RangeValues value) {
              changeCount++;
              rangeValues = value;
            },
          ),
        ),
      );

      final Finder sliderTrack = find.descendant(
        of: find.byType(FadingRangeSlider),
        matching: find.byType(GestureDetector),
      );

      final RenderBox box = tester.renderObject<RenderBox>(sliderTrack);
      final double width = box.size.width;
      final double startThumbX = (20 / 100) * width;

      await tester.dragFrom(
        box.localToGlobal(Offset(startThumbX, 14)),
        const Offset(40, 0),
      );
      await tester.pumpAndSettle();

      expect(changeCount, equals(0));
      expect(rangeValues, (start: 20, end: 80));
    });

    testWidgets('does not emit when onChanged is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          const FadingRangeSlider(
            startValue: 20,
            endValue: 80,
            min: 0,
            max: 100,
            onChanged: null,
          ),
        ),
      );

      final Finder sliderTrack = find.descendant(
        of: find.byType(FadingRangeSlider),
        matching: find.byType(GestureDetector),
      );

      final RenderBox box = tester.renderObject<RenderBox>(sliderTrack);
      final double width = box.size.width;
      final double startThumbX = (20 / 100) * width;

      await tester.dragFrom(
        box.localToGlobal(Offset(startThumbX, 14)),
        const Offset(40, 0),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FadingRangeSlider), findsOneWidget);
    });

    testWidgets('handles fractional values', (WidgetTester tester) async {
      RangeValues rangeValues = (start: 0.25, end: 0.75);

      await tester.pumpWidget(
        buildApp(
          FadingRangeSlider(
            startValue: rangeValues.start,
            endValue: rangeValues.end,
            min: 0,
            max: 1,
            onChanged: (RangeValues value) {
              rangeValues = value;
            },
          ),
        ),
      );

      final Finder sliderTrack = find.descendant(
        of: find.byType(FadingRangeSlider),
        matching: find.byType(GestureDetector),
      );

      final RenderBox box = tester.renderObject<RenderBox>(sliderTrack);
      final double width = box.size.width;
      final double startThumbX = (0.25) * width;

      await tester.dragFrom(
        box.localToGlobal(Offset(startThumbX, 14)),
        const Offset(20, 0),
      );
      await tester.pumpAndSettle();

      expect(rangeValues.start, greaterThan(0.25));
      expect(rangeValues.start, lessThanOrEqualTo(1));
      expect(rangeValues.start, lessThanOrEqualTo(rangeValues.end));
    });

    testWidgets('works with negative ranges', (WidgetTester tester) async {
      RangeValues rangeValues = (start: -50, end: 50);

      await tester.pumpWidget(
        buildApp(
          FadingRangeSlider(
            startValue: rangeValues.start,
            endValue: rangeValues.end,
            min: -100,
            max: 100,
            onChanged: (RangeValues value) {
              rangeValues = value;
            },
          ),
        ),
      );

      final Finder sliderTrack = find.descendant(
        of: find.byType(FadingRangeSlider),
        matching: find.byType(GestureDetector),
      );

      final RenderBox box = tester.renderObject<RenderBox>(sliderTrack);
      final double width = box.size.width;
      // -50 is at 25% position: ((-50) - (-100)) / (100 - (-100)) = 50/200 = 0.25
      final double startThumbX = 0.25 * width;

      await tester.dragFrom(
        box.localToGlobal(Offset(startThumbX, 14)),
        const Offset(40, 0),
      );
      await tester.pumpAndSettle();

      expect(rangeValues.start, greaterThanOrEqualTo(-100));
      expect(rangeValues.end, lessThanOrEqualTo(100));
      expect(rangeValues.start, lessThanOrEqualTo(rangeValues.end));
    });

    testWidgets('initializes with start less than or equal to end', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          FadingRangeSlider(
            startValue: 30,
            endValue: 70,
            min: 0,
            max: 100,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(FadingRangeSlider), findsOneWidget);
    });
  });
}

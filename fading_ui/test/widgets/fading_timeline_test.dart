import 'dart:ui' show SemanticsAction;

import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('renders event fields in supplied order', (tester) async {
    await tester.pumpWidget(
      buildApp(
        const FadingTimeline(
          items: <FadingTimelineItem>[
            FadingTimelineItem(
              title: 'Latest event',
              timestamp: '10:30',
              description: 'Deployment completed.',
            ),
            FadingTimelineItem(title: 'Earlier event', timestamp: '09:00'),
          ],
        ),
      ),
    );

    expect(find.text('Deployment completed.'), findsOneWidget);
    expect(find.text('10:30'), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Latest event')).dy,
      lessThan(tester.getTopLeft(find.text('Earlier event')).dy),
    );
  });

  testWidgets('empty timeline has zero height and no markers', (tester) async {
    await tester.pumpWidget(
      buildApp(
        const Align(
          alignment: Alignment.topLeft,
          child: FadingTimeline(items: <FadingTimelineItem>[]),
        ),
      ),
    );

    expect(tester.getSize(find.byType(FadingTimeline)).height, 0);
    expect(find.byType(PositionedDirectional), findsNothing);
    expect(find.byType(Text), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('single title-only event has no connector', (tester) async {
    await tester.pumpWidget(
      buildApp(
        const FadingTimeline(
          items: <FadingTimelineItem>[FadingTimelineItem(title: 'Created')],
        ),
      ),
    );

    expect(find.text('Created'), findsOneWidget);
    expect(find.byType(PositionedDirectional), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('connectors join markers with no leading or trailing line', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        const FadingTimeline(
          items: <FadingTimelineItem>[
            FadingTimelineItem(
              title: 'First',
              description: 'Created\nValidated\nPublished',
            ),
            FadingTimelineItem(title: 'Middle'),
            FadingTimelineItem(title: 'Last'),
          ],
        ),
      ),
    );

    final Finder stacks = find.descendant(
      of: find.byType(FadingTimeline),
      matching: find.byType(Stack),
    );
    final Finder lines = find.descendant(
      of: find.byType(FadingTimeline),
      matching: find.byType(PositionedDirectional),
    );
    expect(stacks, findsNWidgets(3));
    expect(lines, findsNWidgets(4));
    final List<PositionedDirectional> positions = tester
        .widgetList<PositionedDirectional>(lines)
        .toList();
    expect(positions.first.top, 14);
    expect(positions.first.bottom, 0);
    expect(positions.last.top, 0);
    expect(positions.last.height, 14);

    final Rect firstLine = tester.getRect(lines.at(0));
    final Rect nextLine = tester.getRect(lines.at(1));
    expect(firstLine.height, greaterThan(48));
    expect(firstLine.bottom, nextLine.top);
    expect(firstLine.left, nextLine.left);
    final Rect middleLine = tester.getRect(lines.at(2));
    final Rect lastLine = tester.getRect(lines.at(3));
    expect(middleLine.bottom, lastLine.top);
  });

  testWidgets('renders custom icon and actionable content', (tester) async {
    bool called = false;
    await tester.pumpWidget(
      buildApp(
        FadingTimeline(
          items: <FadingTimelineItem>[
            FadingTimelineItem(
              title: 'Review ready',
              icon: Icons.check,
              content: FadingButton(
                label: 'Review',
                onPressed: () => called = true,
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.tap(find.text('Review'));
    await tester.pump();
    expect(called, isTrue);
  });

  testWidgets('wraps long content at narrow widths and large text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        const Center(
          child: SizedBox(
            width: 220,
            child: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2)),
              child: SingleChildScrollView(
                child: FadingTimeline(
                  items: <FadingTimelineItem>[
                    FadingTimelineItem(
                      title: 'A long deployment event that must wrap',
                      timestamp: 'October 9, 2026 at 10:30 in the morning',
                      description:
                          'The latest telemetry records are now ready.',
                      content: Text('Additional details that also wrap.'),
                    ),
                    FadingTimelineItem(title: 'Next event'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getBottomLeft(find.text('Additional details that also wrap.')).dy,
      lessThan(tester.getTopLeft(find.text('Next event')).dy),
    );
  });

  testWidgets('places markers at the directional start in RTL', (tester) async {
    await tester.pumpWidget(
      buildApp(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: FadingTimeline(
            items: <FadingTimelineItem>[
              FadingTimelineItem(title: 'First', icon: Icons.check),
              FadingTimelineItem(title: 'Second'),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getCenter(find.byIcon(Icons.check)).dx,
      greaterThan(tester.getTopRight(find.text('First')).dx),
    );
    final Finder line = find.byType(PositionedDirectional).first;
    expect(
      tester.getCenter(line).dx,
      tester.getCenter(find.byIcon(Icons.check)).dx,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('responds to theme changes', (tester) async {
    Future<void> pumpTheme(FadingThemeName name) async {
      await tester.pumpWidget(
        buildApp(
          FadingThemeScope(
            theme: name,
            data: FadingThemeData.fromTheme(name),
            child: const FadingTimeline(
              items: <FadingTimelineItem>[
                FadingTimelineItem(
                  title: 'Themed event',
                  timestamp: 'Now',
                  icon: Icons.check,
                ),
                FadingTimelineItem(title: 'Next'),
              ],
            ),
          ),
        ),
      );
    }

    for (final FadingThemeName name in FadingThemeName.values) {
      await pumpTheme(name);
      final FadingThemeData theme = FadingThemeData.fromTheme(name);
      expect(
        tester.widget<Text>(find.text('Themed event')).style!.color,
        theme.textPrimary,
      );
      expect(
        tester.widget<Text>(find.text('Now')).style!.color,
        theme.textMuted,
      );
      expect(tester.widget<Icon>(find.byIcon(Icons.check)).color, theme.accent);
      final ColoredBox rail = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(PositionedDirectional).first,
          matching: find.byType(ColoredBox),
        ),
      );
      expect(rail.color, theme.border);
    }
  });

  testWidgets(
    'exposes event text and action without decorative icon semantics',
    (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          buildApp(
            FadingTimeline(
              items: <FadingTimelineItem>[
                FadingTimelineItem(
                  title: 'Ready',
                  timestamp: 'Today',
                  description: 'Review the import.',
                  icon: Icons.check,
                  content: FadingButton(label: 'Open', onPressed: () {}),
                ),
              ],
            ),
          ),
        );

        expect(find.bySemanticsLabel('Ready'), findsOneWidget);
        expect(find.bySemanticsLabel('Today'), findsOneWidget);
        expect(find.bySemanticsLabel('Review the import.'), findsOneWidget);
        expect(find.bySemanticsLabel('Open'), findsOneWidget);
        expect(
          tester
              .widget<ExcludeSemantics>(
                find.ancestor(
                  of: find.byIcon(Icons.check),
                  matching: find.byType(ExcludeSemantics),
                ),
              )
              .excluding,
          isTrue,
        );
        expect(
          tester
              .getSemantics(find.byType(FadingButton))
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue,
        );
      } finally {
        handle.dispose();
      }
    },
  );
}

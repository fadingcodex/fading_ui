import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('badge renders default label and tone', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(const FadingBadge(label: 'Queued')));

    expect(find.text('Queued'), findsOneWidget);

    final Finder badgeFinder = find.byType(FadingBadge);
    final Finder containerFinder = find.descendant(
      of: badgeFinder,
      matching: find.byType(Container),
    );
    final Container container = tester.widget<Container>(containerFinder.first);
    final BoxDecoration decoration = container.decoration! as BoxDecoration;

    final FadingThemeData theme = FadingThemeData.fromTheme(
      FadingThemeName.abyss,
    );
    expect(decoration.color, theme.surfaceRaised);
  });

  testWidgets('badge applies semantic tones', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(
        const Column(
          children: <Widget>[
            FadingBadge(label: 'Success', tone: FadingBadgeTone.success),
            FadingBadge(label: 'Warning', tone: FadingBadgeTone.warning),
            FadingBadge(label: 'Critical', tone: FadingBadgeTone.critical),
          ],
        ),
      ),
    );

    final FadingThemeData theme = FadingThemeData.fromTheme(
      FadingThemeName.abyss,
    );
    final Finder badgeFinder = find.byType(FadingBadge);

    final Container successContainer = tester.widget<Container>(
      find
          .descendant(of: badgeFinder.at(0), matching: find.byType(Container))
          .first,
    );
    final Container warningContainer = tester.widget<Container>(
      find
          .descendant(of: badgeFinder.at(1), matching: find.byType(Container))
          .first,
    );
    final Container criticalContainer = tester.widget<Container>(
      find
          .descendant(of: badgeFinder.at(2), matching: find.byType(Container))
          .first,
    );

    expect(
      (successContainer.decoration! as BoxDecoration).color,
      theme.success,
    );
    expect((warningContainer.decoration! as BoxDecoration).color, theme.accent);
    expect((criticalContainer.decoration! as BoxDecoration).color, theme.error);
  });

  testWidgets('badge can use basic color source', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(
        const Column(
          children: <Widget>[
            FadingBadge(
              label: 'Neutral',
              colorSource: FadingBadgeColorSource.basic,
            ),
            FadingBadge(
              label: 'Warning',
              tone: FadingBadgeTone.warning,
              colorSource: FadingBadgeColorSource.basic,
            ),
          ],
        ),
      ),
    );

    final Finder badgeFinder = find.byType(FadingBadge);
    final Container neutralContainer = tester.widget<Container>(
      find
          .descendant(of: badgeFinder.at(0), matching: find.byType(Container))
          .first,
    );
    final Container warningContainer = tester.widget<Container>(
      find
          .descendant(of: badgeFinder.at(1), matching: find.byType(Container))
          .first,
    );

    expect(
      (neutralContainer.decoration! as BoxDecoration).color,
      FadingColors.daybreak,
    );
    expect(
      (warningContainer.decoration! as BoxDecoration).color,
      FadingColors.amberGlow,
    );
  });

  testWidgets('badge handles long labels without overflow exceptions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        const SizedBox(
          width: 220,
          child: FadingBadge(
            label: 'Node synchronization pending supervisor confirmation',
            tone: FadingBadgeTone.warning,
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);

    final Text label = tester.widget<Text>(
      find.descendant(
        of: find.byType(FadingBadge),
        matching: find.byType(Text),
      ),
    );
    expect(label.maxLines, 1);
    expect(label.overflow, TextOverflow.ellipsis);
  });
}

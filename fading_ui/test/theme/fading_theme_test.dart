import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}

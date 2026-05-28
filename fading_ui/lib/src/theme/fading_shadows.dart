import 'package:flutter/painting.dart';

import 'fading_theme_data.dart';

final class FadingShadows {
  FadingShadows._();

  static List<BoxShadow> raised({
    FadingThemeData? theme,
    double blur = 18,
    double offset = 8,
  }) {
    final FadingThemeData activeTheme = theme ?? FadingThemeData.night;
    return <BoxShadow>[
      BoxShadow(
        color: activeTheme.shadowDark,
        offset: Offset(offset, offset),
        blurRadius: blur,
      ),
      BoxShadow(
        color: activeTheme.shadowLight,
        offset: Offset(-offset * 0.7, -offset * 0.7),
        blurRadius: blur,
      ),
    ];
  }

  static List<BoxShadow> inset({
    FadingThemeData? theme,
    double blur = 12,
    double offset = 5,
  }) {
    final FadingThemeData activeTheme = theme ?? FadingThemeData.night;
    return <BoxShadow>[
      BoxShadow(
        color: activeTheme.insetShadowDark,
        offset: Offset(offset * 0.8, offset * 0.8),
        blurRadius: blur,
        spreadRadius: -2,
      ),
      BoxShadow(
        color: activeTheme.insetShadowLight,
        offset: Offset(-2, -2),
        blurRadius: 5,
        spreadRadius: -2,
      ),
    ];
  }

  static Border side({FadingThemeData? theme}) {
    final FadingThemeData activeTheme = theme ?? FadingThemeData.night;
    return Border.all(color: activeTheme.border.withValues(alpha: 0.65));
  }
}

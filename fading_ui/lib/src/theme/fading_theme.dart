import 'package:flutter/widgets.dart';

import 'fading_colors.dart';
import 'fading_theme_data.dart';
import 'fading_theme_scope.dart';

final class FadingTheme {
  FadingTheme._();

  static FadingThemeData resolve(BuildContext context) {
    return FadingThemeScope.of(context);
  }

  static TextStyle displayLargeOf(BuildContext context) {
    return resolve(context).displayLarge;
  }

  static TextStyle displayMediumOf(BuildContext context) {
    return resolve(context).displayMedium;
  }

  static TextStyle titleLargeOf(BuildContext context) {
    return resolve(context).titleLarge;
  }

  static TextStyle bodyLargeOf(BuildContext context) {
    return resolve(context).bodyLarge;
  }

  static TextStyle bodyMediumOf(BuildContext context) {
    return resolve(context).bodyMedium;
  }

  static TextStyle labelLargeOf(BuildContext context) {
    return resolve(context).labelLarge;
  }

  static const TextStyle displayLarge = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: FadingColors.starlight,
    height: 1.05,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: FadingColors.starlight,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: FadingColors.starlight,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: FadingColors.starlight,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: FadingColors.starlight,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: FadingColors.starlight,
  );
}

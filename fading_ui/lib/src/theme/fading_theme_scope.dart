import 'package:flutter/widgets.dart';

import 'fading_theme_data.dart';

class FadingThemeScope extends InheritedWidget {
  const FadingThemeScope({
    super.key,
    required this.theme,
    required this.data,
    required super.child,
  });

  final FadingThemeName theme;
  final FadingThemeData data;

  static FadingThemeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FadingThemeScope>();
  }

  static FadingThemeData of(BuildContext context) {
    return maybeOf(context)?.data ?? FadingThemeData.abyss;
  }

  static FadingThemeName themeOf(BuildContext context) {
    return maybeOf(context)?.theme ?? FadingThemeName.abyss;
  }

  @override
  bool updateShouldNotify(covariant FadingThemeScope oldWidget) {
    return oldWidget.theme != theme || oldWidget.data != data;
  }
}

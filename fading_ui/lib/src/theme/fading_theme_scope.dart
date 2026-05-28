import 'package:flutter/widgets.dart';

import 'fading_theme_data.dart';

class FadingThemeScope extends InheritedWidget {
  const FadingThemeScope({
    super.key,
    required this.mode,
    required this.data,
    required super.child,
  });

  final FadingThemeMode mode;
  final FadingThemeData data;

  static FadingThemeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FadingThemeScope>();
  }

  static FadingThemeData of(BuildContext context) {
    return maybeOf(context)?.data ?? FadingThemeData.night;
  }

  static FadingThemeMode modeOf(BuildContext context) {
    return maybeOf(context)?.mode ?? FadingThemeMode.night;
  }

  @override
  bool updateShouldNotify(covariant FadingThemeScope oldWidget) {
    return oldWidget.mode != mode || oldWidget.data != data;
  }
}

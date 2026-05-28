import 'package:flutter/widgets.dart';

import 'fading_colors.dart';

enum FadingThemeMode { day, night }

final class FadingThemeData {
  const FadingThemeData({
    required this.backgroundStart,
    required this.backgroundMiddle,
    required this.backgroundEnd,
    required this.surfaceRaised,
    required this.surfaceInset,
    required this.textPrimary,
    required this.textMuted,
    required this.border,
    required this.accent,
    required this.accentStrong,
    required this.success,
    required this.error,
    required this.shadowDark,
    required this.shadowLight,
    required this.insetShadowDark,
    required this.insetShadowLight,
    required this.displayLarge,
    required this.displayMedium,
    required this.titleLarge,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.labelLarge,
  });

  final Color backgroundStart;
  final Color backgroundMiddle;
  final Color backgroundEnd;

  final Color surfaceRaised;
  final Color surfaceInset;

  final Color textPrimary;
  final Color textMuted;

  final Color border;
  final Color accent;
  final Color accentStrong;

  final Color success;
  final Color error;

  final Color shadowDark;
  final Color shadowLight;
  final Color insetShadowDark;
  final Color insetShadowLight;

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle titleLarge;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle labelLarge;

  static const FadingThemeData night = FadingThemeData(
    backgroundStart: FadingColors.midnight,
    backgroundMiddle: FadingColors.dusk,
    backgroundEnd: FadingColors.dust,
    surfaceRaised: FadingColors.dusk,
    surfaceInset: FadingColors.dust,
    textPrimary: FadingColors.starlight,
    textMuted: FadingColors.storm,
    border: FadingColors.border,
    accent: FadingColors.amberGlow,
    accentStrong: FadingColors.ember,
    success: FadingColors.success,
    error: FadingColors.error,
    shadowDark: Color(0x59000000),
    shadowLight: Color(0x40FFFFFF),
    insetShadowDark: Color(0x40000000),
    insetShadowLight: Color(0x33FFFFFF),
    displayLarge: TextStyle(
      fontSize: 42,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: FadingColors.starlight,
      height: 1.05,
    ),
    displayMedium: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: FadingColors.starlight,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: FadingColors.starlight,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: FadingColors.starlight,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: FadingColors.starlight,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: FadingColors.starlight,
    ),
  );

  static const FadingThemeData day = FadingThemeData(
    backgroundStart: FadingColors.daybreak,
    backgroundMiddle: FadingColors.sunwash,
    backgroundEnd: FadingColors.sand,
    surfaceRaised: FadingColors.sunwash,
    surfaceInset: FadingColors.linen,
    textPrimary: FadingColors.ink,
    textMuted: FadingColors.mist,
    border: FadingColors.dayBorder,
    accent: FadingColors.amberGlow,
    accentStrong: FadingColors.ember,
    success: FadingColors.success,
    error: FadingColors.error,
    shadowDark: Color(0x26000000),
    shadowLight: Color(0xB3FFFFFF),
    insetShadowDark: Color(0x1F000000),
    insetShadowLight: Color(0xD9FFFFFF),
    displayLarge: TextStyle(
      fontSize: 42,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: FadingColors.ink,
      height: 1.05,
    ),
    displayMedium: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: FadingColors.ink,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: FadingColors.ink,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: FadingColors.ink,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: FadingColors.ink,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: FadingColors.ink,
    ),
  );

  static FadingThemeData fromMode(FadingThemeMode mode) {
    return mode == FadingThemeMode.day ? day : night;
  }
}

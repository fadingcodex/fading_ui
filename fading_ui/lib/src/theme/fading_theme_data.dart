import 'package:flutter/widgets.dart';

import 'fading_colors.dart';

enum FadingThemeGroup {
  diaspora('Diaspora'),
  imperium('Imperium');

  const FadingThemeGroup(this.label);

  final String label;
}

enum FadingThemeName {
  dawn('Dawn', FadingThemeGroup.diaspora),
  abyss('Abyss', FadingThemeGroup.diaspora),
  hope('Hope', FadingThemeGroup.imperium),
  dream('Dream', FadingThemeGroup.imperium);

  const FadingThemeName(this.label, this.group);

  final String label;
  final FadingThemeGroup group;

  static List<FadingThemeName> forGroup(FadingThemeGroup group) {
    return values
        .where((FadingThemeName theme) => theme.group == group)
        .toList();
  }
}

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
    required this.controlActive,
    required this.controlInactive,
    required this.controlKnob,
    required this.progressTrack,
    required this.progressFill,
    required this.selectionActive,
    required this.selectionInactive,
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
  final Color controlActive;
  final Color controlInactive;
  final Color controlKnob;
  final Color progressTrack;
  final Color progressFill;
  final Color selectionActive;
  final Color selectionInactive;

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

  static const FadingThemeData abyss = FadingThemeData(
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
    controlActive: FadingColors.amberGlow,
    controlInactive: FadingColors.dust,
    controlKnob: FadingColors.starlight,
    progressTrack: FadingColors.dust,
    progressFill: FadingColors.roseHaze,
    selectionActive: FadingColors.amberGlow,
    selectionInactive: FadingColors.storm,
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

  static const FadingThemeData dawn = FadingThemeData(
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
    controlActive: FadingColors.amberGlow,
    controlInactive: FadingColors.sand,
    controlKnob: FadingColors.linen,
    progressTrack: FadingColors.sand,
    progressFill: FadingColors.ember,
    selectionActive: FadingColors.amberGlow,
    selectionInactive: FadingColors.mist,
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

  static const FadingThemeData hope = FadingThemeData(
    backgroundStart: FadingColors.imperialBlack,
    backgroundMiddle: FadingColors.imperialCharcoal,
    backgroundEnd: FadingColors.imperialBronze,
    surfaceRaised: FadingColors.imperialCharcoal,
    surfaceInset: FadingColors.imperialBlack,
    textPrimary: FadingColors.imperialSilver,
    textMuted: FadingColors.imperialSilver,
    border: FadingColors.imperialBorder,
    accent: FadingColors.imperialGold,
    accentStrong: FadingColors.imperialOchre,
    success: FadingColors.success,
    error: FadingColors.error,
    controlActive: FadingColors.imperialGold,
    controlInactive: FadingColors.imperialBronze,
    controlKnob: FadingColors.imperialSilver,
    progressTrack: FadingColors.imperialBronze,
    progressFill: FadingColors.imperialGold,
    selectionActive: FadingColors.imperialGold,
    selectionInactive: FadingColors.imperialBronze,
    shadowDark: Color(0x66000000),
    shadowLight: Color(0x14FFFFFF),
    insetShadowDark: Color(0x4D000000),
    insetShadowLight: Color(0x12FFFFFF),
    displayLarge: TextStyle(
      fontSize: 42,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: FadingColors.imperialSilver,
      height: 1.05,
    ),
    displayMedium: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: FadingColors.imperialSilver,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: FadingColors.imperialSilver,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: FadingColors.imperialSilver,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: FadingColors.imperialSilver,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: FadingColors.imperialSilver,
    ),
  );

  static const FadingThemeData dream = FadingThemeData(
    backgroundStart: FadingColors.dreamWhite,
    backgroundMiddle: FadingColors.dreamCream,
    backgroundEnd: FadingColors.dreamBeige,
    surfaceRaised: FadingColors.dreamCream,
    surfaceInset: FadingColors.dreamWhite,
    textPrimary: FadingColors.dreamCharcoal,
    textMuted: FadingColors.dreamSlate,
    border: FadingColors.dreamBorder,
    accent: FadingColors.dreamSteel,
    accentStrong: FadingColors.dreamSlate,
    success: FadingColors.success,
    error: FadingColors.error,
    controlActive: FadingColors.dreamSlate,
    controlInactive: FadingColors.dreamBeige,
    controlKnob: FadingColors.dreamWhite,
    progressTrack: FadingColors.dreamBeige,
    progressFill: FadingColors.dreamSlate,
    selectionActive: FadingColors.dreamSteel,
    selectionInactive: FadingColors.dreamBeige,
    shadowDark: Color(0x240C1017),
    shadowLight: Color(0xCCFFFFFF),
    insetShadowDark: Color(0x160C1017),
    insetShadowLight: Color(0xE6FFFFFF),
    displayLarge: TextStyle(
      fontSize: 42,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: FadingColors.dreamCharcoal,
      height: 1.05,
    ),
    displayMedium: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: FadingColors.dreamCharcoal,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: FadingColors.dreamCharcoal,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: FadingColors.dreamCharcoal,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: FadingColors.dreamCharcoal,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: FadingColors.dreamCharcoal,
    ),
  );

  static FadingThemeData fromTheme(FadingThemeName theme) {
    switch (theme) {
      case FadingThemeName.dawn:
        return dawn;
      case FadingThemeName.abyss:
        return abyss;
      case FadingThemeName.hope:
        return hope;
      case FadingThemeName.dream:
        return dream;
    }
  }
}

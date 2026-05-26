import 'package:flutter/painting.dart';

import 'fading_colors.dart';

final class FadingShadows {
  FadingShadows._();

  static List<BoxShadow> raised({double blur = 18, double offset = 8}) {
    return <BoxShadow>[
      BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.35),
        offset: Offset(offset, offset),
        blurRadius: blur,
      ),
      BoxShadow(
        color: const Color(0x40FFFFFF),
        offset: Offset(-offset * 0.7, -offset * 0.7),
        blurRadius: blur,
      ),
    ];
  }

  static List<BoxShadow> inset({double blur = 12, double offset = 5}) {
    return <BoxShadow>[
      BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.25),
        offset: Offset(offset * 0.8, offset * 0.8),
        blurRadius: blur,
        spreadRadius: -2,
      ),
      const BoxShadow(
        color: Color(0x33FFFFFF),
        offset: Offset(-2, -2),
        blurRadius: 5,
        spreadRadius: -2,
      ),
    ];
  }

  static Border side() {
    return Border.all(color: FadingColors.border.withValues(alpha: 0.65));
  }
}

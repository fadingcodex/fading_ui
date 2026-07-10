import 'package:flutter/widgets.dart';

import '../theme/fading_theme_data.dart';
import '../theme/fading_theme_scope.dart';

enum FadingBadgeTone { neutral, success, warning, critical }

class FadingBadge extends StatelessWidget {
  const FadingBadge({
    super.key,
    required this.label,
    this.tone = FadingBadgeTone.neutral,
  });

  final String label;
  final FadingBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = FadingThemeScope.of(context);
    final _BadgePalette palette = _paletteForTone(theme, tone);

    return Semantics(
      label: label,
      child: Container(
        constraints: const BoxConstraints(minHeight: 24, minWidth: 24),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: palette.border),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.labelLarge.copyWith(
            color: palette.foreground,
            fontSize: 12,
            letterSpacing: 0.35,
          ),
        ),
      ),
    );
  }

  _BadgePalette _paletteForTone(FadingThemeData theme, FadingBadgeTone tone) {
    switch (tone) {
      case FadingBadgeTone.neutral:
        return _BadgePalette(
          background: theme.surfaceRaised,
          foreground: theme.textPrimary,
          border: theme.border,
        );
      case FadingBadgeTone.success:
        return _BadgePalette(
          background: theme.success,
          foreground: theme.controlKnob,
          border: theme.success,
        );
      case FadingBadgeTone.warning:
        return _BadgePalette(
          background: theme.accent,
          foreground: theme.controlKnob,
          border: theme.accentStrong,
        );
      case FadingBadgeTone.critical:
        return _BadgePalette(
          background: theme.error,
          foreground: theme.controlKnob,
          border: theme.error,
        );
    }
  }
}

final class _BadgePalette {
  const _BadgePalette({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

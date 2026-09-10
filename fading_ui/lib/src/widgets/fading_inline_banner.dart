import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../theme/fading_theme_data.dart';
import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

enum FadingInlineBannerTone { neutral, success, warning, critical }

class FadingInlineBanner extends StatelessWidget {
  const FadingInlineBanner({
    super.key,
    required this.message,
    this.title,
    this.tone = FadingInlineBannerTone.neutral,
    this.leading,
    this.action,
    this.dismissible = false,
    this.onDismiss,
  });

  final String message;
  final String? title;
  final FadingInlineBannerTone tone;
  final Widget? leading;
  final Widget? action;
  final bool dismissible;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = FadingThemeScope.of(context);
    final palette = _paletteForTone(theme, tone);

    final Widget content = FadingSurface(
      style: FadingSurfaceStyle.raised,
      color: palette.background,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (leading != null) ...<Widget>[
            leading!,
            const SizedBox(width: 10),
          ] else ...<Widget>[
            _LeadingDot(color: palette.accent),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null) ...<Widget>[
                  Text(
                    title!,
                    style: theme.labelLarge.copyWith(color: palette.foreground),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: theme.bodyMedium.copyWith(color: palette.foreground),
                ),
              ],
            ),
          ),
          if (action != null) ...<Widget>[
            const SizedBox(width: 10),
            DefaultTextStyle(
              style: theme.labelLarge.copyWith(color: palette.foreground),
              child: action!,
            ),
          ],
          if (dismissible) ...<Widget>[
            const SizedBox(width: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(Icons.close, size: 16, color: palette.foreground),
              ),
            ),
          ],
        ],
      ),
    );

    return content;
  }

  _BannerPalette _paletteForTone(
    FadingThemeData theme,
    FadingInlineBannerTone tone,
  ) {
    switch (tone) {
      case FadingInlineBannerTone.neutral:
        return _BannerPalette(
          background: theme.surfaceInset,
          foreground: theme.textPrimary,
          accent: theme.border,
        );
      case FadingInlineBannerTone.success:
        return _BannerPalette(
          background: theme.success.withOpacity(0.18),
          foreground: theme.textPrimary,
          accent: theme.success,
        );
      case FadingInlineBannerTone.warning:
        return _BannerPalette(
          background: theme.accent.withOpacity(0.18),
          foreground: theme.textPrimary,
          accent: theme.accent,
        );
      case FadingInlineBannerTone.critical:
        return _BannerPalette(
          background: theme.error.withOpacity(0.18),
          foreground: theme.textPrimary,
          accent: theme.error,
        );
    }
  }
}

class _LeadingDot extends StatelessWidget {
  const _LeadingDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _BannerPalette {
  const _BannerPalette({
    required this.background,
    required this.foreground,
    required this.accent,
  });

  final Color background;
  final Color foreground;
  final Color accent;
}

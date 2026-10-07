import 'package:flutter/material.dart';

import '../theme/fading_theme_data.dart';
import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

enum FadingEmptyStateTone { neutral, success, warning, critical }

class FadingEmptyState extends StatelessWidget {
  const FadingEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.illustration,
    this.tone = FadingEmptyStateTone.neutral,
    this.primaryAction,
    this.secondaryAction,
    this.compact = false,
    this.padding,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final Widget? illustration;
  final FadingEmptyStateTone tone;
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final bool compact;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);
    final _EmptyStatePalette palette = _paletteForTone(theme, tone);
    final double glyphSize = compact ? 40 : 56;
    final double iconSize = compact ? 22 : 30;

    return FadingSurface(
      style: FadingSurfaceStyle.inset,
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: compact ? 16 : 24,
            vertical: compact ? 20 : 32,
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: glyphSize,
            height: glyphSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.background,
              shape: BoxShape.circle,
              border: Border.all(color: palette.accent),
            ),
            child:
                illustration ??
                Icon(
                  icon ?? _defaultIconForTone(tone),
                  size: iconSize,
                  color: palette.accent,
                ),
          ),
          SizedBox(height: compact ? 12 : 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.titleLarge.copyWith(color: palette.accent),
          ),
          if (message != null) ...<Widget>[
            SizedBox(height: compact ? 6 : 8),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.bodyMedium.copyWith(color: theme.textMuted),
            ),
          ],
          if (primaryAction != null || secondaryAction != null) ...<Widget>[
            SizedBox(height: compact ? 14 : 20),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[?primaryAction, ?secondaryAction],
            ),
          ],
        ],
      ),
    );
  }

  IconData _defaultIconForTone(FadingEmptyStateTone tone) {
    switch (tone) {
      case FadingEmptyStateTone.neutral:
        return Icons.inbox_outlined;
      case FadingEmptyStateTone.success:
        return Icons.check_circle_outline;
      case FadingEmptyStateTone.warning:
        return Icons.error_outline;
      case FadingEmptyStateTone.critical:
        return Icons.report_gmailerrorred_outlined;
    }
  }

  _EmptyStatePalette _paletteForTone(
    FadingThemeData theme,
    FadingEmptyStateTone tone,
  ) {
    switch (tone) {
      case FadingEmptyStateTone.neutral:
        return _EmptyStatePalette(
          background: theme.surfaceInset,
          accent: theme.border,
        );
      case FadingEmptyStateTone.success:
        return _EmptyStatePalette(
          background: theme.success.withValues(alpha: 0.18),
          accent: theme.success,
        );
      case FadingEmptyStateTone.warning:
        return _EmptyStatePalette(
          background: theme.accent.withValues(alpha: 0.18),
          accent: theme.accent,
        );
      case FadingEmptyStateTone.critical:
        return _EmptyStatePalette(
          background: theme.error.withValues(alpha: 0.18),
          accent: theme.error,
        );
    }
  }
}

class _EmptyStatePalette {
  const _EmptyStatePalette({required this.background, required this.accent});

  final Color background;
  final Color accent;
}

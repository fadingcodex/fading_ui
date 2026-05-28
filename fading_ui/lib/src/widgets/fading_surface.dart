import 'package:flutter/widgets.dart';

import '../theme/fading_shadows.dart';
import '../theme/fading_theme_scope.dart';

enum FadingSurfaceStyle { raised, inset }

class FadingSurface extends StatelessWidget {
  const FadingSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.color,
    this.style = FadingSurfaceStyle.raised,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? color;
  final FadingSurfaceStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = FadingThemeScope.of(context);
    final bool isInset = style == FadingSurfaceStyle.inset;
    final Color resolvedColor =
        color ?? (isInset ? theme.surfaceInset : theme.surfaceRaised);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedColor,
        borderRadius: borderRadius,
        border: FadingShadows.side(theme: theme),
        boxShadow: isInset
            ? FadingShadows.inset(theme: theme)
            : FadingShadows.raised(theme: theme),
      ),
      child: child,
    );
  }
}

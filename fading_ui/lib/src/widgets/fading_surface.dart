import 'package:flutter/widgets.dart';

import '../theme/fading_colors.dart';
import '../theme/fading_shadows.dart';

enum FadingSurfaceStyle { raised, inset }

class FadingSurface extends StatelessWidget {
  const FadingSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.color = FadingColors.dusk,
    this.style = FadingSurfaceStyle.raised,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color color;
  final FadingSurfaceStyle style;

  @override
  Widget build(BuildContext context) {
    final bool isInset = style == FadingSurfaceStyle.inset;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: FadingShadows.side(),
        boxShadow: isInset ? FadingShadows.inset() : FadingShadows.raised(),
      ),
      child: child,
    );
  }
}

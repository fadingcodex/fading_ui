import 'package:flutter/widgets.dart';

import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

class FadingCard extends StatelessWidget {
  const FadingCard({
    super.key,
    this.title,
    required this.child,
    this.accentColor,
  });

  final String? title;
  final Widget child;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = FadingThemeScope.of(context);
    final Color resolvedAccent = accentColor ?? theme.accentStrong;

    return FadingSurface(
      style: FadingSurfaceStyle.raised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: resolvedAccent,
                  ),
                ),
                const SizedBox(width: 8),
                Text(title!, style: theme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

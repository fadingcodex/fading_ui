import 'package:flutter/widgets.dart';

import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

class FadingButton extends StatefulWidget {
  const FadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool enabled;

  @override
  State<FadingButton> createState() => _FadingButtonState();
}

class _FadingButtonState extends State<FadingButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = FadingThemeScope.of(context);
    final bool isEnabled = widget.enabled && widget.onPressed != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.5,
        child: FadingSurface(
          style: _isPressed
              ? FadingSurfaceStyle.inset
              : FadingSurfaceStyle.raised,
          color: _isPressed ? theme.surfaceInset : theme.surfaceRaised,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.leading != null) ...<Widget>[
                widget.leading!,
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

class FadingSwitch extends StatefulWidget {
  const FadingSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;

  @override
  State<FadingSwitch> createState() => _FadingSwitchState();
}

class _FadingSwitchState extends State<FadingSwitch> {
  bool _isPressed = false;

  bool get _isEnabled => widget.enabled && widget.onChanged != null;

  void _toggle() {
    if (!_isEnabled) {
      return;
    }
    widget.onChanged?.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FadingThemeScope.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: _isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              _toggle();
            }
          : null,
      onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
      child: Opacity(
        opacity: _isEnabled ? 1 : 0.5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.label != null) ...<Widget>[
              Text(widget.label!, style: theme.bodyMedium),
              const SizedBox(width: 10),
            ],
            FadingSurface(
              style: _isPressed
                  ? FadingSurfaceStyle.inset
                  : FadingSurfaceStyle.raised,
              color: widget.value ? theme.controlActive : theme.controlInactive,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              child: SizedBox(
                width: 54,
                height: 26,
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  alignment: widget.value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.controlKnob,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

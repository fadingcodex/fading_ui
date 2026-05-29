import 'package:flutter/widgets.dart';

import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

class FadingCheckbox extends StatefulWidget {
  const FadingCheckbox({
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
  State<FadingCheckbox> createState() => _FadingCheckboxState();
}

class _FadingCheckboxState extends State<FadingCheckbox> {
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
            FadingSurface(
              style: _isPressed
                  ? FadingSurfaceStyle.inset
                  : FadingSurfaceStyle.raised,
              color: widget.value ? theme.controlActive : theme.controlInactive,
              padding: const EdgeInsets.all(0),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: SizedBox(
                width: 24,
                height: 24,
                child: widget.value
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: theme.controlKnob,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            if (widget.label != null) ...<Widget>[
              const SizedBox(width: 10),
              Text(widget.label!, style: theme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

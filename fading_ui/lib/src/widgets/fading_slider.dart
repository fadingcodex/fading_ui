import 'package:flutter/widgets.dart';

import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

class FadingSlider extends StatelessWidget {
  const FadingSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.enabled = true,
    this.label,
  }) : assert(max > min, 'max must be greater than min');

  final double value;
  final double min;
  final double max;
  final bool enabled;
  final String? label;
  final ValueChanged<double>? onChanged;

  bool get _isEnabled => enabled && onChanged != null;

  double _clamp(double input) {
    if (input < min) {
      return min;
    }
    if (input > max) {
      return max;
    }
    return input;
  }

  double _normalized(double input) {
    return ((_clamp(input) - min) / (max - min)).clamp(0.0, 1.0);
  }

  void _emitFromLocalDx(BuildContext context, double localDx, double width) {
    if (!_isEnabled) {
      return;
    }
    final double clampedDx = localDx.clamp(0.0, width);
    final double ratio = width == 0 ? 0 : clampedDx / width;
    final double nextValue = min + (max - min) * ratio;
    onChanged?.call(_clamp(nextValue));
  }

  @override
  Widget build(BuildContext context) {
    final theme = FadingThemeScope.of(context);
    const double thumbSize = 18;
    final double progress = _normalized(value);

    return Opacity(
      opacity: _isEnabled ? 1 : 0.5,
      child: FadingSurface(
        style: FadingSurfaceStyle.inset,
        color: theme.surfaceInset,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (label != null) ...<Widget>[
              Text(label!, style: theme.labelLarge),
              const SizedBox(height: 8),
            ],
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double width = constraints.maxWidth;
                final double thumbCenterX = progress * width;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: _isEnabled
                      ? (TapDownDetails details) {
                          _emitFromLocalDx(
                            context,
                            details.localPosition.dx,
                            width,
                          );
                        }
                      : null,
                  onHorizontalDragStart: _isEnabled
                      ? (DragStartDetails details) {
                          _emitFromLocalDx(
                            context,
                            details.localPosition.dx,
                            width,
                          );
                        }
                      : null,
                  onHorizontalDragUpdate: _isEnabled
                      ? (DragUpdateDetails details) {
                          _emitFromLocalDx(
                            context,
                            details.localPosition.dx,
                            width,
                          );
                        }
                      : null,
                  child: SizedBox(
                    height: 28,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.progressTrack,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Container(
                          width: width * progress,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.progressFill,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Positioned(
                          left: (thumbCenterX - thumbSize / 2).clamp(
                            0.0,
                            width - thumbSize,
                          ),
                          child: Container(
                            width: thumbSize,
                            height: thumbSize,
                            decoration: BoxDecoration(
                              color: theme.controlKnob,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.border.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

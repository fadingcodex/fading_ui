import 'package:flutter/widgets.dart';

import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

typedef RangeValues = ({double start, double end});

class FadingRangeSlider extends StatelessWidget {
  const FadingRangeSlider({
    super.key,
    required this.startValue,
    required this.endValue,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.enabled = true,
    this.label,
  }) : assert(max > min, 'max must be greater than min'),
       assert(
         startValue >= min && startValue <= max,
         'startValue must be between min and max',
       ),
       assert(
         endValue >= min && endValue <= max,
         'endValue must be between min and max',
       ),
       assert(startValue <= endValue, 'startValue must not exceed endValue');

  final double startValue;
  final double endValue;
  final double min;
  final double max;
  final bool enabled;
  final String? label;
  final ValueChanged<RangeValues>? onChanged;

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

  void _emitFromLocalDx(
    BuildContext context,
    double localDx,
    double width,
    bool isStartThumb,
  ) {
    if (!_isEnabled) {
      return;
    }
    final double clampedDx = localDx.clamp(0.0, width);
    final double ratio = width == 0 ? 0 : clampedDx / width;
    final double nextValue = min + (max - min) * ratio;
    final double clampedValue = _clamp(nextValue);

    if (isStartThumb) {
      // Ensure start doesn't exceed end
      final double newStart = clampedValue.clamp(min, endValue);
      onChanged?.call((start: newStart, end: endValue));
    } else {
      // Ensure end doesn't go below start
      final double newEnd = clampedValue.clamp(startValue, max);
      onChanged?.call((start: startValue, end: newEnd));
    }
  }

  /// Determines which thumb is closer to the tap/drag position.
  /// Returns true for start thumb, false for end thumb.
  bool _getCloserThumb(double localDx, double width) {
    final double startX = _normalized(startValue) * width;
    final double endX = _normalized(endValue) * width;
    final double distToStart = (localDx - startX).abs();
    final double distToEnd = (localDx - endX).abs();
    return distToStart <= distToEnd;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FadingThemeScope.of(context);
    const double thumbSize = 18;
    final double startProgress = _normalized(startValue);
    final double endProgress = _normalized(endValue);

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
                final double startThumbCenterX = startProgress * width;
                final double endThumbCenterX = endProgress * width;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: _isEnabled
                      ? (TapDownDetails details) {
                          final bool isStartThumb = _getCloserThumb(
                            details.localPosition.dx,
                            width,
                          );
                          _emitFromLocalDx(
                            context,
                            details.localPosition.dx,
                            width,
                            isStartThumb,
                          );
                        }
                      : null,
                  onHorizontalDragStart: _isEnabled
                      ? (DragStartDetails details) {
                          final bool isStartThumb = _getCloserThumb(
                            details.localPosition.dx,
                            width,
                          );
                          _emitFromLocalDx(
                            context,
                            details.localPosition.dx,
                            width,
                            isStartThumb,
                          );
                        }
                      : null,
                  onHorizontalDragUpdate: _isEnabled
                      ? (DragUpdateDetails details) {
                          // Determine which thumb to drag based on initial position
                          final bool isStartThumb = _getCloserThumb(
                            details.localPosition.dx,
                            width,
                          );
                          _emitFromLocalDx(
                            context,
                            details.localPosition.dx,
                            width,
                            isStartThumb,
                          );
                        }
                      : null,
                  child: SizedBox(
                    height: 28,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        // Background track
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.progressTrack,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        // Filled region (between start and end)
                        Positioned(
                          left: startThumbCenterX,
                          right: width - endThumbCenterX,
                          height: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.progressFill,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        // Start thumb
                        Positioned(
                          left: (startThumbCenterX - thumbSize / 2).clamp(
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
                        // End thumb
                        Positioned(
                          left: (endThumbCenterX - thumbSize / 2).clamp(
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

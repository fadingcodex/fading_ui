import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

enum FadingProgressVariant { linear, circular }

class FadingProgressIndicator extends StatelessWidget {
  const FadingProgressIndicator({
    super.key,
    required this.value,
    this.variant = FadingProgressVariant.linear,
    this.label,
    this.size = 72,
  });

  final double value;
  final FadingProgressVariant variant;
  final String? label;
  final double size;

  double get _progress => value.clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = FadingThemeScope.of(context);

    return FadingSurface(
      style: FadingSurfaceStyle.inset,
      color: theme.surfaceInset,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (label != null) ...<Widget>[
            Text(label!, style: theme.labelLarge),
            const SizedBox(height: 10),
          ],
          if (variant == FadingProgressVariant.linear)
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.progressTrack,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.progressFill,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _FadingCircularProgressPainter(
                  progress: _progress,
                  trackColor: theme.progressTrack,
                  fillColor: theme.progressFill,
                ),
                child: Center(
                  child: Text(
                    '${(_progress * 100).round()}%',
                    style: theme.bodyMedium,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FadingCircularProgressPainter extends CustomPainter {
  _FadingCircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  final double progress;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = math.min(size.width, size.height) / 2 - 4;

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, trackPaint);

    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FadingCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.fillColor != fillColor;
  }
}

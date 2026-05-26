import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/fading_colors.dart';
import '../theme/fading_theme.dart';
import 'fading_surface.dart';

final class FadingToast {
  FadingToast._();

  static OverlayEntry show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return _FadingToastHost(
          message: message,
          duration: duration,
          onDismissed: () {
            if (entry.mounted) {
              entry.remove();
            }
          },
        );
      },
    );

    overlay.insert(entry);
    return entry;
  }
}

class _FadingToastHost extends StatefulWidget {
  const _FadingToastHost({
    required this.message,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_FadingToastHost> createState() => _FadingToastHostState();
}

class _FadingToastHostState extends State<_FadingToastHost>
    with SingleTickerProviderStateMixin {
  static const Duration _fadeDuration = Duration(milliseconds: 180);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _fadeDuration,
    reverseDuration: _fadeDuration,
  );

  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _dismissTimer = Timer(widget.duration, _startDismiss);
  }

  Future<void> _startDismiss() async {
    if (!mounted) {
      return;
    }

    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _controller,
              curve: Curves.easeOutCubic,
            ),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.18),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: FadingSurface(
                style: FadingSurfaceStyle.raised,
                color: FadingColors.dusk,
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: DefaultTextStyle(
                  style: FadingTheme.bodyMedium.copyWith(
                    color: FadingColors.starlight,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: FadingColors.amberGlow,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(child: Text(widget.message)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

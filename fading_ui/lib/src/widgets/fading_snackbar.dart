import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/fading_theme_data.dart';
import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

final class FadingSnackbarAction {
  const FadingSnackbarAction({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;
}

final class FadingSnackbar {
  FadingSnackbar._();

  static OverlayEntry show(
    BuildContext context, {
    required String message,
    FadingSnackbarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    final FadingThemeData theme = FadingThemeScope.of(context);
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return _FadingSnackbarHost(
          message: message,
          action: action,
          duration: duration,
          theme: theme,
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

class _FadingSnackbarHost extends StatefulWidget {
  const _FadingSnackbarHost({
    required this.message,
    required this.action,
    required this.duration,
    required this.theme,
    required this.onDismissed,
  });

  final String message;
  final FadingSnackbarAction? action;
  final Duration duration;
  final FadingThemeData theme;
  final VoidCallback onDismissed;

  @override
  State<_FadingSnackbarHost> createState() => _FadingSnackbarHostState();
}

class _FadingSnackbarHostState extends State<_FadingSnackbarHost>
    with SingleTickerProviderStateMixin {
  static const Duration _fadeDuration = Duration(milliseconds: 180);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _fadeDuration,
    reverseDuration: _fadeDuration,
  );

  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _dismissTimer = Timer(widget.duration, _startDismiss);
  }

  Future<void> _startDismiss() async {
    if (!mounted || _isDismissing) {
      return;
    }

    _isDismissing = true;
    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  void _handleActionPressed() {
    widget.action?.onPressed?.call();
    _startDismiss();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: FadingSurface(
                style: FadingSurfaceStyle.raised,
                color: widget.theme.surfaceRaised,
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.message,
                        style: widget.theme.bodyMedium.copyWith(
                          color: widget.theme.textPrimary,
                        ),
                      ),
                    ),
                    if (widget.action != null) ...<Widget>[
                      const SizedBox(width: 12),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _handleActionPressed,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Text(
                            widget.action!.label,
                            style: widget.theme.labelLarge.copyWith(
                              color: widget.theme.accent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
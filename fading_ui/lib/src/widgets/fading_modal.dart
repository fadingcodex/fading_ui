import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/fading_theme_data.dart';
import '../theme/fading_theme_scope.dart';
import 'fading_button.dart';
import 'fading_surface.dart';

final class FadingModalAction {
  const FadingModalAction({
    required this.label,
    this.onPressed,
    this.leading,
    this.dismisses = true,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool dismisses;
  final bool enabled;
}

class FadingModal extends StatelessWidget {
  const FadingModal({
    super.key,
    required this.title,
    required this.body,
    this.actions = const <FadingModalAction>[],
    this.onDismiss,
    this.maxWidth = 420,
  }) : assert(maxWidth > 0, 'maxWidth must be greater than zero');

  final String title;
  final Widget body;
  final List<FadingModalAction> actions;
  final VoidCallback? onDismiss;
  final double maxWidth;

  static OverlayEntry show(
    BuildContext context, {
    required String title,
    required Widget body,
    List<FadingModalAction> actions = const <FadingModalAction>[],
    bool isDismissible = true,
    double maxWidth = 420,
  }) {
    final FadingThemeData theme = FadingThemeScope.of(context);
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return _FadingModalHost(
          theme: theme,
          isDismissible: isDismissible,
          maxWidth: maxWidth,
          onDismissed: () {
            if (entry.mounted) {
              entry.remove();
            }
          },
          childBuilder: (VoidCallback dismiss) {
            return FadingModal(
              title: title,
              body: body,
              actions: actions,
              onDismiss: dismiss,
              maxWidth: maxWidth,
            );
          },
        );
      },
    );

    overlay.insert(entry);
    return entry;
  }

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);

    return FadingSurface(
      style: FadingSurfaceStyle.raised,
      color: theme.surfaceRaised,
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: theme.titleLarge.copyWith(color: theme.textPrimary),
            ),
            const SizedBox(height: 10),
            DefaultTextStyle(
              style: theme.bodyLarge.copyWith(color: theme.textMuted),
              child: body,
            ),
            if (actions.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  for (final FadingModalAction action in actions)
                    FadingButton(
                      label: action.label,
                      leading: action.leading,
                      enabled: action.enabled,
                      onPressed: action.enabled
                          ? () {
                              action.onPressed?.call();
                              if (action.dismisses) {
                                onDismiss?.call();
                              }
                            }
                          : null,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FadingModalHost extends StatefulWidget {
  const _FadingModalHost({
    required this.theme,
    required this.childBuilder,
    required this.onDismissed,
    required this.isDismissible,
    required this.maxWidth,
  });

  final FadingThemeData theme;
  final Widget Function(VoidCallback dismiss) childBuilder;
  final VoidCallback onDismissed;
  final bool isDismissible;
  final double maxWidth;

  @override
  State<_FadingModalHost> createState() => _FadingModalHostState();
}

class _FadingModalHostState extends State<_FadingModalHost>
    with SingleTickerProviderStateMixin {
  static const Duration _fadeDuration = Duration(milliseconds: 180);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _fadeDuration,
    reverseDuration: _fadeDuration,
  );

  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  Future<void> _dismiss() async {
    if (_isDismissing) {
      return;
    }

    _isDismissing = true;
    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (!widget.isDismissible || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _dismiss();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return Positioned.fill(
      child: FadeTransition(
        opacity: animation,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              key: const ValueKey<String>('fading-modal-backdrop'),
              behavior: HitTestBehavior.opaque,
              onTap: widget.isDismissible ? _dismiss : () {},
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.theme.shadowDark.withValues(alpha: 0.78),
                ),
                child: const SizedBox.expand(),
              ),
            ),
            SafeArea(
              minimum: const EdgeInsets.all(20),
              child: Center(
                child: Focus(
                  autofocus: true,
                  onKeyEvent: _handleKey,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.96,
                      end: 1,
                    ).animate(animation),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: widget.maxWidth,
                        maxHeight: mediaQuery.size.height - 40,
                      ),
                      child: SingleChildScrollView(
                        child: widget.childBuilder(_dismiss),
                      ),
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

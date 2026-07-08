import 'package:flutter/widgets.dart';

import '../theme/fading_theme_data.dart';
import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

class FadingBreadcrumbs extends StatelessWidget {
  const FadingBreadcrumbs({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.label,
    this.enabled = true,
  }) : assert(items.length > 0, 'items must not be empty'),
       assert(
         currentIndex >= 0 && currentIndex < items.length,
         'currentIndex must be within items range',
       );

  final List<String> items;
  final int currentIndex;
  final ValueChanged<int>? onChanged;
  final String? label;
  final bool enabled;

  bool get _isEnabled => enabled && onChanged != null;

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);

    return Opacity(
      opacity: _isEnabled ? 1 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (label != null) ...<Widget>[
            Text(
              label!,
              style: theme.bodyMedium.copyWith(color: theme.textMuted),
            ),
            const SizedBox(height: 8),
          ],
          FadingSurface(
            style: FadingSurfaceStyle.inset,
            color: theme.surfaceInset,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            child: Wrap(
              spacing: 2,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                for (var index = 0; index < items.length; index++) ...<Widget>[
                  if (index > 0) _buildSeparator(theme, index),
                  _buildItem(theme, index),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator(FadingThemeData theme, int index) {
    return Text(
      '/',
      key: ValueKey<String>('fading-breadcrumbs-separator-$index'),
      style: theme.bodyMedium.copyWith(
        color: theme.textMuted,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildItem(FadingThemeData theme, int index) {
    final bool selected = index == currentIndex;
    final VoidCallback? onTap = _isEnabled && !selected
        ? () => _emitIndex(index)
        : null;

    return GestureDetector(
      key: ValueKey<String>('fading-breadcrumbs-item-$index'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.selectionActive : const Color(0x00000000),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          items[index],
          style: theme.bodyMedium.copyWith(
            color: selected ? theme.controlKnob : theme.textPrimary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _emitIndex(int index) {
    if (!_isEnabled || index == currentIndex) {
      return;
    }
    if (index < 0 || index >= items.length) {
      return;
    }
    onChanged?.call(index);
  }
}

import 'package:flutter/widgets.dart';

import '../theme/fading_theme_data.dart';
import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

class FadingBreadcrumbItem {
  const FadingBreadcrumbItem({
    required this.label,
    this.leading,
    this.enabled = true,
  });

  final String label;
  final Widget? leading;
  final bool enabled;
}

typedef FadingBreadcrumbSeparatorBuilder =
    Widget Function(BuildContext context, int index, FadingThemeData theme);

class FadingBreadcrumbs extends StatelessWidget {
  const FadingBreadcrumbs({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.label,
    this.enabled = true,
    this.separatorBuilder,
  }) : assert(items.length > 0, 'items must not be empty'),
       assert(
         currentIndex >= 0 && currentIndex < items.length,
         'currentIndex must be within items range',
       );

  final List<Object> items;
  final int currentIndex;
  final ValueChanged<int>? onChanged;
  final String? label;
  final bool enabled;
  final FadingBreadcrumbSeparatorBuilder? separatorBuilder;

  bool get _isEnabled => enabled && onChanged != null;

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);
    final List<FadingBreadcrumbItem> normalizedItems = _normalizedItems();

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
                for (
                  var index = 0;
                  index < normalizedItems.length;
                  index++
                ) ...<Widget>[
                  if (index > 0) _buildSeparator(context, theme, index),
                  _buildItem(theme, normalizedItems[index], index),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<FadingBreadcrumbItem> _normalizedItems() {
    return items.map((Object item) {
      if (item is FadingBreadcrumbItem) {
        return item;
      }
      if (item is! String) {
        throw ArgumentError(
          'items must contain only String or FadingBreadcrumbItem values',
        );
      }
      return FadingBreadcrumbItem(label: item);
    }).toList();
  }

  Widget _buildSeparator(
    BuildContext context,
    FadingThemeData theme,
    int index,
  ) {
    if (separatorBuilder != null) {
      return KeyedSubtree(
        key: ValueKey<String>('fading-breadcrumbs-separator-$index'),
        child: separatorBuilder!(context, index, theme),
      );
    }

    return Text(
      '/',
      key: ValueKey<String>('fading-breadcrumbs-separator-$index'),
      style: theme.bodyMedium.copyWith(
        color: theme.textMuted,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildItem(
    FadingThemeData theme,
    FadingBreadcrumbItem item,
    int index,
  ) {
    final bool selected = index == currentIndex;
    final bool itemEnabled = item.enabled;
    final bool interactive = _isEnabled && itemEnabled && !selected;
    final VoidCallback? onTap = interactive ? () => _emitIndex(index) : null;

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (item.leading != null) ...<Widget>[
              item.leading!,
              const SizedBox(width: 8),
            ],
            Text(
              item.label,
              style: theme.bodyMedium.copyWith(
                color: itemEnabled
                    ? (selected ? theme.controlKnob : theme.textPrimary)
                    : theme.textMuted,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _emitIndex(int index) {
    if (!_isEnabled || index == currentIndex) {
      return;
    }
    final List<FadingBreadcrumbItem> normalizedItems = _normalizedItems();
    if (index < 0 || index >= normalizedItems.length) {
      return;
    }
    if (!normalizedItems[index].enabled) {
      return;
    }
    onChanged?.call(index);
  }
}

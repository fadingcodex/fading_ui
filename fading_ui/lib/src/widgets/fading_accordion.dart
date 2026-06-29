import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/fading_theme_data.dart';
import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

class FadingAccordionItem {
  const FadingAccordionItem({
    required this.title,
    required this.content,
    this.subtitle,
    this.trailing,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final Widget content;
  final Widget? trailing;
  final bool enabled;
}

String _headerKeyForIndex(int index) => 'fading-accordion-header-$index';
String _contentKeyForIndex(int index) => 'fading-accordion-content-$index';
String _indicatorKeyForIndex(int index) => 'fading-accordion-indicator-$index';

class FadingAccordion extends StatelessWidget {
  const FadingAccordion({
    super.key,
    required this.items,
    required this.expandedIndex,
    required this.onChanged,
    this.label,
    this.enabled = true,
  }) : assert(items.length > 0, 'items must not be empty');

  final List<FadingAccordionItem> items;
  final int? expandedIndex;
  final ValueChanged<int?>? onChanged;
  final String? label;
  final bool enabled;

  bool get _isEnabled => enabled && onChanged != null;

  void _toggleItem(int index) {
    final int? nextIndex = expandedIndex == index ? null : index;
    onChanged?.call(nextIndex);
  }

  KeyEventResult _handleItemKey(KeyEvent event, int index, bool itemEnabled) {
    if (!itemEnabled || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      _toggleItem(index);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape &&
        expandedIndex == index) {
      onChanged?.call(null);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);

    return Opacity(
      opacity: _isEnabled ? 1 : 0.5,
      child: FadingSurface(
        style: FadingSurfaceStyle.inset,
        color: theme.surfaceInset,
        padding: const EdgeInsets.all(8),
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (label != null) ...<Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 6),
                child: Text(label!, style: theme.labelLarge),
              ),
            ],
            for (var index = 0; index < items.length; index++) ...<Widget>[
              _AccordionRow(
                key: ValueKey<String>('fading-accordion-row-$index'),
                item: items[index],
                theme: theme,
                expanded: expandedIndex == index,
                enabled: _isEnabled && items[index].enabled,
                headerKey: ValueKey<String>(_headerKeyForIndex(index)),
                contentKey: ValueKey<String>(_contentKeyForIndex(index)),
                indicatorKey: ValueKey<String>(_indicatorKeyForIndex(index)),
                onTap: () => _toggleItem(index),
                onKeyEvent: (KeyEvent event) {
                  return _handleItemKey(
                    event,
                    index,
                    _isEnabled && items[index].enabled,
                  );
                },
              ),
              if (index != items.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccordionRow extends StatelessWidget {
  const _AccordionRow({
    super.key,
    required this.item,
    required this.theme,
    required this.expanded,
    required this.enabled,
    required this.headerKey,
    required this.contentKey,
    required this.indicatorKey,
    required this.onTap,
    required this.onKeyEvent,
  });

  final FadingAccordionItem item;
  final FadingThemeData theme;
  final bool expanded;
  final bool enabled;
  final Key headerKey;
  final Key contentKey;
  final Key indicatorKey;
  final VoidCallback onTap;
  final KeyEventResult Function(KeyEvent event) onKeyEvent;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: item.enabled ? 1 : 0.55,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: expanded
              ? theme.selectionActive.withValues(alpha: 0.18)
              : const Color(0x00000000),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Focus(
          onKeyEvent: (_, KeyEvent event) => onKeyEvent(event),
          child: GestureDetector(
            key: headerKey,
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.title,
                              style: theme.titleLarge.copyWith(fontSize: 16),
                            ),
                            if (item.subtitle != null) ...<Widget>[
                              const SizedBox(height: 4),
                              Text(
                                item.subtitle!,
                                style: theme.bodyMedium.copyWith(
                                  color: theme.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (item.trailing != null) ...<Widget>[
                        item.trailing!,
                        const SizedBox(width: 10),
                      ],
                      AnimatedRotation(
                        key: indicatorKey,
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOutCubic,
                        child: Text(
                          'v',
                          style: theme.labelLarge.copyWith(
                            color: expanded
                                ? theme.accentStrong
                                : theme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: expanded
                        ? Padding(
                            key: contentKey,
                            padding: const EdgeInsets.only(top: 10),
                            child: item.content,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

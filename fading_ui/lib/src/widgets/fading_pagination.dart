import 'package:flutter/widgets.dart';

import '../theme/fading_theme_data.dart';
import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

class FadingPagination extends StatelessWidget {
  const FadingPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.label,
    this.enabled = true,
    this.siblingCount = 1,
  }) : assert(totalPages > 0, 'totalPages must be greater than zero'),
       assert(currentPage > 0, 'currentPage must be greater than zero'),
       assert(
         currentPage <= totalPages,
         'currentPage must be less than or equal to totalPages',
       ),
       assert(siblingCount >= 0, 'siblingCount must be zero or greater');

  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;
  final String? label;
  final bool enabled;
  final int siblingCount;

  bool get _isEnabled => enabled && onPageChanged != null;

  @override
  Widget build(BuildContext context) {
    final theme = FadingThemeScope.of(context);
    final List<_PaginationItem> items = _buildItems();

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              _buildControlButton(
                context,
                key: const ValueKey<String>('fading-pagination-first'),
                text: '<<',
                onTap: _isEnabled && currentPage > 1
                    ? () => _emitPage(1)
                    : null,
              ),
              _buildControlButton(
                context,
                key: const ValueKey<String>('fading-pagination-prev'),
                text: '<',
                onTap: _isEnabled && currentPage > 1
                    ? () => _emitPage(currentPage - 1)
                    : null,
              ),
              for (var index = 0; index < items.length; index++)
                switch (items[index]) {
                  _PageItem(:final page) => _buildPageButton(context, page),
                  _EllipsisItem() => _buildEllipsis(index, theme),
                },
              _buildControlButton(
                context,
                key: const ValueKey<String>('fading-pagination-next'),
                text: '>',
                onTap: _isEnabled && currentPage < totalPages
                    ? () => _emitPage(currentPage + 1)
                    : null,
              ),
              _buildControlButton(
                context,
                key: const ValueKey<String>('fading-pagination-last'),
                text: '>>',
                onTap: _isEnabled && currentPage < totalPages
                    ? () => _emitPage(totalPages)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required Key key,
    required String text,
    required VoidCallback? onTap,
  }) {
    final theme = FadingThemeScope.of(context);

    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: FadingSurface(
        style: onTap == null
            ? FadingSurfaceStyle.inset
            : FadingSurfaceStyle.raised,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Text(
          text,
          style: theme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: onTap == null ? theme.textMuted : theme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildPageButton(BuildContext context, int page) {
    final theme = FadingThemeScope.of(context);
    final bool selected = page == currentPage;
    final VoidCallback? onTap = _isEnabled && !selected
        ? () => _emitPage(page)
        : null;

    return GestureDetector(
      key: ValueKey<String>('fading-pagination-page-$page'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.selectionActive : theme.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$page',
          style: theme.bodyMedium.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? theme.controlKnob : theme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis(int index, FadingThemeData theme) {
    return Text(
      '...',
      key: ValueKey<String>('fading-pagination-ellipsis-$index'),
      style: theme.bodyMedium.copyWith(color: theme.textMuted),
    );
  }

  void _emitPage(int nextPage) {
    if (!_isEnabled || nextPage == currentPage) {
      return;
    }
    if (nextPage < 1 || nextPage > totalPages) {
      return;
    }
    onPageChanged?.call(nextPage);
  }

  List<_PaginationItem> _buildItems() {
    if (totalPages <= 7) {
      return <_PaginationItem>[
        for (var page = 1; page <= totalPages; page++) _PageItem(page),
      ];
    }

    final Set<int> pages = <int>{1, totalPages};
    for (
      var page = currentPage - siblingCount;
      page <= currentPage + siblingCount;
      page++
    ) {
      if (page > 1 && page < totalPages) {
        pages.add(page);
      }
    }

    final List<int> sortedPages = pages.toList()..sort();

    final List<_PaginationItem> items = <_PaginationItem>[];
    for (var index = 0; index < sortedPages.length; index++) {
      final int page = sortedPages[index];
      if (index > 0 && page - sortedPages[index - 1] > 1) {
        items.add(const _EllipsisItem());
      }
      items.add(_PageItem(page));
    }

    return items;
  }
}

sealed class _PaginationItem {
  const _PaginationItem();
}

final class _PageItem extends _PaginationItem {
  const _PageItem(this.page);

  final int page;
}

final class _EllipsisItem extends _PaginationItem {
  const _EllipsisItem();
}

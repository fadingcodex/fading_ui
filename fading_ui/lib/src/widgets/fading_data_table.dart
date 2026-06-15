import 'package:flutter/widgets.dart';

import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

typedef FadingDataTableSortChanged =
    void Function(int columnIndex, bool ascending);
typedef FadingDataTableRowTap<T> = void Function(int rowIndex, T row);

class FadingDataColumn<T> {
  const FadingDataColumn({
    required this.label,
    required this.cellBuilder,
    this.sortComparator,
    this.numeric = false,
    this.flex = 1,
  }) : assert(flex > 0, 'flex must be greater than zero');

  final String label;
  final Widget Function(BuildContext context, T row) cellBuilder;
  final Comparator<T>? sortComparator;
  final bool numeric;
  final int flex;

  bool get sortable => sortComparator != null;
}

class FadingDataTable<T> extends StatefulWidget {
  const FadingDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.label,
    this.enabled = true,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSortChanged,
    this.selectedRowIndex,
    this.onRowTap,
    this.emptyLabel = 'No rows.',
    this.minWidth = 560,
  }) : assert(columns.length > 0, 'columns must not be empty'),
       assert(minWidth > 0, 'minWidth must be greater than zero'),
       assert(
         selectedRowIndex == null || selectedRowIndex >= 0,
         'selectedRowIndex must be null or greater than or equal to zero',
       ),
       assert(
         sortColumnIndex == null || sortColumnIndex >= 0,
         'sortColumnIndex must be null or greater than or equal to zero',
       ),
       assert(
         sortColumnIndex == null || sortColumnIndex < columns.length,
         'sortColumnIndex must be in range of columns',
       );

  final List<FadingDataColumn<T>> columns;
  final List<T> rows;
  final String? label;
  final bool enabled;
  final int? sortColumnIndex;
  final bool sortAscending;
  final FadingDataTableSortChanged? onSortChanged;
  final int? selectedRowIndex;
  final FadingDataTableRowTap<T>? onRowTap;
  final String emptyLabel;
  final double minWidth;

  @override
  State<FadingDataTable<T>> createState() => _FadingDataTableState<T>();
}

class _FadingDataTableState<T> extends State<FadingDataTable<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  int? _hoveredRowIndex;

  bool get _isEnabled => widget.enabled;
  bool get _isSortControlled => widget.onSortChanged != null;

  int? get _activeSortColumnIndex {
    return _isSortControlled ? widget.sortColumnIndex : _sortColumnIndex;
  }

  bool get _activeSortAscending {
    return _isSortControlled ? widget.sortAscending : _sortAscending;
  }

  @override
  void initState() {
    super.initState();
    _sortColumnIndex = widget.sortColumnIndex;
    _sortAscending = widget.sortAscending;
  }

  @override
  void didUpdateWidget(covariant FadingDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sortColumnIndex != oldWidget.sortColumnIndex) {
      _sortColumnIndex = widget.sortColumnIndex;
    }
    if (widget.sortAscending != oldWidget.sortAscending) {
      _sortAscending = widget.sortAscending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FadingThemeScope.of(context);
    final List<T> resolvedRows = _resolvedRows();

    return Opacity(
      opacity: _isEnabled ? 1 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.label != null) ...<Widget>[
            Text(
              widget.label!,
              style: theme.bodyMedium.copyWith(color: theme.textMuted),
            ),
            const SizedBox(height: 8),
          ],
          FadingSurface(
            style: FadingSurfaceStyle.inset,
            padding: const EdgeInsets.all(10),
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double targetWidth =
                    constraints.maxWidth > widget.minWidth
                    ? constraints.maxWidth
                    : widget.minWidth;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: targetWidth,
                    child: Column(
                      children: <Widget>[
                        _buildHeaderRow(context),
                        const SizedBox(height: 8),
                        if (resolvedRows.isEmpty)
                          _buildEmptyState(context)
                        else
                          for (
                            var index = 0;
                            index < resolvedRows.length;
                            index++
                          )
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: index == resolvedRows.length - 1
                                    ? 0
                                    : 6,
                              ),
                              child: _buildDataRow(
                                context,
                                index,
                                resolvedRows[index],
                              ),
                            ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final theme = FadingThemeScope.of(context);
    final int? activeSortColumn = _activeSortColumnIndex;

    return FadingSurface(
      style: FadingSurfaceStyle.raised,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      child: Row(
        children: <Widget>[
          for (var index = 0; index < widget.columns.length; index++)
            Expanded(
              flex: widget.columns[index].flex,
              child: GestureDetector(
                key: ValueKey<String>('fading-data-table-header-$index'),
                behavior: HitTestBehavior.opaque,
                onTap: widget.columns[index].sortable
                    ? () => _handleHeaderTap(index)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Align(
                    alignment: widget.columns[index].numeric
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          widget.columns[index].label,
                          style: theme.labelLarge.copyWith(
                            color: activeSortColumn == index
                                ? theme.accentStrong
                                : theme.textPrimary,
                          ),
                        ),
                        if (activeSortColumn == index) ...<Widget>[
                          const SizedBox(width: 6),
                          Text(
                            _activeSortAscending ? '^' : 'v',
                            style: theme.labelLarge.copyWith(
                              color: theme.accentStrong,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, int index, T row) {
    final theme = FadingThemeScope.of(context);
    final bool selected = widget.selectedRowIndex == index;
    final bool hovered = _hoveredRowIndex == index;
    final bool canTap = _isEnabled && widget.onRowTap != null;

    Color rowColor = theme.surfaceRaised;
    if (selected) {
      rowColor = theme.selectionActive.withValues(alpha: 0.22);
    } else if (hovered) {
      rowColor = theme.selectionInactive.withValues(alpha: 0.2);
    }

    return MouseRegion(
      onEnter: (_) {
        if (_isEnabled) {
          setState(() {
            _hoveredRowIndex = index;
          });
        }
      },
      onExit: (_) {
        if (_hoveredRowIndex == index) {
          setState(() {
            _hoveredRowIndex = null;
          });
        }
      },
      child: GestureDetector(
        key: ValueKey<String>('fading-data-table-row-$index'),
        behavior: HitTestBehavior.opaque,
        onTap: canTap ? () => widget.onRowTap?.call(index, row) : null,
        child: FadingSurface(
          style: selected
              ? FadingSurfaceStyle.inset
              : FadingSurfaceStyle.raised,
          color: rowColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Row(
            children: <Widget>[
              for (
                var columnIndex = 0;
                columnIndex < widget.columns.length;
                columnIndex++
              )
                Expanded(
                  flex: widget.columns[columnIndex].flex,
                  child: Align(
                    alignment: widget.columns[columnIndex].numeric
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: widget.columns[columnIndex].cellBuilder(
                      context,
                      row,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = FadingThemeScope.of(context);
    return FadingSurface(
      style: FadingSurfaceStyle.raised,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: SizedBox(
        height: 68,
        child: Center(
          child: Text(
            widget.emptyLabel,
            style: theme.bodyMedium.copyWith(color: theme.textMuted),
          ),
        ),
      ),
    );
  }

  void _handleHeaderTap(int columnIndex) {
    if (!_isEnabled) {
      return;
    }

    final FadingDataColumn<T> column = widget.columns[columnIndex];
    if (!column.sortable) {
      return;
    }

    final bool ascending = _activeSortColumnIndex == columnIndex
        ? !_activeSortAscending
        : true;

    if (_isSortControlled) {
      widget.onSortChanged?.call(columnIndex, ascending);
      return;
    }

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<T> _resolvedRows() {
    final int? sortColumnIndex = _activeSortColumnIndex;
    if (sortColumnIndex == null) {
      return widget.rows;
    }

    final FadingDataColumn<T> column = widget.columns[sortColumnIndex];
    final Comparator<T>? comparator = column.sortComparator;
    if (comparator == null) {
      return widget.rows;
    }

    final List<T> sorted = widget.rows.toList();
    sorted.sort(comparator);
    if (!_activeSortAscending) {
      return sorted.reversed.toList();
    }

    return sorted;
  }
}

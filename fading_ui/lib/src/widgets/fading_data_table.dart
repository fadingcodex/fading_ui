import 'package:flutter/widgets.dart';

import '../theme/fading_theme_scope.dart';
import 'fading_pagination.dart';
import 'fading_surface.dart';

typedef FadingDataTableSortChanged =
    void Function(int columnIndex, bool ascending);
typedef FadingDataTableRowTap<T> = void Function(int rowIndex, T row);
typedef FadingDataTableFilter<T> = bool Function(T row, String query);
typedef FadingDataTableQueryChanged = void Function(FadingDataTableQuery query);
typedef FadingDataTableColumnWidthsChanged =
    void Function(Map<int, double> widths);

class FadingDataTableQuery {
  const FadingDataTableQuery({
    this.sortColumnIndex,
    required this.sortAscending,
    required this.page,
    required this.rowsPerPage,
    required this.filterQuery,
  });

  final int? sortColumnIndex;
  final bool sortAscending;
  final int page;
  final int rowsPerPage;
  final String filterQuery;
}

class FadingDataColumn<T> {
  const FadingDataColumn({
    required this.label,
    required this.cellBuilder,
    this.sortComparator,
    this.numeric = false,
    this.flex = 1,
    this.headerAlignment,
    this.cellAlignment,
    this.width,
    this.minWidth = 96,
    this.maxWidth,
    this.resizable = false,
  }) : assert(flex > 0, 'flex must be greater than zero');

  final String label;
  final Widget Function(BuildContext context, T row) cellBuilder;
  final Comparator<T>? sortComparator;
  final bool numeric;
  final int flex;
  final Alignment? headerAlignment;
  final Alignment? cellAlignment;
  final double? width;
  final double minWidth;
  final double? maxWidth;
  final bool resizable;

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
    this.page,
    this.rowsPerPage,
    this.totalRowCount,
    this.onPageChanged,
    this.paginationLabel,
    this.filterQuery = '',
    this.filterPredicate,
    this.onQueryChanged,
    this.applyLocalOperations = true,
    this.columnWidths,
    this.onColumnWidthsChanged,
    this.defaultResizableColumnWidth = 160,
  }) : assert(columns.length > 0, 'columns must not be empty'),
       assert(minWidth > 0, 'minWidth must be greater than zero'),
       assert(page == null || page > 0, 'page must be greater than zero'),
       assert(
         rowsPerPage == null || rowsPerPage > 0,
         'rowsPerPage must be greater than zero',
       ),
       assert(
         totalRowCount == null || totalRowCount >= 0,
         'totalRowCount must not be negative',
       ),
       assert(
         defaultResizableColumnWidth > 0,
         'defaultResizableColumnWidth must be greater than zero',
       ),
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
  final int? page;
  final int? rowsPerPage;
  final int? totalRowCount;
  final ValueChanged<int>? onPageChanged;
  final String? paginationLabel;
  final String filterQuery;
  final FadingDataTableFilter<T>? filterPredicate;
  final FadingDataTableQueryChanged? onQueryChanged;
  final bool applyLocalOperations;
  final Map<int, double>? columnWidths;
  final FadingDataTableColumnWidthsChanged? onColumnWidthsChanged;
  final double defaultResizableColumnWidth;

  @override
  State<FadingDataTable<T>> createState() => _FadingDataTableState<T>();
}

class _FadingDataTableState<T> extends State<FadingDataTable<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  int? _hoveredRowIndex;
  int _page = 1;
  final Map<int, double> _columnWidths = <int, double>{};

  static const int _defaultRowsPerPage = 10;

  bool get _isEnabled => widget.enabled;
  bool get _isSortControlled => widget.onSortChanged != null;
  bool get _isPageControlled => widget.onPageChanged != null;
  bool get _isColumnWidthControlled => widget.columnWidths != null;

  int get _activeRowsPerPage => widget.rowsPerPage ?? _defaultRowsPerPage;

  int get _activePage {
    return _isPageControlled ? (widget.page ?? _page) : _page;
  }

  int get _effectiveTotalRows {
    return widget.totalRowCount ?? widget.rows.length;
  }

  int get _effectiveTotalPages {
    final int rowsPerPage = _activeRowsPerPage;
    if (rowsPerPage <= 0) {
      return 1;
    }
    final int computed = (_effectiveTotalRows / rowsPerPage).ceil();
    return computed < 1 ? 1 : computed;
  }

  Map<int, double> get _activeColumnWidths {
    return _isColumnWidthControlled ? widget.columnWidths! : _columnWidths;
  }

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
    _page = widget.page ?? 1;
    _hydrateColumnWidthsFromColumns();
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
    if (widget.page != oldWidget.page && widget.page != null) {
      _page = widget.page!;
    }
    if (widget.columns != oldWidget.columns) {
      _hydrateColumnWidthsFromColumns();
    }
    if (widget.filterQuery != oldWidget.filterQuery && !_isPageControlled) {
      final int clampedPage = _clampPage(_page, _effectiveTotalPages);
      if (clampedPage != _page) {
        setState(() {
          _page = clampedPage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FadingThemeScope.of(context);
    final _FadingResolvedRows<T> resolved = _resolvedRows();

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
                        if (resolved.rows.isEmpty)
                          _buildEmptyState(context)
                        else
                          for (
                            var index = 0;
                            index < resolved.rows.length;
                            index++
                          )
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: index == resolved.rows.length - 1
                                    ? 0
                                    : 6,
                              ),
                              child: _buildDataRow(
                                context,
                                index,
                                resolved.rows[index],
                              ),
                            ),
                        if (widget.rowsPerPage != null) ...<Widget>[
                          const SizedBox(height: 10),
                          _buildPagination(context, resolved),
                        ],
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
            _buildColumnSlot(
              index,
              _buildHeaderCell(context, index, activeSortColumn, theme),
              isHeader: true,
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
    BuildContext context,
    int index,
    int? activeSortColumn,
    dynamic theme,
  ) {
    final FadingDataColumn<T> column = widget.columns[index];

    return GestureDetector(
      key: ValueKey<String>('fading-data-table-header-$index'),
      behavior: HitTestBehavior.opaque,
      onTap: column.sortable ? () => _handleHeaderTap(index) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Align(
          alignment: _headerAlignmentFor(column),
          child: Row(
            key: ValueKey<String>('fading-data-table-header-content-$index'),
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                column.label,
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
                  style: theme.labelLarge.copyWith(color: theme.accentStrong),
                ),
              ],
            ],
          ),
        ),
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
                _buildColumnSlot(
                  columnIndex,
                  Align(
                    alignment: _cellAlignmentFor(widget.columns[columnIndex]),
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

  Widget _buildPagination(
    BuildContext context,
    _FadingResolvedRows<T> resolved,
  ) {
    final int totalPages = resolved.totalPages;
    final int page = resolved.page;

    return FadingPagination(
      label:
          widget.paginationLabel ??
          'Page $page of $totalPages (${resolved.totalRows} rows)',
      enabled: _isEnabled,
      currentPage: page,
      totalPages: totalPages,
      onPageChanged: _isEnabled ? _handlePageChanged : null,
    );
  }

  Widget _buildColumnSlot(int index, Widget child, {bool isHeader = false}) {
    final FadingDataColumn<T> column = widget.columns[index];
    final double? width = _resolvedColumnWidth(index);
    final Widget content = isHeader
        ? _buildResizableHeaderCell(index, child)
        : child;

    if (width != null) {
      return SizedBox(width: width, child: content);
    }

    return Expanded(flex: column.flex, child: content);
  }

  Widget _buildResizableHeaderCell(int index, Widget child) {
    final FadingDataColumn<T> column = widget.columns[index];
    if (!column.resizable || !_isEnabled) {
      return child;
    }

    return Row(
      children: <Widget>[
        Expanded(child: child),
        GestureDetector(
          key: ValueKey<String>('fading-data-table-resize-handle-$index'),
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            _resizeColumn(index, details.delta.dx);
          },
          child: const SizedBox(width: 12, height: 24),
        ),
      ],
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
      _emitQueryChanged(sortColumnIndex: columnIndex, sortAscending: ascending);
      return;
    }

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      if (!_isPageControlled) {
        _page = 1;
      }
    });

    _emitQueryChanged(sortColumnIndex: columnIndex, sortAscending: ascending);
  }

  void _handlePageChanged(int page) {
    if (!_isEnabled) {
      return;
    }

    final int nextPage = _clampPage(page, _resolveTotalPages());
    if (_isPageControlled) {
      widget.onPageChanged?.call(nextPage);
      _emitQueryChanged(page: nextPage);
      return;
    }

    setState(() {
      _page = nextPage;
    });
    widget.onPageChanged?.call(nextPage);
    _emitQueryChanged(page: nextPage);
  }

  void _resizeColumn(int index, double deltaDx) {
    if (!_isEnabled) {
      return;
    }

    final FadingDataColumn<T> column = widget.columns[index];
    final Map<int, double> next = Map<int, double>.from(_activeColumnWidths);
    final double base =
        next[index] ?? column.width ?? widget.defaultResizableColumnWidth;

    final double nextWidth = _clampColumnWidth(column, base + deltaDx);
    next[index] = nextWidth;

    if (_isColumnWidthControlled) {
      widget.onColumnWidthsChanged?.call(next);
      return;
    }

    setState(() {
      _columnWidths
        ..clear()
        ..addAll(next);
    });
    widget.onColumnWidthsChanged?.call(next);
  }

  void _hydrateColumnWidthsFromColumns() {
    if (_isColumnWidthControlled) {
      return;
    }
    _columnWidths
      ..clear()
      ..addEntries(<MapEntry<int, double>>[
        for (var index = 0; index < widget.columns.length; index++)
          if (widget.columns[index].width != null)
            MapEntry<int, double>(index, widget.columns[index].width!),
      ]);
  }

  double? _resolvedColumnWidth(int index) {
    final FadingDataColumn<T> column = widget.columns[index];
    final double? configured = _activeColumnWidths[index] ?? column.width;
    if (configured == null) {
      return null;
    }
    return _clampColumnWidth(column, configured);
  }

  double _clampColumnWidth(FadingDataColumn<T> column, double width) {
    final double maxWidth = column.maxWidth ?? double.infinity;
    return width.clamp(column.minWidth, maxWidth).toDouble();
  }

  int _clampPage(int page, int totalPages) {
    return page.clamp(1, totalPages).toInt();
  }

  Alignment _headerAlignmentFor(FadingDataColumn<T> column) {
    return column.headerAlignment ??
        (column.numeric ? Alignment.centerRight : Alignment.centerLeft);
  }

  Alignment _cellAlignmentFor(FadingDataColumn<T> column) {
    return column.cellAlignment ??
        (column.numeric ? Alignment.centerRight : Alignment.centerLeft);
  }

  void _emitQueryChanged({
    int? sortColumnIndex,
    bool? sortAscending,
    int? page,
  }) {
    if (widget.onQueryChanged == null) {
      return;
    }

    widget.onQueryChanged!(
      FadingDataTableQuery(
        sortColumnIndex: sortColumnIndex ?? _activeSortColumnIndex,
        sortAscending: sortAscending ?? _activeSortAscending,
        page: page ?? _activePage,
        rowsPerPage: _activeRowsPerPage,
        filterQuery: widget.filterQuery,
      ),
    );
  }

  _FadingResolvedRows<T> _resolvedRows() {
    final List<T> base = widget.applyLocalOperations
        ? _resolvedRowsWithoutPagination()
        : widget.rows;

    final int rowsPerPage = _activeRowsPerPage;
    final int totalRows = widget.applyLocalOperations
        ? base.length
        : _effectiveTotalRows;
    final int totalPages = widget.rowsPerPage == null
        ? 1
        : _computeTotalPages(totalRows, rowsPerPage);
    final int page = _clampPage(_activePage, totalPages);

    if (widget.rowsPerPage == null || !widget.applyLocalOperations) {
      return _FadingResolvedRows<T>(
        rows: base,
        totalRows: totalRows,
        totalPages: totalPages,
        page: page,
      );
    }

    final int start = (page - 1) * rowsPerPage;
    if (start >= base.length) {
      return _FadingResolvedRows<T>(
        rows: <T>[],
        totalRows: totalRows,
        totalPages: totalPages,
        page: page,
      );
    }
    final int end = (start + rowsPerPage).clamp(0, base.length);
    return _FadingResolvedRows<T>(
      rows: base.sublist(start, end),
      totalRows: totalRows,
      totalPages: totalPages,
      page: page,
    );
  }

  List<T> _resolvedRowsWithoutPagination() {
    List<T> working = widget.rows;

    final String query = widget.filterQuery.trim();
    if (query.isNotEmpty) {
      final FadingDataTableFilter<T>? predicate = widget.filterPredicate;
      if (predicate != null) {
        working = working.where((T row) => predicate(row, query)).toList();
      }
    }

    final int? sortColumnIndex = _activeSortColumnIndex;
    if (sortColumnIndex != null) {
      final FadingDataColumn<T> column = widget.columns[sortColumnIndex];
      final Comparator<T>? comparator = column.sortComparator;
      if (comparator != null) {
        final List<T> sorted = working.toList();
        sorted.sort(comparator);
        if (!_activeSortAscending) {
          working = sorted.reversed.toList();
        } else {
          working = sorted;
        }
      }
    }

    return working;
  }

  int _resolveTotalPages() {
    final int totalRows = widget.applyLocalOperations
        ? _resolvedRowsWithoutPagination().length
        : _effectiveTotalRows;
    return _computeTotalPages(totalRows, _activeRowsPerPage);
  }

  int _computeTotalPages(int totalRows, int rowsPerPage) {
    if (rowsPerPage <= 0) {
      return 1;
    }
    final int computed = (totalRows / rowsPerPage).ceil();
    return computed < 1 ? 1 : computed;
  }
}

class _FadingResolvedRows<T> {
  const _FadingResolvedRows({
    required this.rows,
    required this.totalRows,
    required this.totalPages,
    required this.page,
  });

  final List<T> rows;
  final int totalRows;
  final int totalPages;
  final int page;
}

import 'package:flutter/widgets.dart';

import '../theme/fading_theme_data.dart';
import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

const ValueKey<String> _previousMonthKey = ValueKey<String>(
  'fading-date-picker-prev-month',
);
const ValueKey<String> _nextMonthKey = ValueKey<String>(
  'fading-date-picker-next-month',
);

const List<String> _monthLabels = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _weekdayLabels = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

class FadingDatePicker extends StatefulWidget {
  const FadingDatePicker({
    super.key,
    this.label,
    required this.selectedDate,
    required this.onChanged,
    this.initialMonth,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  final String? label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onChanged;
  final DateTime? initialMonth;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  @override
  State<FadingDatePicker> createState() => _FadingDatePickerState();
}

class _FadingDatePickerState extends State<FadingDatePicker> {
  late DateTime _displayMonth;

  bool get _canInteract => widget.enabled && widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    assert(
      widget.firstDate == null ||
          widget.lastDate == null ||
          !widget.firstDate!.isAfter(widget.lastDate!),
      'firstDate must be less than or equal to lastDate',
    );
    _displayMonth = _initialDisplayMonth();
  }

  @override
  void didUpdateWidget(covariant FadingDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final DateTime? selectedDate = widget.selectedDate;
    final DateTime? oldSelectedDate = oldWidget.selectedDate;
    if (!_isSameDay(selectedDate, oldSelectedDate) && selectedDate != null) {
      _displayMonth = _firstDayOfMonth(selectedDate);
    }
  }

  DateTime _initialDisplayMonth() {
    final DateTime reference =
        widget.selectedDate ?? widget.initialMonth ?? DateTime.now();
    return _firstDayOfMonth(reference);
  }

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);
    final DateTime monthStart = _firstDayOfMonth(_displayMonth);
    final DateTime? selectedDate = _normalizeNullable(widget.selectedDate);

    return FadingSurface(
      style: FadingSurfaceStyle.raised,
      color: theme.surfaceRaised,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.label != null) ...<Widget>[
            Text(
              widget.label!,
              style: theme.labelLarge.copyWith(color: theme.textMuted),
            ),
            const SizedBox(height: 10),
          ],
          _MonthHeader(
            monthStart: monthStart,
            theme: theme,
            canGoPrevious: _canNavigateToPreviousMonth(monthStart),
            canGoNext: _canNavigateToNextMonth(monthStart),
            enabled: _canInteract,
            onPrevious: _goToPreviousMonth,
            onNext: _goToNextMonth,
          ),
          const SizedBox(height: 14),
          _WeekdayHeader(theme: theme),
          const SizedBox(height: 8),
          ..._buildWeekRows(theme, monthStart, selectedDate),
        ],
      ),
    );
  }

  List<Widget> _buildWeekRows(
    FadingThemeData theme,
    DateTime monthStart,
    DateTime? selectedDate,
  ) {
    final DateTime gridStart = monthStart.subtract(
      Duration(days: monthStart.weekday - DateTime.monday),
    );
    final DateTime today = _normalized(DateTime.now());
    final List<Widget> rows = <Widget>[];

    for (int week = 0; week < 6; week++) {
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: week == 5 ? 0 : 8),
          child: Row(
            children: <Widget>[
              for (int day = 0; day < 7; day++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: day == 6 ? 0 : 6),
                    child: _buildDayCell(
                      theme: theme,
                      date: gridStart.add(Duration(days: week * 7 + day)),
                      monthStart: monthStart,
                      selectedDate: selectedDate,
                      today: today,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildDayCell({
    required FadingThemeData theme,
    required DateTime date,
    required DateTime monthStart,
    required DateTime? selectedDate,
    required DateTime today,
  }) {
    final DateTime normalizedDate = _normalized(date);
    final bool inCurrentMonth = normalizedDate.month == monthStart.month;
    final bool inRange = _inRange(normalizedDate);
    final bool enabled = _canInteract && inCurrentMonth && inRange;
    final bool selected =
        selectedDate != null && _isSameDay(selectedDate, normalizedDate);
    final bool isToday = _isSameDay(normalizedDate, today);

    final Color backgroundColor;
    if (selected) {
      backgroundColor = theme.selectionActive.withValues(alpha: 0.28);
    } else if (enabled) {
      backgroundColor = theme.surfaceInset;
    } else {
      backgroundColor = theme.surfaceInset.withValues(alpha: 0.55);
    }

    Color textColor;
    if (selected) {
      textColor = theme.accentStrong;
    } else if (!inCurrentMonth) {
      textColor = theme.textMuted.withValues(alpha: 0.55);
    } else if (!enabled) {
      textColor = theme.textMuted.withValues(alpha: 0.65);
    } else {
      textColor = theme.textPrimary;
    }

    if (isToday && !selected && enabled) {
      textColor = theme.accent;
    }

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: GestureDetector(
        key: ValueKey<String>(_dayKey(normalizedDate)),
        onTap: enabled ? () => _handleDateTap(normalizedDate) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 36,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? theme.accentStrong
                  : isToday
                  ? theme.accent.withValues(alpha: 0.75)
                  : theme.border.withValues(alpha: 0.5),
              width: selected ? 1.4 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${normalizedDate.day}',
            style: theme.bodyMedium.copyWith(
              color: textColor,
              fontWeight: selected || isToday
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _handleDateTap(DateTime day) {
    if (!_canInteract) {
      return;
    }
    widget.onChanged?.call(day);
  }

  void _goToPreviousMonth() {
    if (!_canInteract) {
      return;
    }
    final DateTime previous = DateTime(
      _displayMonth.year,
      _displayMonth.month - 1,
    );
    if (!_canNavigateToPreviousMonth(_displayMonth)) {
      return;
    }
    setState(() {
      _displayMonth = _firstDayOfMonth(previous);
    });
  }

  void _goToNextMonth() {
    if (!_canInteract) {
      return;
    }
    final DateTime next = DateTime(_displayMonth.year, _displayMonth.month + 1);
    if (!_canNavigateToNextMonth(_displayMonth)) {
      return;
    }
    setState(() {
      _displayMonth = _firstDayOfMonth(next);
    });
  }

  bool _canNavigateToPreviousMonth(DateTime month) {
    final DateTime? firstDate = widget.firstDate == null
        ? null
        : _firstDayOfMonth(widget.firstDate!);
    if (firstDate == null) {
      return true;
    }
    return _monthNumber(month) > _monthNumber(firstDate);
  }

  bool _canNavigateToNextMonth(DateTime month) {
    final DateTime? lastDate = widget.lastDate == null
        ? null
        : _firstDayOfMonth(widget.lastDate!);
    if (lastDate == null) {
      return true;
    }
    return _monthNumber(month) < _monthNumber(lastDate);
  }

  bool _inRange(DateTime date) {
    final DateTime normalizedDate = _normalized(date);
    final DateTime? firstDate = widget.firstDate == null
        ? null
        : _normalized(widget.firstDate!);
    final DateTime? lastDate = widget.lastDate == null
        ? null
        : _normalized(widget.lastDate!);

    if (firstDate != null && normalizedDate.isBefore(firstDate)) {
      return false;
    }
    if (lastDate != null && normalizedDate.isAfter(lastDate)) {
      return false;
    }
    return true;
  }

  static int _monthNumber(DateTime value) => value.year * 12 + value.month;
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.monthStart,
    required this.theme,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.enabled,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime monthStart;
  final FadingThemeData theme;
  final bool canGoPrevious;
  final bool canGoNext;
  final bool enabled;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final String monthLabel =
        '${_monthLabels[monthStart.month - 1]} ${monthStart.year}';
    return Row(
      children: <Widget>[
        _MonthButton(
          key: _previousMonthKey,
          label: '<',
          enabled: enabled && canGoPrevious,
          onTap: onPrevious,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            monthLabel,
            key: const ValueKey<String>('fading-date-picker-month-label'),
            textAlign: TextAlign.center,
            style: theme.titleLarge.copyWith(color: theme.textPrimary),
          ),
        ),
        const SizedBox(width: 12),
        _MonthButton(
          key: _nextMonthKey,
          label: '>',
          enabled: enabled && canGoNext,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled
                ? theme.surfaceInset
                : theme.surfaceInset.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.border.withValues(alpha: enabled ? 0.9 : 0.45),
            ),
          ),
          child: Text(
            label,
            style: theme.labelLarge.copyWith(
              color: enabled
                  ? theme.textPrimary
                  : theme.textMuted.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.theme});

  final FadingThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int index = 0; index < _weekdayLabels.length; index++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == _weekdayLabels.length - 1 ? 0 : 6,
              ),
              child: Text(
                _weekdayLabels[index],
                textAlign: TextAlign.center,
                style: theme.labelLarge.copyWith(
                  color: theme.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

String _dayKey(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return 'fading-date-picker-day-${value.year}-$month-$day';
}

DateTime _firstDayOfMonth(DateTime value) => DateTime(value.year, value.month);

DateTime _normalized(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime? _normalizeNullable(DateTime? value) {
  if (value == null) {
    return null;
  }
  return _normalized(value);
}

bool _isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

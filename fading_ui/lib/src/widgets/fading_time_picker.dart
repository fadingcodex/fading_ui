import 'package:flutter/material.dart' show DayPeriod, TimeOfDay;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/fading_theme_data.dart';
import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

const ValueKey<String> _triggerKey = ValueKey<String>(
  'fading-time-picker-trigger',
);
const ValueKey<String> _dismissAreaKey = ValueKey<String>(
  'fading-time-picker-dismiss-area',
);
const ValueKey<String> _hourUpKey = ValueKey<String>(
  'fading-time-picker-hour-up',
);
const ValueKey<String> _hourDownKey = ValueKey<String>(
  'fading-time-picker-hour-down',
);
const ValueKey<String> _minuteUpKey = ValueKey<String>(
  'fading-time-picker-minute-up',
);
const ValueKey<String> _minuteDownKey = ValueKey<String>(
  'fading-time-picker-minute-down',
);
const ValueKey<String> _meridiemToggleKey = ValueKey<String>(
  'fading-time-picker-meridiem-toggle',
);
const ValueKey<String> _confirmKey = ValueKey<String>(
  'fading-time-picker-confirm',
);
const ValueKey<String> _cancelKey = ValueKey<String>(
  'fading-time-picker-cancel',
);

class FadingTimePicker extends StatefulWidget {
  const FadingTimePicker({
    super.key,
    this.label,
    required this.selectedTime,
    required this.onChanged,
    this.enabled = true,
    this.use24HourFormat = true,
    this.minuteStep = 1,
  }) : assert(minuteStep > 0, 'minuteStep must be greater than zero'),
       assert(60 % minuteStep == 0, 'minuteStep must divide 60 evenly');

  final String? label;
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay>? onChanged;
  final bool enabled;
  final bool use24HourFormat;
  final int minuteStep;

  @override
  State<FadingTimePicker> createState() => _FadingTimePickerState();
}

class _FadingTimePickerState extends State<FadingTimePicker> {
  final GlobalKey _triggerContainerKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();

  OverlayEntry? _overlayEntry;
  bool _isPressed = false;

  bool get _isOpen => _overlayEntry != null;
  bool get _isEnabled => widget.enabled && widget.onChanged != null;

  @override
  void dispose() {
    _removeOverlay(updateState: false);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FadingTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEnabled && _isOpen) {
      _removeOverlay();
    }
  }

  void _toggleOpen() {
    if (!_isEnabled) {
      return;
    }
    if (_isOpen) {
      _removeOverlay();
      return;
    }
    _showOverlay();
    _focusNode.requestFocus();
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      return;
    }

    final BuildContext? triggerContext = _triggerContainerKey.currentContext;
    if (triggerContext == null) {
      return;
    }

    final RenderObject? renderObject = triggerContext.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) {
      return;
    }

    final OverlayState overlay = Overlay.of(context);
    final RenderBox? overlayBox =
        overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null || !overlayBox.attached) {
      return;
    }

    final FadingThemeData theme = FadingThemeScope.of(context);
    final Size triggerSize = renderObject.size;
    final Offset triggerOffset = renderObject.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final Size screenSize = overlayBox.size;
    final EdgeInsets viewPadding = MediaQuery.of(context).viewPadding;

    const double screenMargin = 8;
    const double popupGap = 8;
    const double popupHeight = 296;
    const double popupWidth = 320;

    final double availableBelow =
        screenSize.height -
        triggerOffset.dy -
        triggerSize.height -
        screenMargin;
    final double availableAbove =
        triggerOffset.dy - viewPadding.top - screenMargin;
    final bool openAbove =
        availableBelow < popupHeight && availableAbove > availableBelow;

    final double maxHeight = (openAbove ? availableAbove : availableBelow)
        .clamp(220, popupHeight)
        .toDouble();
    final double width = popupWidth
        .clamp(220, screenSize.width - screenMargin * 2)
        .toDouble();
    final double rawLeft = triggerOffset.dx;
    final double left = rawLeft + width > screenSize.width - screenMargin
        ? screenSize.width - screenMargin - width
        : rawLeft.clamp(screenMargin, screenSize.width - screenMargin - width);
    final double minTop = viewPadding.top + screenMargin;
    final double maxTop = (screenSize.height - screenMargin - maxHeight).clamp(
      minTop,
      double.infinity,
    );
    final double rawTop = openAbove
        ? triggerOffset.dy - popupGap - maxHeight
        : triggerOffset.dy + triggerSize.height + popupGap;
    final double top = rawTop.clamp(minTop, maxTop);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return _FadingTimePickerOverlay(
          theme: theme,
          initialTime: _normalizeMinute(widget.selectedTime, widget.minuteStep),
          use24HourFormat: widget.use24HourFormat,
          minuteStep: widget.minuteStep,
          left: left,
          top: top,
          width: width,
          maxHeight: maxHeight,
          label: widget.label,
          onCancel: _removeOverlay,
          onConfirm: (TimeOfDay value) {
            widget.onChanged?.call(value);
            _removeOverlay();
          },
        );
      },
    );

    overlay.insert(entry);
    setState(() {
      _overlayEntry = entry;
    });
  }

  void _removeOverlay({bool updateState = true}) {
    final OverlayEntry? entry = _overlayEntry;
    if (entry == null) {
      return;
    }

    _overlayEntry = null;
    if (entry.mounted) {
      entry.remove();
    }
    if (updateState && mounted) {
      setState(() {});
    }
    if (mounted && _isEnabled) {
      _focusNode.requestFocus();
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (!_isEnabled || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      _toggleOpen();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape && _isOpen) {
      _removeOverlay();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);
    final String summary = _formatTime(
      widget.selectedTime,
      use24HourFormat: widget.use24HourFormat,
    );

    return Opacity(
      opacity: _isEnabled ? 1 : 0.5,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _isEnabled
              ? (_) {
                  setState(() {
                    _isPressed = true;
                  });
                }
              : null,
          onTapCancel: _isEnabled
              ? () {
                  setState(() {
                    _isPressed = false;
                  });
                }
              : null,
          onTapUp: _isEnabled
              ? (_) {
                  setState(() {
                    _isPressed = false;
                  });
                }
              : null,
          onTap: _toggleOpen,
          child: FadingSurface(
            style: FadingSurfaceStyle.inset,
            color: theme.surfaceInset,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (widget.label != null) ...<Widget>[
                  Text(widget.label!, style: theme.labelLarge),
                  const SizedBox(height: 8),
                ],
                AnimatedContainer(
                  key: _triggerContainerKey,
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _isOpen || _isPressed
                        ? theme.selectionActive.withValues(alpha: 0.2)
                        : theme.surfaceRaised,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    key: _triggerKey,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyMedium.copyWith(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _Chevron(color: theme.textPrimary, isOpen: _isOpen),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FadingTimePickerOverlay extends StatefulWidget {
  const _FadingTimePickerOverlay({
    required this.theme,
    required this.initialTime,
    required this.use24HourFormat,
    required this.minuteStep,
    required this.left,
    required this.top,
    required this.width,
    required this.maxHeight,
    required this.onCancel,
    required this.onConfirm,
    this.label,
  });

  final FadingThemeData theme;
  final TimeOfDay initialTime;
  final bool use24HourFormat;
  final int minuteStep;
  final double left;
  final double top;
  final double width;
  final double maxHeight;
  final String? label;
  final VoidCallback onCancel;
  final ValueChanged<TimeOfDay> onConfirm;

  @override
  State<_FadingTimePickerOverlay> createState() =>
      _FadingTimePickerOverlayState();
}

class _FadingTimePickerOverlayState extends State<_FadingTimePickerOverlay> {
  late TimeOfDay _draftTime;

  @override
  void initState() {
    super.initState();
    _draftTime = widget.initialTime;
  }

  KeyEventResult _handleOverlayKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onCancel();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _updateHour(int delta) {
    setState(() {
      _draftTime = _adjustHour(_draftTime, delta);
    });
  }

  void _updateMinute(int delta) {
    setState(() {
      _draftTime = _adjustMinute(_draftTime, delta, widget.minuteStep);
    });
  }

  void _toggleMeridiem() {
    setState(() {
      _draftTime = _flipMeridiem(_draftTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = widget.theme;

    return Positioned.fill(
      child: Stack(
        children: <Widget>[
          GestureDetector(
            key: _dismissAreaKey,
            behavior: HitTestBehavior.opaque,
            onTap: widget.onCancel,
            child: const SizedBox.expand(),
          ),
          Positioned(
            left: widget.left,
            top: widget.top,
            width: widget.width,
            child: Focus(
              autofocus: true,
              onKeyEvent: _handleOverlayKey,
              child: FadingSurface(
                style: FadingSurfaceStyle.raised,
                color: theme.surfaceRaised,
                padding: const EdgeInsets.all(14),
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: widget.maxHeight),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (widget.label != null) ...<Widget>[
                          Text(
                            widget.label!,
                            style: theme.labelLarge.copyWith(
                              color: theme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          _formatTime(
                            _draftTime,
                            use24HourFormat: widget.use24HourFormat,
                          ),
                          style: theme.displayMedium.copyWith(fontSize: 26),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _TimeStepper(
                                title: 'Hour',
                                value: _hourDisplay(
                                  _draftTime,
                                  use24HourFormat: widget.use24HourFormat,
                                ),
                                incrementKey: _hourUpKey,
                                decrementKey: _hourDownKey,
                                onIncrement: () => _updateHour(1),
                                onDecrement: () => _updateHour(-1),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TimeStepper(
                                title: 'Minute',
                                value: _twoDigits(_draftTime.minute),
                                incrementKey: _minuteUpKey,
                                decrementKey: _minuteDownKey,
                                onIncrement: () => _updateMinute(1),
                                onDecrement: () => _updateMinute(-1),
                              ),
                            ),
                          ],
                        ),
                        if (!widget.use24HourFormat) ...<Widget>[
                          const SizedBox(height: 12),
                          _ActionButton(
                            key: _meridiemToggleKey,
                            label: _draftTime.period == DayPeriod.am
                                ? 'AM'
                                : 'PM',
                            primary: false,
                            onTap: _toggleMeridiem,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _ActionButton(
                                key: _cancelKey,
                                label: 'Cancel',
                                primary: false,
                                onTap: widget.onCancel,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ActionButton(
                                key: _confirmKey,
                                label: 'Apply',
                                primary: true,
                                onTap: () => widget.onConfirm(_draftTime),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeStepper extends StatelessWidget {
  const _TimeStepper({
    required this.title,
    required this.value,
    required this.incrementKey,
    required this.decrementKey,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String title;
  final String value;
  final ValueKey<String> incrementKey;
  final ValueKey<String> decrementKey;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);

    return FadingSurface(
      style: FadingSurfaceStyle.inset,
      padding: const EdgeInsets.all(12),
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Column(
        children: <Widget>[
          Text(
            title,
            style: theme.labelLarge.copyWith(
              fontSize: 12,
              color: theme.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          _ArrowButton(key: incrementKey, label: '+', onTap: onIncrement),
          const SizedBox(height: 10),
          Text(value, style: theme.displayMedium.copyWith(fontSize: 28)),
          const SizedBox(height: 10),
          _ArrowButton(key: decrementKey, label: '-', onTap: onDecrement),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 42,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.border.withValues(alpha: 0.75)),
        ),
        child: Text(label, style: theme.titleLarge.copyWith(fontSize: 18)),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: primary ? theme.selectionActive : theme.surfaceInset,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primary
                ? theme.accentStrong.withValues(alpha: 0.8)
                : theme.border.withValues(alpha: 0.75),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.labelLarge.copyWith(
            color: primary ? theme.backgroundStart : theme.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.color, required this.isOpen});

  final Color color;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      duration: const Duration(milliseconds: 160),
      turns: isOpen ? 0.5 : 0,
      child: Text(
        '⌄',
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

TimeOfDay _normalizeMinute(TimeOfDay time, int minuteStep) {
  final int remainder = time.minute % minuteStep;
  if (remainder == 0) {
    return time;
  }
  final int roundedMinute = time.minute - remainder;
  return TimeOfDay(hour: time.hour, minute: roundedMinute);
}

TimeOfDay _adjustHour(TimeOfDay time, int delta) {
  final int nextHour = (time.hour + delta) % 24;
  return TimeOfDay(
    hour: nextHour < 0 ? nextHour + 24 : nextHour,
    minute: time.minute,
  );
}

TimeOfDay _adjustMinute(TimeOfDay time, int delta, int minuteStep) {
  final int totalMinutes = time.hour * 60 + time.minute + delta * minuteStep;
  const int minutesPerDay = 24 * 60;
  final int wrappedMinutes =
      ((totalMinutes % minutesPerDay) + minutesPerDay) % minutesPerDay;
  return TimeOfDay(hour: wrappedMinutes ~/ 60, minute: wrappedMinutes % 60);
}

TimeOfDay _flipMeridiem(TimeOfDay time) {
  final int nextHour = (time.hour + 12) % 24;
  return TimeOfDay(hour: nextHour, minute: time.minute);
}

String _formatTime(TimeOfDay time, {required bool use24HourFormat}) {
  final String minute = _twoDigits(time.minute);
  if (use24HourFormat) {
    return '${_twoDigits(time.hour)}:$minute';
  }

  final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final String suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}

String _hourDisplay(TimeOfDay time, {required bool use24HourFormat}) {
  if (use24HourFormat) {
    return _twoDigits(time.hour);
  }
  final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  return _twoDigits(hour);
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

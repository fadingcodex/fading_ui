import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/fading_theme_data.dart';
import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

class FadingSelectOption<T> {
  const FadingSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

String _optionKeyForLabel(String label) => 'fading-select-option-$label';

class FadingSelect<T> extends StatefulWidget {
  const FadingSelect({
    super.key,
    required this.options,
    required this.values,
    required this.onChanged,
    this.label,
    this.placeholder = 'Select options',
    this.enabled = true,
    this.maxMenuHeight = 260,
    this.menuWidth,
  }) : value = null,
       onValueChanged = null,
       multiSelect = true,
       assert(maxMenuHeight > 0, 'maxMenuHeight must be greater than zero');

  const FadingSelect.single({
    super.key,
    required this.options,
    this.value,
    required this.onValueChanged,
    this.label,
    this.placeholder = 'Select option',
    this.enabled = true,
    this.maxMenuHeight = 260,
    this.menuWidth,
  }) : values = null,
       onChanged = null,
       multiSelect = false,
       assert(maxMenuHeight > 0, 'maxMenuHeight must be greater than zero');

  final List<FadingSelectOption<T>> options;
  final List<T>? values;
  final ValueChanged<List<T>>? onChanged;
  final T? value;
  final ValueChanged<T?>? onValueChanged;
  final bool multiSelect;
  final String? label;
  final String placeholder;
  final bool enabled;
  final double maxMenuHeight;
  final double? menuWidth;

  @override
  State<FadingSelect<T>> createState() => _FadingSelectState<T>();
}

class _FadingSelectState<T> extends State<FadingSelect<T>> {
  final GlobalKey _triggerKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();

  OverlayEntry? _overlayEntry;
  bool _isPressed = false;

  bool get _isOpen => _overlayEntry != null;
  bool get _isEnabled {
    if (!widget.enabled) {
      return false;
    }
    return widget.multiSelect
        ? widget.onChanged != null
        : widget.onValueChanged != null;
  }

  List<T> get _selectedValues {
    if (widget.multiSelect) {
      return widget.values ?? <T>[];
    }
    final T? selected = widget.value;
    if (selected == null) {
      return <T>[];
    }
    return <T>[selected];
  }

  @override
  void dispose() {
    _removeOverlay(updateState: false);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FadingSelect<T> oldWidget) {
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

    final BuildContext? triggerContext = _triggerKey.currentContext;
    if (triggerContext == null) {
      return;
    }

    final RenderObject? renderObject = triggerContext.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) {
      return;
    }

    final FadingThemeData theme = FadingThemeScope.of(context);
    final OverlayState overlay = Overlay.of(context);
    final RenderBox? overlayBox =
        overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null || !overlayBox.attached) {
      return;
    }

    final Size triggerSize = renderObject.size;
    final Offset triggerOffset = renderObject.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );

    final Size screenSize = overlayBox.size;
    final EdgeInsets viewPadding = MediaQuery.of(context).viewPadding;

    const double screenMargin = 8;
    const double dropdownGap = 8;
    const double rowHeight = 44;
    final double estimatedHeight = (widget.options.length * rowHeight + 12)
        .clamp(96, widget.maxMenuHeight)
        .toDouble();

    final double availableBelow =
        screenSize.height -
        triggerOffset.dy -
        triggerSize.height -
        screenMargin;
    final double availableAbove =
        triggerOffset.dy - viewPadding.top - screenMargin;

    final bool openAbove =
        availableBelow < estimatedHeight && availableAbove > availableBelow;

    final double maxHeight = (openAbove ? availableAbove : availableBelow)
        .clamp(0, widget.maxMenuHeight)
        .toDouble();

    if (maxHeight <= 0) {
      return;
    }

    final double left = triggerOffset.dx.clamp(
      screenMargin,
      screenSize.width - screenMargin,
    );

    final double preferredWidth = widget.menuWidth ?? triggerSize.width;
    final double width = preferredWidth
        .clamp(120, screenSize.width - screenMargin * 2)
        .toDouble();

    final double resolvedLeft = left + width > screenSize.width - screenMargin
        ? screenSize.width - screenMargin - width
        : left;

    final double minTop = viewPadding.top + screenMargin;
    final double maxTop = (screenSize.height - screenMargin - maxHeight).clamp(
      minTop,
      double.infinity,
    );
    final double rawTop = openAbove
        ? triggerOffset.dy - dropdownGap - maxHeight
        : triggerOffset.dy + triggerSize.height + dropdownGap;
    final double top = rawTop.clamp(minTop, maxTop);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return _FadingSelectOverlay<T>(
          theme: theme,
          options: widget.options,
          selectedValues: _selectedValues,
          multiSelect: widget.multiSelect,
          width: width,
          maxHeight: maxHeight,
          left: resolvedLeft,
          top: top,
          onDismissed: _removeOverlay,
          onOptionToggled: _toggleValue,
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
      setState(() {
        // Local visual state depends on _isOpen.
      });
    }
    if (mounted && _isEnabled) {
      _focusNode.requestFocus();
    }
  }

  void _toggleValue(T value) {
    if (!_isEnabled) {
      return;
    }

    if (!widget.multiSelect) {
      widget.onValueChanged?.call(value);
      _removeOverlay();
      return;
    }

    final Set<T> current = _selectedValues.toSet();
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }

    final List<T> ordered = <T>[];
    for (final FadingSelectOption<T> option in widget.options) {
      if (current.contains(option.value)) {
        ordered.add(option.value);
      }
    }

    widget.onChanged?.call(ordered);
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

  String _selectedSummary() {
    final List<T> selectedValues = _selectedValues;
    if (selectedValues.isEmpty) {
      return widget.placeholder;
    }

    final Map<T, String> labelsByValue = <T, String>{
      for (final FadingSelectOption<T> option in widget.options)
        option.value: option.label,
    };

    final List<String> labels = <String>[];
    for (final T value in selectedValues) {
      final String? label = labelsByValue[value];
      if (label != null) {
        labels.add(label);
      }
    }

    if (labels.isEmpty) {
      return widget.placeholder;
    }

    if (labels.length <= 2) {
      return labels.join(', ');
    }

    return '${labels.take(2).join(', ')} +${labels.length - 2} more';
  }

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);
    final bool hasSelection = _selectedValues.isNotEmpty;

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
                  key: _triggerKey,
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
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _selectedSummary(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyMedium.copyWith(
                            color: hasSelection
                                ? theme.textPrimary
                                : theme.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
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

class _FadingSelectOverlay<T> extends StatelessWidget {
  const _FadingSelectOverlay({
    required this.theme,
    required this.options,
    required this.selectedValues,
    required this.multiSelect,
    required this.width,
    required this.maxHeight,
    required this.left,
    required this.top,
    required this.onDismissed,
    required this.onOptionToggled,
  });

  final FadingThemeData theme;
  final List<FadingSelectOption<T>> options;
  final List<T> selectedValues;
  final bool multiSelect;
  final double width;
  final double maxHeight;
  final double left;
  final double top;
  final VoidCallback onDismissed;
  final ValueChanged<T> onOptionToggled;

  KeyEventResult _handleOverlayKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      onDismissed();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final Set<T> selectedSet = selectedValues.toSet();

    return Positioned.fill(
      child: Stack(
        children: <Widget>[
          GestureDetector(
            key: const ValueKey<String>('fading-select-dismiss-area'),
            behavior: HitTestBehavior.opaque,
            onTap: onDismissed,
            child: const SizedBox.expand(),
          ),
          Positioned(
            left: left,
            top: top,
            width: width,
            child: Focus(
              autofocus: true,
              onKeyEvent: _handleOverlayKey,
              child: FadingSurface(
                style: FadingSurfaceStyle.raised,
                color: theme.surfaceRaised,
                padding: const EdgeInsets.all(6),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        for (final FadingSelectOption<T> option in options)
                          _SelectOptionRow(
                            key: ValueKey<String>(
                              _optionKeyForLabel(option.label),
                            ),
                            label: option.label,
                            selected: selectedSet.contains(option.value),
                            multiSelect: multiSelect,
                            theme: theme,
                            onTap: () => onOptionToggled(option.value),
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

class _SelectOptionRow extends StatelessWidget {
  const _SelectOptionRow({
    super.key,
    required this.label,
    required this.selected,
    required this.multiSelect,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool multiSelect;
  final FadingThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.selectionActive.withValues(alpha: 0.24)
              : const Color(0x00000000),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 18,
              height: 18,
              decoration: multiSelect
                  ? BoxDecoration(
                      color: selected
                          ? theme.selectionActive
                          : theme.selectionInactive,
                      borderRadius: BorderRadius.circular(5),
                    )
                  : BoxDecoration(
                      color: selected
                          ? theme.selectionActive
                          : theme.selectionInactive,
                      shape: BoxShape.circle,
                    ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: theme.controlKnob,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: theme.bodyMedium.copyWith(
                  color: selected ? theme.textPrimary : theme.textMuted,
                ),
              ),
            ),
          ],
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
      turns: isOpen ? 0.5 : 0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      child: SizedBox(
        width: 14,
        height: 14,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              left: 1,
              child: Transform.rotate(
                angle: 0.78,
                child: Container(width: 2, height: 9, color: color),
              ),
            ),
            Positioned(
              right: 1,
              child: Transform.rotate(
                angle: -0.78,
                child: Container(width: 2, height: 9, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

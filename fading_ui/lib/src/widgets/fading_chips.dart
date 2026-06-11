import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/fading_theme_data.dart';
import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

class FadingChipsOption {
  const FadingChipsOption({required this.value, required this.label});

  final String value;
  final String label;
}

String _optionKeyForLabel(String label) => 'fading-chips-option-$label';
String _chipKeyForValue(String value) => 'fading-chips-chip-$value';
String _removeKeyForValue(String value) => 'fading-chips-remove-$value';

class FadingChips extends StatefulWidget {
  const FadingChips({
    super.key,
    required this.values,
    required this.onChanged,
    this.options = const <FadingChipsOption>[],
    this.controller,
    this.focusNode,
    this.label,
    this.hint = 'Add chip',
    this.enabled = true,
    this.allowCustomValues = true,
    this.maxValues,
  }) : assert(maxValues == null || maxValues > 0, 'maxValues must be positive');

  final List<String> values;
  final ValueChanged<List<String>>? onChanged;
  final List<FadingChipsOption> options;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String hint;
  final bool enabled;
  final bool allowCustomValues;
  final int? maxValues;

  @override
  State<FadingChips> createState() => _FadingChipsState();
}

class _FadingChipsState extends State<FadingChips> {
  static final RegExp _separatorPattern = RegExp(r'[\n,]');

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final bool _ownsController;
  late final bool _ownsFocusNode;
  bool _isProcessingTextChange = false;

  bool get _isEnabled => widget.enabled && widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_handleTextChanged);
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _focusNode.removeListener(_handleFocusChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChanged() {
    setState(() {});
  }

  void _handleTextChanged() {
    if (_isProcessingTextChange || !_isEnabled || !widget.allowCustomValues) {
      setState(() {});
      return;
    }

    final String text = _controller.text;
    if (!_separatorPattern.hasMatch(text)) {
      setState(() {});
      return;
    }

    final List<String> segments = text.split(_separatorPattern);
    final bool endsWithSeparator = RegExp(r'[\n,]\s*$').hasMatch(text);
    final int tokenCount = endsWithSeparator
        ? segments.length
        : (segments.length - 1).clamp(0, segments.length);

    final List<String> completed = <String>[];
    for (var index = 0; index < tokenCount; index++) {
      final String token = segments[index].trim();
      if (token.isNotEmpty) {
        completed.add(token);
      }
    }

    if (completed.isNotEmpty) {
      _emitNextValues(_nextValuesWithTokens(completed));
    }

    final String trailingText = endsWithSeparator
        ? ''
        : segments.last.trimLeft();
    _isProcessingTextChange = true;
    _controller.value = TextEditingValue(
      text: trailingText,
      selection: TextSelection.collapsed(offset: trailingText.length),
    );
    _isProcessingTextChange = false;
    setState(() {});
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (!_isEnabled || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _commitCurrentInput();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _controller.text.isEmpty &&
        widget.values.isNotEmpty) {
      _removeChip(widget.values.last);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  bool _containsIgnoreCase(Iterable<String> values, String candidate) {
    final String normalizedCandidate = candidate.trim().toLowerCase();
    for (final String value in values) {
      if (value.trim().toLowerCase() == normalizedCandidate) {
        return true;
      }
    }
    return false;
  }

  List<String> _nextValuesWithTokens(List<String> tokens) {
    final List<String> next = List<String>.of(widget.values);
    for (final String token in tokens) {
      if (_containsIgnoreCase(next, token)) {
        continue;
      }
      if (widget.maxValues != null && next.length >= widget.maxValues!) {
        break;
      }
      next.add(token);
    }
    return next;
  }

  void _emitNextValues(List<String> nextValues) {
    if (!_isEnabled) {
      return;
    }
    if (_sameValues(nextValues, widget.values)) {
      return;
    }
    widget.onChanged?.call(nextValues);
  }

  bool _sameValues(List<String> a, List<String> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  void _commitCurrentInput() {
    if (!_isEnabled || !widget.allowCustomValues) {
      return;
    }
    final String token = _controller.text.trim();
    if (token.isEmpty) {
      return;
    }
    _emitNextValues(_nextValuesWithTokens(<String>[token]));
    _isProcessingTextChange = true;
    _controller.clear();
    _isProcessingTextChange = false;
    setState(() {});
  }

  void _toggleOption(FadingChipsOption option) {
    if (!_isEnabled) {
      return;
    }
    final List<String> next = List<String>.of(widget.values);
    if (_containsIgnoreCase(next, option.value)) {
      next.removeWhere(
        (String value) =>
            value.trim().toLowerCase() == option.value.trim().toLowerCase(),
      );
    } else {
      if (widget.maxValues != null && next.length >= widget.maxValues!) {
        return;
      }
      next.add(option.value);
    }
    _emitNextValues(next);
  }

  void _removeChip(String value) {
    if (!_isEnabled) {
      return;
    }
    final List<String> next = List<String>.of(widget.values);
    next.remove(value);
    _emitNextValues(next);
  }

  String _labelForValue(String value) {
    for (final FadingChipsOption option in widget.options) {
      if (option.value == value) {
        return option.label;
      }
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);
    final bool isFocused = _focusNode.hasFocus;

    return Opacity(
      opacity: _isEnabled ? 1 : 0.5,
      child: Focus(
        onKeyEvent: _handleKey,
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  ...widget.values.map((String value) {
                    return _SelectedChip(
                      key: ValueKey<String>(_chipKeyForValue(value)),
                      label: _labelForValue(value),
                      onRemove: _isEnabled ? () => _removeChip(value) : null,
                      removeKey: ValueKey<String>(_removeKeyForValue(value)),
                    );
                  }),
                  if (widget.allowCustomValues)
                    _InputChip(
                      key: const ValueKey<String>('fading-chips-input'),
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: _isEnabled,
                      hint: widget.hint,
                      theme: theme,
                      onSubmitted: _commitCurrentInput,
                    ),
                ],
              ),
              if (isFocused) ...<Widget>[
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: theme.accent,
                ),
              ],
              if (widget.options.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.options.map((FadingChipsOption option) {
                    final bool selected = _containsIgnoreCase(
                      widget.values,
                      option.value,
                    );
                    return _OptionChip(
                      key: ValueKey<String>(_optionKeyForLabel(option.label)),
                      label: option.label,
                      selected: selected,
                      enabled: _isEnabled,
                      theme: theme,
                      onTap: () => _toggleOption(option),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final FadingThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.selectionActive.withValues(alpha: 0.28)
              : theme.surfaceRaised,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.bodyMedium.copyWith(
            color: selected ? theme.accentStrong : theme.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SelectedChip extends StatelessWidget {
  const _SelectedChip({
    super.key,
    required this.label,
    required this.onRemove,
    required this.removeKey,
  });

  final String label;
  final VoidCallback? onRemove;
  final ValueKey<String> removeKey;

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.selectionActive,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: theme.bodyMedium.copyWith(color: theme.controlKnob),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            key: removeKey,
            behavior: HitTestBehavior.opaque,
            onTap: onRemove,
            child: SizedBox(
              width: 14,
              height: 14,
              child: Center(
                child: Text(
                  '×',
                  style: theme.labelLarge.copyWith(
                    color: theme.controlKnob,
                    fontSize: 12,
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

class _InputChip extends StatelessWidget {
  const _InputChip({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.hint,
    required this.theme,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final String hint;
  final FadingThemeData theme;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final bool hasText = controller.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.surfaceRaised,
        borderRadius: BorderRadius.circular(999),
      ),
      constraints: const BoxConstraints(minWidth: 130, maxWidth: 220),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          EditableText(
            controller: controller,
            focusNode: focusNode,
            style: theme.bodyMedium.copyWith(
              color: enabled ? theme.textPrimary : theme.textMuted,
            ),
            cursorColor: theme.accent,
            backgroundCursorColor: theme.surfaceRaised,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            autofocus: false,
            readOnly: !enabled,
            enableInteractiveSelection: true,
            maxLines: 1,
            onSubmitted: (_) => onSubmitted(),
            onChanged: (_) {},
            selectionControls: null,
            obscureText: false,
            autocorrect: true,
            enableSuggestions: true,
            expands: false,
            minLines: null,
            textDirection: TextDirection.ltr,
          ),
          if (!hasText)
            IgnorePointer(
              child: Text(
                hint,
                style: theme.bodyMedium.copyWith(color: theme.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

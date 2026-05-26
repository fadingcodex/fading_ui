import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../theme/fading_colors.dart';
import '../theme/fading_theme.dart';
import 'fading_surface.dart';

class FadingTextField extends StatefulWidget {
  const FadingTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  State<FadingTextField> createState() => _FadingTextFieldState();
}

class _FadingTextFieldState extends State<FadingTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final bool _ownsController;
  late final bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_handleChanged);
    _focusNode.addListener(_handleFocusChanged);
  }

  void _handleChanged() {
    widget.onChanged?.call(_controller.text);
    setState(() {});
  }

  void _handleFocusChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChanged);
    _focusNode.removeListener(_handleFocusChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;
    final bool hasText = _controller.text.isNotEmpty;

    return FadingSurface(
      style: FadingSurfaceStyle.inset,
      color: FadingColors.dust,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.label != null) ...<Widget>[
            Text(widget.label!, style: FadingTheme.labelLarge),
            const SizedBox(height: 8),
          ],
          Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                child: EditableText(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: FadingTheme.bodyLarge.copyWith(
                    color: widget.enabled
                        ? FadingColors.starlight
                        : FadingColors.storm,
                  ),
                  cursorColor: FadingColors.amberGlow,
                  backgroundCursorColor: FadingColors.dust,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  autofocus: false,
                  readOnly: !widget.enabled,
                  enableInteractiveSelection: true,
                  maxLines: 1,
                  onChanged: (String _) => setState(() {}),
                  selectionControls: null,
                  obscureText: false,
                  autocorrect: true,
                  enableSuggestions: true,
                  expands: false,
                  minLines: null,
                  textDirection: TextDirection.ltr,
                ),
              ),
              if (!hasText && widget.hint != null)
                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 6,
                    ),
                    child: Text(
                      widget.hint!,
                      style: FadingTheme.bodyMedium.copyWith(
                        color: FadingColors.storm,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (widget.errorText != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              widget.errorText!,
              style: FadingTheme.bodyMedium.copyWith(color: FadingColors.error),
            ),
          ],
          if (isFocused) ...<Widget>[
            const SizedBox(height: 6),
            Container(
              height: 1,
              width: double.infinity,
              color: FadingColors.amberGlow,
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

class FadingRadioOption<T> {
  const FadingRadioOption({required this.value, required this.label});

  final T value;
  final String label;
}

class FadingRadioGroup<T> extends StatelessWidget {
  const FadingRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final List<FadingRadioOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String? label;
  final bool enabled;

  bool get _isEnabled => enabled && onChanged != null;

  @override
  Widget build(BuildContext context) {
    final theme = FadingThemeScope.of(context);

    return Opacity(
      opacity: _isEnabled ? 1 : 0.5,
      child: FadingSurface(
        style: FadingSurfaceStyle.inset,
        color: theme.surfaceInset,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (label != null) ...<Widget>[
              Text(label!, style: theme.labelLarge),
              const SizedBox(height: 8),
            ],
            ...options.map((FadingRadioOption<T> option) {
              final bool selected = option.value == value;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _isEnabled ? () => onChanged?.call(option.value) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: <Widget>[
                      FadingSurface(
                        style: selected
                            ? FadingSurfaceStyle.raised
                            : FadingSurfaceStyle.inset,
                        color: selected
                            ? theme.selectionActive
                            : theme.selectionInactive,
                        padding: const EdgeInsets.all(0),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(999),
                        ),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: selected
                              ? Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: theme.controlKnob,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(option.label, style: theme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../theme/fading_theme_scope.dart';
import 'fading_surface.dart';

class FadingTabBar extends StatelessWidget {
  const FadingTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.enabled = true,
  }) : assert(tabs.length > 0, 'tabs must not be empty');

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
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
        padding: const EdgeInsets.all(6),
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        child: Row(
          children: <Widget>[
            for (var index = 0; index < tabs.length; index++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _isEnabled ? () => onChanged?.call(index) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? theme.selectionActive
                          : Color(0x00000000),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tabs[index],
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium.copyWith(
                        color: selectedIndex == index
                            ? theme.controlKnob
                            : theme.textPrimary,
                        fontWeight: selectedIndex == index
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

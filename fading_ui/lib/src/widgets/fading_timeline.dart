import 'package:flutter/widgets.dart';

import '../theme/fading_theme_data.dart';
import '../theme/fading_theme_scope.dart';

/// An event in a [FadingTimeline].
class FadingTimelineItem {
  const FadingTimelineItem({
    required this.title,
    this.timestamp,
    this.description,
    this.icon,
    this.content,
  });

  final String title;

  /// Caller-formatted time or date, allowing localization without a dependency.
  final String? timestamp;
  final String? description;

  /// A decorative icon that replaces the default dot.
  final IconData? icon;

  /// Additional content, such as a badge, details, or an action.
  final Widget? content;
}

/// A vertical event feed that preserves the supplied item order.
///
/// Requires bounded width. Scrolling and sorting are owned by the caller.
/// An empty list renders no content.
class FadingTimeline extends StatelessWidget {
  const FadingTimeline({super.key, required this.items});

  final List<FadingTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    final FadingThemeData theme = FadingThemeScope.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int index = 0; index < items.length; index++)
          _TimelineRow(
            item: items[index],
            theme: theme,
            first: index == 0,
            last: index == items.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.item,
    required this.theme,
    required this.first,
    required this.last,
  });

  final FadingTimelineItem item;
  final FadingThemeData theme;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Stack(
        children: <Widget>[
          if (!first)
            PositionedDirectional(
              start: 13,
              top: 0,
              width: 2,
              height: 14,
              child: ExcludeSemantics(
                child: ColoredBox(color: theme.border),
              ),
            ),
          if (!last)
            PositionedDirectional(
              start: 13,
              top: 14,
              bottom: 0,
              width: 2,
              child: ExcludeSemantics(
                child: ColoredBox(color: theme.border),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ExcludeSemantics(
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.surfaceRaised,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.accent),
                    ),
                    child: item.icon != null
                        ? Icon(item.icon, size: 16, color: theme.accent)
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.title,
                        style: theme.labelLarge.copyWith(
                          color: theme.textPrimary,
                        ),
                      ),
                      if (item.timestamp != null) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(
                          item.timestamp!,
                          style: theme.bodyMedium.copyWith(
                            color: theme.textMuted,
                          ),
                        ),
                      ],
                      if (item.description != null) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          item.description!,
                          style: theme.bodyMedium.copyWith(
                            color: theme.textPrimary,
                          ),
                        ),
                      ],
                      if (item.content != null) ...<Widget>[
                        const SizedBox(height: 8),
                        item.content!,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class UnreadMessagesMarker extends StatelessWidget {
  final int? unreadCount;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Key? markerKey;

  const UnreadMessagesMarker({
    super.key,
    this.unreadCount,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.markerKey,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final Color lineColor = colors.outlineVariant.withOpacity(0.6);
    final Color pillBackground = theme.brightness == Brightness.dark
        ? colors.surfaceContainerHigh
        : colors.surface;
    final Color pillBorder = colors.outlineVariant.withOpacity(0.7);
    final Color textColor = colors.onSurfaceVariant;

    // i18n: берём строку из slang
    final String label = unreadCount == 0
        ? context.t.unreadMarker.label
        : context.t.unreadMarker.labelWithCount(count: unreadCount!);

    return Semantics(
      label: context.t.unreadMarker.a11yLabel,
      container: true,
      child: Padding(
        padding: margin,
        child: Row(
          children: [
            Expanded(child: _SeparatorLine(color: lineColor)),
            const SizedBox(width: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: pillBackground,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: pillBorder),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [colors.primary.withOpacity(0.06), colors.secondary.withOpacity(0.06)],
                ),
              ),
              child: Padding(
                key: markerKey ?? const Key('unread-messages-marker'),
                padding: padding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mark_chat_unread_rounded, size: 18, color: textColor),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _SeparatorLine(color: lineColor)),
          ],
        ),
      ),
    );
  }
}

class _SeparatorLine extends StatelessWidget {
  final Color color;
  const _SeparatorLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: color);
  }
}

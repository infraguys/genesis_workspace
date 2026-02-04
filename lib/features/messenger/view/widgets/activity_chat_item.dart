import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';

class ActivityChatItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget icon;
  final Color color;
  final int unreadCount;
  final bool isMuted;
  const ActivityChatItem({
    super.key,
    required this.title,
    required this.onTap,
    required this.icon,
    required this.color,
    this.unreadCount = 0,
    this.isMuted = false,
  });

  static const BorderRadius materialBorderRadius = BorderRadius.all(Radius.circular(8));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColors = theme.extension<CardColors>()!;
    return Material(
      borderRadius: materialBorderRadius,
      animationDuration: const Duration(milliseconds: 200),
      animateColor: true,
      color: cardColors.base,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered) ? cardColors.active : null,
        ),
        child: Padding(
          padding: EdgeInsetsGeometry.all(8),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Row(
                spacing: 12,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                    child: icon,
                  ),
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              UnreadBadge(
                count: unreadCount,
                isMuted: isMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

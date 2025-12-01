import 'package:flutter/material.dart';

class MessageTime extends StatelessWidget {
  final Widget messageTime;
  final bool isMyMessage;
  final bool isRead;
  final bool isSkeleton;
  const MessageTime({
    super.key,
    required this.messageTime,
    required this.isMyMessage,
    required this.isRead,
    required this.isSkeleton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12,
        ),
        messageTime,
        if (!isMyMessage && !isRead && !isSkeleton) ...[
          const SizedBox(width: 4),
          Icon(Icons.circle, color: theme.colorScheme.primary, size: 8),
        ],
      ],
    );
  }
}

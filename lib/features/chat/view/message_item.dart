import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';

class MessageItem extends StatelessWidget {
  final bool isMyMessage;
  final MessageEntity message;
  const MessageItem({super.key, required this.isMyMessage, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = message.flags?.contains('read') ?? false;

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Row(
          mainAxisSize: MainAxisSize.min, // ← ключевая строка
          mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMyMessage) ...[
              UserAvatar(avatarUrl: message.avatarUrl),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: isMyMessage
                      ? theme.colorScheme.secondaryContainer.withAlpha(128)
                      : theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    currentSize(context) <= ScreenSize.tablet
                        ? Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(message.senderFullName, style: theme.textTheme.labelSmall),
                                const SizedBox(height: 2),
                                Text(
                                  message.content,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(message.senderFullName, style: theme.textTheme.labelSmall),
                              const SizedBox(height: 2),
                              Text(message.content, softWrap: true, overflow: TextOverflow.visible),
                            ],
                          ),
                    (isRead || isMyMessage)
                        ? SizedBox()
                        : Icon(Icons.circle, color: theme.colorScheme.primary, size: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

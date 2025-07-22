import 'package:flutter/material.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/features/home/view/user_avatar.dart';

class MessageItem extends StatelessWidget {
  final bool isMyMessage;
  final MessageEntity message;
  const MessageItem({super.key, required this.isMyMessage, required this.message});

  @override
  Widget build(BuildContext context) {
    bool isRead = message.flags?.contains('read') ?? false;
    final theme = Theme.of(context);
    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Stack(
          // fit: StackFit.expand,
          children: [
            Row(
              mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMyMessage) UserAvatar(avatarUrl: message.avatarUrl),
                if (!isMyMessage) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isMyMessage
                          ? theme.colorScheme.secondaryContainer.withAlpha(128)
                          : theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message.senderFullName, style: theme.textTheme.labelSmall),
                        const SizedBox(height: 2),
                        Text(message.content, softWrap: true, overflow: TextOverflow.visible),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: isRead
                  ? Icon(Icons.done_all, color: theme.colorScheme.primary, size: 12)
                  : Icon(Icons.check, color: Colors.blueGrey, size: 12),
            ),
          ],
        ),
      ),
    );
  }
}

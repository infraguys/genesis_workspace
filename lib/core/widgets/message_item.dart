import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MessageItem extends StatelessWidget {
  final bool isMyMessage;
  final MessageEntity message;
  final bool isSkeleton;
  final bool showTopic;

  const MessageItem({
    super.key,
    required this.isMyMessage,
    required this.message,
    this.isSkeleton = false,
    this.showTopic = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = message.flags?.contains('read') ?? false;

    final avatar = isSkeleton
        ? const CircleAvatar(radius: 20) // Skeleton avatar
        : UserAvatar(avatarUrl: message.avatarUrl);

    final senderName = isSkeleton
        ? Container(height: 10, width: 80, color: theme.colorScheme.surfaceVariant)
        : Text(message.senderFullName, style: theme.textTheme.titleSmall);

    final messageContent = isSkeleton
        ? Container(height: 14, width: 150, color: theme.colorScheme.surfaceVariant)
        : SelectableText(
            message.content,
            contextMenuBuilder: (context, editableTextState) {
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: editableTextState.contextMenuAnchors,
                buttonItems: [
                  ContextMenuButtonItem(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: message.content));
                      ContextMenuController.removeAny();
                    },
                    label: context.t.copy,
                  ),
                ],
              );
            },
          );

    return Skeletonizer(
      enabled: isSkeleton,
      child: Align(
        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMyMessage) ...[avatar, const SizedBox(width: 8)],
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                senderName,
                                if (showTopic)
                                  Skeleton.ignore(
                                    child: Row(
                                      children: [
                                        Icon(Icons.arrow_right, size: 16),
                                        Text(message.subject, style: theme.textTheme.labelSmall),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            messageContent,
                          ],
                        ),
                      ),
                      (isRead || isMyMessage || isSkeleton)
                          ? const SizedBox()
                          : Icon(Icons.circle, color: theme.colorScheme.primary, size: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

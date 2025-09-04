import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/widgets/message/message_html.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MessageBody extends StatelessWidget {
  final bool showSenderName;
  final bool isSkeleton;
  final MessageEntity message;
  final bool showTopic;
  final bool isStarred;
  final GlobalKey<CustomPopupState> actionsPopupKey;
  final double maxMessageWidth;
  const MessageBody({
    super.key,
    required this.showSenderName,
    required this.isSkeleton,
    required this.message,
    required this.showTopic,
    required this.isStarred,
    required this.actionsPopupKey,
    required this.maxMessageWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showSenderName)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  isSkeleton
                      ? Container(
                          height: 10,
                          width: 80,
                          color: theme.colorScheme.surfaceContainerHighest,
                        )
                      : Text(message.senderFullName, style: theme.textTheme.titleSmall),
                  if (showTopic && message.subject.isNotEmpty)
                    Skeleton.ignore(
                      child: Row(
                        children: [
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_right, size: 16),
                          Text(message.subject, style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ),
                ],
              ),
              if (currentSize(context) > ScreenSize.tablet) ...[
                SizedBox(width: 4),
                _MessageActions(
                  isStarred: isStarred,
                  messageId: message.id,
                  actionsPopupKey: actionsPopupKey,
                ),
              ],
            ],
          ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicWidth(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxMessageWidth, minWidth: 30),
                child: isSkeleton
                    ? Container(
                        height: 14,
                        width: 150,
                        color: theme.colorScheme.surfaceContainerHighest,
                      )
                    : MessageHtml(content: message.content),
              ),
            ),
            if (currentSize(context) > ScreenSize.tablet && !showSenderName)
              _MessageActions(
                isStarred: isStarred,
                messageId: message.id,
                actionsPopupKey: actionsPopupKey,
              ),
          ],
        ),
      ],
    );
  }
}

class _MessageActions extends StatelessWidget {
  final bool isStarred;
  final int messageId;
  final GlobalKey<CustomPopupState> actionsPopupKey;
  const _MessageActions({
    super.key,
    required this.isStarred,
    required this.messageId,
    required this.actionsPopupKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () async {
              actionsPopupKey.currentState?.show();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(Icons.menu, color: theme.unselectedWidgetColor, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

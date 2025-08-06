import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fwfh_cached_network_image/fwfh_cached_network_image.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/widgets/authorized_image.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum MessageUIOrder { first, last, middle, single, lastSingle }

class MessageItem extends StatelessWidget {
  final bool isMyMessage;
  final MessageEntity message;
  final bool isSkeleton;
  final bool showTopic;
  final MessageUIOrder messageOrder;

  const MessageItem({
    super.key,
    required this.isMyMessage,
    required this.message,
    this.isSkeleton = false,
    this.showTopic = false,
    this.messageOrder = MessageUIOrder.middle,
  });

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = message.flags?.contains('read') ?? false;

    final avatar = isSkeleton
        ? const CircleAvatar(radius: 20)
        : UserAvatar(avatarUrl: message.avatarUrl);

    final senderName = isSkeleton
        ? Container(height: 10, width: 80, color: theme.colorScheme.surfaceContainerHighest)
        : Text(message.senderFullName, style: theme.textTheme.titleSmall);

    final messageContent = isSkeleton
        ? Container(height: 14, width: 150, color: theme.colorScheme.surfaceContainerHighest)
        : HtmlWidget(
            message.content,
            factoryBuilder: () => MyWidgetFactory(),
            customStylesBuilder: (element) {
              if (element.classes.contains('user-mention')) {
                return {'font-weight': '600'};
              }
              return null;
            },
            customWidgetBuilder: (element) {
              if (element.attributes.containsValue('image/png')) {
                return AuthorizedImage(url: '${AppConstants.baseUrl}${element.attributes['src']}');
              }
              if (element.classes.contains('emoji')) {
                inspect(element);
              }
              return null;
            },
            onTapUrl: (String? url) async {
              print(url);
              return true;
            },
          );
    // : SelectableText(
    //     message.content,
    //     contextMenuBuilder: (context, editableTextState) {
    //       return AdaptiveTextSelectionToolbar.buttonItems(
    //         anchors: editableTextState.contextMenuAnchors,
    //         buttonItems: [
    //           ContextMenuButtonItem(
    //             onPressed: () {
    //               Clipboard.setData(ClipboardData(text: message.content));
    //               ContextMenuController.removeAny();
    //             },
    //             label: context.t.copy,
    //           ),
    //         ],
    //       );
    //     },
    //   );

    final messageTime = isSkeleton
        ? Container(height: 10, width: 30, color: theme.colorScheme.surfaceContainerHighest)
        : Text(
            _formatTime(message.timestamp),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          );

    BorderRadius? messageRadius;

    if (isMyMessage) {
      switch (messageOrder) {
        case MessageUIOrder.last:
          messageRadius = BorderRadius.only(
            topLeft: Radius.zero,
            topRight: Radius.zero,
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.zero,
          );
        case MessageUIOrder.first:
          messageRadius = BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          );
        case MessageUIOrder.single || MessageUIOrder.lastSingle:
          messageRadius = BorderRadius.circular(12).copyWith(bottomRight: Radius.zero);
        case MessageUIOrder.middle:
          messageRadius = BorderRadius.zero;
      }
    } else {
      switch (messageOrder) {
        case MessageUIOrder.last:
          messageRadius = BorderRadius.only(
            topLeft: Radius.zero,
            topRight: Radius.zero,
            bottomLeft: Radius.zero,
            bottomRight: Radius.circular(12),
          );
        case MessageUIOrder.first:
          messageRadius = BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          );
        case MessageUIOrder.single || MessageUIOrder.lastSingle:
          messageRadius = BorderRadius.circular(12).copyWith(bottomLeft: Radius.zero);
        case MessageUIOrder.middle:
          messageRadius = BorderRadius.zero;
      }
    }

    final bool showAvatar =
        !isMyMessage &&
        (messageOrder == MessageUIOrder.last ||
            messageOrder == MessageUIOrder.single ||
            messageOrder == MessageUIOrder.lastSingle);
    final bool showSenderName =
        messageOrder == MessageUIOrder.first ||
        messageOrder == MessageUIOrder.single ||
        messageOrder == MessageUIOrder.lastSingle;

    return Skeletonizer(
      enabled: isSkeleton,
      child: Align(
        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.of(context).size.width * 0.9) - (isMyMessage ? 30 : 0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (showAvatar) ...[avatar, const SizedBox(width: 4)],
              if (!showAvatar) SizedBox(width: 44),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  constraints: (showAvatar) ? BoxConstraints(minHeight: 40) : null,
                  decoration: BoxDecoration(
                    color: isMyMessage
                        ? theme.colorScheme.secondaryContainer.withAlpha(128)
                        : theme.colorScheme.secondaryContainer,
                    borderRadius: messageRadius,
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
                            if (showSenderName)
                              Row(
                                children: [
                                  senderName,
                                  if (showTopic && message.subject.isNotEmpty)
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          messageTime,
                          const SizedBox(height: 2),
                          (isRead || isMyMessage || isSkeleton)
                              ? const SizedBox()
                              : Icon(Icons.circle, color: theme.colorScheme.primary, size: 8),
                        ],
                      ),
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

class MyWidgetFactory extends WidgetFactory with CachedNetworkImageFactory {}

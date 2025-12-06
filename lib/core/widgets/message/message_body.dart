import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/message/message_html.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MessageBody extends StatelessWidget {
  final bool showSenderName;
  final bool isSkeleton;
  final MessageEntity message;
  final bool showTopic;
  final bool isStarred;
  final double maxMessageWidth;
  const MessageBody({
    super.key,
    required this.showSenderName,
    required this.isSkeleton,
    required this.message,
    required this.showTopic,
    required this.isStarred,
    required this.maxMessageWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messageColors = Theme.of(context).extension<MessageColors>()!;
    final textColors = Theme.of(context).extension<TextColors>()!;
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
                      : Text(
                          message.senderFullName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: messageColors.senderNameColor,
                          ),
                        ),
                  if (showTopic && message.subject.isNotEmpty)
                    Skeleton.ignore(
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Container(
                            width: 3,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadiusGeometry.circular(14),
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            '# ${message.subject}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: textColors.text30,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              // if (currentSize(context) > ScreenSize.tablet) ...[
              //   SizedBox(width: 4),
              //   _MessageActions(
              //     isStarred: isStarred,
              //     messageId: message.id,
              //   ),
              // ],
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
            // if (currentSize(context) > ScreenSize.tablet && !showSenderName)
            //   _MessageActions(
            //     isStarred: isStarred,
            //     messageId: message.id,
            //   ),
          ],
        ),
      ],
    );
  }
}

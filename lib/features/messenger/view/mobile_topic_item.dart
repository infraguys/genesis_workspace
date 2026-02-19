import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/message_preview.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MobileTopicItem extends StatelessWidget {
  MobileTopicItem({
    super.key,
    required this.selectedChat,
    required this.topic,
  });

  final ChatEntity selectedChat;
  final TopicEntity topic;

  final GlobalKey<CustomPopupState> popupKey = GlobalKey<CustomPopupState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;

    return CustomPopup(
      key: popupKey,
      backgroundColor: theme.colorScheme.surfaceDim,
      arrowColor: theme.colorScheme.surfaceDim,
      rootNavigator: true,
      isLongPress: true,
      contentDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceDim,
        borderRadius: .circular(12),
        boxShadow: kElevationToShadow[3],
      ),
      content: Container(
        width: 240,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: .circular(12),
        ),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          spacing: 4,
          children: [
            TextButton(
              child: Text(
                context.t.readAllMessages,
                textAlign: .center,
              ),
              onPressed: () async {
                context.pop();
                await context.read<MessengerCubit>().readAllMessages(
                  selectedChat.id,
                  topicName: topic.name,
                );
              },
            ),
          ],
        ),
      ),
      child: Padding(
        padding: .only(left: 38),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.pushNamed(
                Routes.channelChatTopic,
                pathParameters: {
                  'chatId': selectedChat.id.toString(),
                  'channelId': selectedChat.streamId.toString(),
                  'topicName': topic.name,
                },
                extra: {'messageId': topic.firstUnreadMessageId},
              );
            },
            child: Ink(
              height: 76,
              child: Row(
                crossAxisAlignment: .end,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: .center,
                      children: [
                        Container(
                          width: 3,
                          height: 47,
                          decoration: BoxDecoration(
                            color: selectedChat.backgroundColor,
                            borderRadius: .circular(4),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: .center,
                            crossAxisAlignment: .start,
                            children: [
                              Tooltip(
                                message: topic.name,
                                child: Text(
                                  "# ${topic.name}",
                                  maxLines: 1,
                                  overflow: .ellipsis,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontSize: 14,
                                    color: textColors.text100,
                                  ),
                                ),
                              ),
                              Text(
                                topic.lastMessageSenderName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              MessagePreview(
                                messagePreview: topic.lastMessagePreview,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const .all(12.0),
                    child: Skeleton.ignore(
                      child: SizedBox(
                        height: 21,
                        child: UnreadBadge(
                          count: topic.unreadMessages.length,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

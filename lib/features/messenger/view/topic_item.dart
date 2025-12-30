import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/message_preview.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TopicItem extends StatelessWidget {
  final ChatEntity chat;
  final TopicEntity topic;
  final GlobalKey<CustomPopupState> popupKey = GlobalKey<CustomPopupState>();

  TopicItem({super.key, required this.chat, required this.topic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColors = theme.extension<CardColors>()!;
    final textColors = theme.extension<TextColors>()!;
    return CustomPopup(
      key: popupKey,
      backgroundColor: theme.colorScheme.surfaceDim,
      arrowColor: theme.colorScheme.surfaceDim,
      rootNavigator: true,
      isLongPress: currentSize(context) <= .tablet,
      contentDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceDim,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kElevationToShadow[3],
      ),
      content: Container(
        width: 240,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            TextButton(
              child: Text(
                context.t.readAllMessages,
                textAlign: TextAlign.center,
              ),
              onPressed: () async {
                context.pop();
                await context.read<MessengerCubit>().readAllMessagesInTopic(
                  streamId: chat.streamId!,
                  topicName: topic.name,
                );
              },
            ),
          ],
        ),
      ),
      child: InkWell(
        onSecondaryTap: () {
          popupKey.currentState?.show();
        },
        onTap: () {
          context.read<MessengerCubit>().selectChat(
            chat,
            selectedTopic: topic.name,
          );
        },
        child: BlocBuilder<MessengerCubit, MessengerState>(
          builder: (context, state) {
            final isSelected = topic.name == state.selectedTopic;
            return Container(
              height: 76,
              padding: EdgeInsetsGeometry.only(left: 38, right: 8, bottom: 12),
              decoration: BoxDecoration(
                color: isSelected ? cardColors.active : cardColors.base,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 3,
                          height: 47,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadiusGeometry.circular(4),
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Tooltip(
                                message: topic.name,
                                child: Text(
                                  "# ${topic.name}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                  Skeleton.ignore(
                    child: SizedBox(
                      height: 21,
                      child: UnreadBadge(
                        count: topic.unreadMessages.length,
                        isMuted: chat.isMuted,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

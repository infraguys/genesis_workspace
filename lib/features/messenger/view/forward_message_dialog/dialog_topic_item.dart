part of './forward_message_dialog.dart';

class _DialogTopicItem extends StatelessWidget {
  const _DialogTopicItem({
    super.key, // ignore: unused_element_parameter
    required this.chat,
    required this.topic,
    required this.messageId,
    this.quote,
  });

  final ChatEntity chat;
  final TopicEntity topic;
  final int messageId;
  final String? quote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColors = theme.extension<CardColors>()!;
    final textColors = theme.extension<TextColors>()!;
    return InkWell(
      onTap: () async {
        final router = GoRouter.of(context);
        final messagesCubit = context.read<MessagesCubit>();
        final channelChatCubit = context.read<ChannelChatCubit>();
        final messengerCubit = context.read<MessengerCubit>();
        try {
          final message = await messagesCubit.getMessageById(
            messageId: messageId,
            applyMarkdown: false,
          );
          channelChatCubit.sendMessage(
            streamId: chat.streamId!,
            topic: topic.name,
            content: message.makeForwardedContent(quote: quote),
          );
          if (context.mounted) {
            messengerCubit.selectChat(chat, selectedTopic: topic.name);
          }
        } on DioException catch (e) {
          if (context.mounted) {
            showErrorSnackBar(context, exception: e);
          }
        }
        router.pop();
      },
      child: BlocBuilder<MessengerCubit, MessengerState>(
        builder: (context, state) {
          return Container(
            height: 76,
            padding: EdgeInsetsGeometry.only(left: 38, right: 8, bottom: 12),
            decoration: BoxDecoration(color: cardColors.base),
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
                          color: chat.backgroundColor ?? AppColors.primary,
                          borderRadius: .circular(4),
                        ),
                      ),
                      SizedBox(width: 12.0),
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
                            MessagePreview(messagePreview: topic.lastMessagePreview),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Skeleton.ignore(
                  child: SizedBox(
                    height: 21,
                    child: UnreadBadge(count: topic.unreadMessages.length, isMuted: chat.isMuted),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

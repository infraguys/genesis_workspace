import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/message_preview.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatTopicsList extends StatefulWidget {
  final bool showTopics;
  final bool isPending;
  final ChatEntity? selectedChat;
  const ChatTopicsList({super.key, required this.showTopics, required this.isPending, this.selectedChat});

  @override
  State<ChatTopicsList> createState() => _ChatTopicsListState();
}

class _ChatTopicsListState extends State<ChatTopicsList> {
  late final ScrollController _topicsController;

  @override
  void initState() {
    _topicsController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _topicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    return Positioned(
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(color: theme.colorScheme.background),
        constraints: BoxConstraints(
          maxWidth: widget.showTopics ? MediaQuery.sizeOf(context).width - 70 : 0,
        ),
        child: Skeletonizer(
          enabled: widget.isPending,
          child: widget.selectedChat == null
              ? SizedBox.shrink()
              : ListView.builder(
                  controller: _topicsController,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: widget.selectedChat!.isTopicsLoading ? 4 : widget.selectedChat!.topics!.length,
                  itemBuilder: (BuildContext context, int index) {
                    final topic = widget.selectedChat?.topics?[index] ?? TopicEntity.fake();
                    return InkWell(
                      onTap: () {
                        context.read<MessengerCubit>().selectChat(
                          widget.selectedChat!,
                          selectedTopic: topic.name,
                        );
                      },
                      child: Container(
                        height: 76,
                        padding: EdgeInsetsGeometry.only(
                          left: 38,
                          right: 8,
                          bottom: 12,
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
                                      borderRadius: BorderRadiusGeometry.circular(
                                        4,
                                      ),
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
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

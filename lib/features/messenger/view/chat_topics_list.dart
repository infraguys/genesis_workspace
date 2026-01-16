import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/features/messenger/view/mobile_topic_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatTopicsList extends StatefulWidget {
  final bool showTopics;
  final bool isPending;
  final ChatEntity? selectedChat;
  final double listPadding;
  const ChatTopicsList({
    super.key,
    required this.showTopics,
    required this.isPending,
    this.selectedChat,
    required this.listPadding,
  });

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
        height: MediaQuery.sizeOf(context).height,
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
                  shrinkWrap: true,
                  padding: EdgeInsets.only(bottom: widget.listPadding),
                  itemCount: widget.selectedChat!.isTopicsLoading ? 4 : widget.selectedChat!.topics!.length,
                  itemBuilder: (BuildContext context, int index) {
                    final topic = widget.selectedChat?.topics?[index] ?? TopicEntity.fake();
                    return MobileTopicItem(selectedChat: widget.selectedChat!, topic: topic);
                  },
                ),
        ),
      ),
    );
  }
}

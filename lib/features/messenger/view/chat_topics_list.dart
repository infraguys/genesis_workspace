import 'package:flutter/material.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/features/messenger/view/mobile_topic_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatTopicsList extends StatefulWidget {
  const ChatTopicsList({
    super.key,
    required this.isPending,
    this.selectedChat,
    required this.listPadding,
    required this.onDismissed,
  });

  final bool isPending;
  final ChatEntity? selectedChat;
  final double listPadding;
  final VoidCallback onDismissed;

  @override
  State<ChatTopicsList> createState() => _ChatTopicsListState();
}

class _ChatTopicsListState extends State<ChatTopicsList> {
  late final ScrollController _topicsController;

  List<TopicEntity> get sortedTopics {
    final topics = widget.selectedChat?.topics ?? const [];
    final list = List<TopicEntity>.of(topics)..sort((a, b) => b.maxId.compareTo(a.maxId));
    return list;
  }

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
    final sizeOf = MediaQuery.sizeOf(context);

    return Dismissible(
      key: const ValueKey('topics_list'),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => widget.onDismissed(),
      child: SizedBox(
        width: sizeOf.width - 70,
        height: sizeOf.height,
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.colorScheme.background),
          child: Skeletonizer(
            enabled: widget.isPending,
            child: widget.selectedChat == null
                ? SizedBox.shrink()
                : ListView.builder(
                    controller: _topicsController,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(bottom: widget.listPadding),
                    itemCount: widget.selectedChat!.isTopicsLoading ? 4 : sortedTopics.length,
                    itemBuilder: (context, index) {
                      final topic = sortedTopics.isEmpty ? TopicEntity.fake() : sortedTopics[index];
                      return MobileTopicItem(selectedChat: widget.selectedChat!, topic: topic);
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

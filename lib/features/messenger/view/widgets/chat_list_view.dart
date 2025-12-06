import 'package:flutter/material.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/features/messenger/view/chat_item.dart';

class MessengerChatListView extends StatelessWidget {
  const MessengerChatListView({
    super.key,
    required this.chats,
    required this.padding,
    required this.controller,
    required this.showTopics,
    required this.selectedChatId,
    required this.onTap,
  });

  final List<ChatEntity> chats;
  final EdgeInsets padding;
  final ScrollController controller;
  final bool showTopics;
  final int? selectedChatId;
  final void Function(ChatEntity chat) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: chats.length,
      separatorBuilder: (_, __) => SizedBox(height: 4),
      controller: controller,
      itemBuilder: (BuildContext context, int index) {
        final chat = chats[index];
        return ChatItem(
          key: ValueKey(chat.id),
          chat: chat,
          selectedChatId: selectedChatId,
          showTopics: showTopics,
          onTap: () => onTap(chat),
        );
      },
    );
  }
}

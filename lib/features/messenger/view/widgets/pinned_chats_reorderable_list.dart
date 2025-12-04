import 'package:flutter/material.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/features/messenger/view/chat_reorder_item.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';

class PinnedChatsReorderableList extends StatelessWidget {
  const PinnedChatsReorderableList({
    super.key,
    required this.pinnedChats,
    required this.pinnedMeta,
    required this.padding,
    required this.absorbing,
    required this.onReorderCalculated,
    this.onReorderStart,
  });

  final List<ChatEntity> pinnedChats;
  final List<PinnedChatEntity> pinnedMeta;
  final EdgeInsets padding;
  final bool absorbing;
  final VoidCallback? onReorderStart;
  final void Function(List<ChatEntity> reorderedChats, List<PinnedChatOrderUpdate> updates) onReorderCalculated;

  void _handleReorder(int oldIndex, int newIndex) {
    onReorderStart?.call();
    int adjustedNewIndex = newIndex;
    if (adjustedNewIndex > oldIndex) adjustedNewIndex -= 1;
    final List<ChatEntity> local = List<ChatEntity>.from(pinnedChats);
    final ChatEntity moved = local.removeAt(oldIndex);
    local.insert(adjustedNewIndex, moved);

    final updates = _buildPinnedOrderUpdates(local, pinnedMeta);
    onReorderCalculated(local, updates);
  }

  List<PinnedChatOrderUpdate> _buildPinnedOrderUpdates(
    List<ChatEntity> orderedChats,
    List<PinnedChatEntity> pinnedMeta,
  ) {
    if (orderedChats.isEmpty || pinnedMeta.isEmpty) return [];
    final Map<int, PinnedChatEntity> pinnedByChatId = {
      for (final pinned in pinnedMeta) pinned.chatId: pinned,
    };
    final List<PinnedChatOrderUpdate> updates = [];
    for (int index = 0; index < orderedChats.length; index++) {
      final chat = orderedChats[index];
      final pinned = pinnedByChatId[chat.id];
      if (pinned == null) continue;
      updates.add(
        PinnedChatOrderUpdate(
          folderItemUuid: pinned.folderItemUuid,
          orderIndex: index,
        ),
      );
    }
    return updates;
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: absorbing,
      child: ReorderableListView.builder(
        padding: padding,
        itemCount: pinnedChats.length,
        buildDefaultDragHandles: false,
        onReorder: _handleReorder,
        proxyDecorator: (child, index, animation) {
          return Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final chat = pinnedChats[index];
          return KeyedSubtree(
            key: ValueKey('pinned-chat-${chat.id}'),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: index == pinnedChats.length - 1 ? 0 : 4,
              ),
              child: ChatReorderItem(
                chat: chat,
                index: index,
              ),
            ),
          );
        },
      ),
    );
  }
}

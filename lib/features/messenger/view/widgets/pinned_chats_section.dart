import 'package:flutter/material.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/messenger/entities/pinned_chat_order_update.dart';
import 'package:genesis_workspace/features/messenger/view/widgets/chat_list_view.dart';
import 'package:genesis_workspace/features/messenger/view/widgets/pinned_chats_reorderable_list.dart';

class PinnedChatsSection extends StatefulWidget {
  const PinnedChatsSection({
    super.key,
    required this.visibleChats,
    required this.pinnedMeta,
    required this.listPadding,
    required this.chatsController,
    required this.selectedChatId,
    required this.showTopics,
    required this.onChatTap,
    required this.onPinningSaved,
    required this.folderUuid,
    required this.isEditPinning,
  });

  final List<ChatEntity> visibleChats;
  final List<PinnedChatEntity> pinnedMeta;
  final EdgeInsets listPadding;
  final ScrollController chatsController;
  final int? selectedChatId;
  final bool showTopics;
  final void Function(ChatEntity chat) onChatTap;
  final Function(List<PinnedChatOrderUpdate> chats) onPinningSaved;
  final String? folderUuid;
  final bool isEditPinning;

  @override
  State<PinnedChatsSection> createState() => PinnedChatsSectionState();
}

class PinnedChatsSectionState extends State<PinnedChatsSection> {
  List<ChatEntity>? _optimisticPinnedChats;
  List<PinnedChatOrderUpdate> _pendingPinnedOrders = [];
  bool _isPinnedReorderInProgress = false;
  bool _isSavingPinnedOrder = false;

  List<ChatEntity> _pinnedChatsForEdit(List<ChatEntity> chats, List<PinnedChatEntity> pinnedMeta) {
    if (pinnedMeta.isEmpty) {
      return chats.where((chat) => chat.isPinned).toList();
    }
    final Map<int, PinnedChatEntity> pinnedByChatId = {
      for (final pinned in pinnedMeta) pinned.chatId: pinned,
    };

    int comparePinnedMeta(PinnedChatEntity? a, PinnedChatEntity? b) {
      final bool aPinned = a != null;
      final bool bPinned = b != null;
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      if (!aPinned && !bPinned) return 0;

      final int? aOrder = a?.orderIndex;
      final int? bOrder = b?.orderIndex;

      if (aOrder != null && bOrder != null && aOrder != bOrder) {
        return aOrder.compareTo(bOrder);
      }
      if (aOrder != null && bOrder == null) return -1;
      if (aOrder == null && bOrder != null) return 1;

      final DateTime aUpdatedAt = a?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bUpdatedAt = b?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bUpdatedAt.compareTo(aUpdatedAt);
    }

    final List<ChatEntity> pinnedChats = chats.where((chat) => pinnedByChatId.containsKey(chat.id)).toList()
      ..sort((a, b) => comparePinnedMeta(pinnedByChatId[a.id], pinnedByChatId[b.id]));
    return pinnedChats;
  }

  void cancelEditing() {
    _setSaving(false);
    setState(() {
      _optimisticPinnedChats = null;
      _pendingPinnedOrders = [];
      _isPinnedReorderInProgress = false;
      _isSavingPinnedOrder = false;
    });
  }

  void _setSaving(bool value) {
    _isSavingPinnedOrder = value;
    if (value == false) {
      widget.onPinningSaved(_pendingPinnedOrders);
    }
  }

  @override
  void didUpdateWidget(covariant PinnedChatsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.folderUuid != widget.folderUuid) {
      cancelEditing();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinnedChatsForEdit = _optimisticPinnedChats ?? _pinnedChatsForEdit(widget.visibleChats, widget.pinnedMeta);

    if (widget.isEditPinning) {
      return PinnedChatsReorderableList(
        pinnedChats: pinnedChatsForEdit,
        pinnedMeta: widget.pinnedMeta,
        padding: widget.listPadding,
        absorbing: _isPinnedReorderInProgress || _isSavingPinnedOrder,
        onReorderStart: () => setState(() {
          _isPinnedReorderInProgress = true;
        }),
        onReorderCalculated: (reorderedChats, updates) {
          if (!mounted) return;
          setState(() {
            _optimisticPinnedChats = reorderedChats;
            _pendingPinnedOrders = updates;
            _isPinnedReorderInProgress = false;
          });
          widget.onPinningSaved(updates);
        },
      );
    }

    return MessengerChatListView(
      chats: widget.visibleChats,
      padding: widget.listPadding,
      controller: widget.chatsController,
      showTopics: widget.showTopics,
      selectedChatId: widget.selectedChatId,
      onTap: widget.onChatTap,
    );
  }
}

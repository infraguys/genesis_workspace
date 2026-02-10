import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/mixins/chat/open_chat_mixin.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/info_panel/info_panel_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/chat_item.dart';

class MessengerChatListView extends StatelessWidget with OpenChatMixin {
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

  static const BorderRadius materialBorderRadius = BorderRadius.all(Radius.circular(8));

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: chats.length,
      separatorBuilder: (_, index) {
        return const SizedBox(height: 4);
      },
      controller: controller,
      itemBuilder: (BuildContext context, int index) {
        final chatIndex = index;
        final chat = chats[chatIndex];
        return ChatItem(
          key: ValueKey(chat.id),
          chat: chat,
          selectedChatId: selectedChatId,
          showTopics: showTopics,
          onTap: () {
            onTap(chat);
            final currentStatus = context.read<InfoPanelCubit>().state.status;
            if (currentStatus != .closed) {
              switch (chat.type) {
                case .channel:
                  context.read<InfoPanelCubit>().setInfoPanelState(.channelInfo);
                  break;
                case .direct || .groupDirect:
                  context.read<InfoPanelCubit>().setInfoPanelState(.dmInfo);
                  break;
              }
            }
          },
        );
      },
    );
  }
}

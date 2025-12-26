import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/info_panel/info_panel_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/widgets/chat_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MessengerChatListView extends StatelessWidget {
  const MessengerChatListView({
    super.key,
    required this.chats,
    required this.padding,
    required this.controller,
    required this.showTopics,
    required this.selectedChatId,
    required this.onTap,
    required this.isPending,
  });

  final List<ChatEntity> chats;
  final bool isPending;
  final EdgeInsets padding;
  final ScrollController controller;
  final bool showTopics;
  final int? selectedChatId;
  final void Function(ChatEntity chat) onTap;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isPending,
      child: ListView.separated(
        padding: padding,
        itemCount: isPending ? 15 : chats.length,
        separatorBuilder: (_, _) => SizedBox(height: 4),
        controller: controller,
        itemBuilder: (BuildContext context, int index) {
          if (isPending) {
            return ChatItem(
              chat: ChatEntity.fake(),
              onTap: () {},
              showTopics: false,
            );
          } else {
            final chat = chats[index];
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
          }
        },
      ),
    );
  }
}

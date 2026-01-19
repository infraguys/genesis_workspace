import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/info_panel_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/chat_item.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';

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

  static const int headerItemsCount = 1;
  static const BorderRadius materialBorderRadius = BorderRadius.all(Radius.circular(8));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColors = theme.extension<CardColors>()!;
    return ListView.separated(
      padding: padding,
      itemCount: chats.length + headerItemsCount,
      separatorBuilder: (_, index) {
        if (index == headerItemsCount - 1) {
          return Column(
            children: [
              Divider(
                color: theme.dividerColor,
              ),
            ],
          );
        }
        return const SizedBox(height: 4);
      },
      controller: controller,
      itemBuilder: (BuildContext context, int index) {
        if (index < headerItemsCount) {
          switch (index) {
            case 0:
              return Material(
                borderRadius: materialBorderRadius,
                animationDuration: const Duration(milliseconds: 200),
                animateColor: true,
                color: cardColors.base,
                child: InkWell(
                  onTap: () {
                    context.read<MessengerCubit>().openStarredMessages();
                  },
                  borderRadius: BorderRadius.circular(8),
                  overlayColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.hovered) ? cardColors.active : null,
                  ),
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(8),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffF04C4C),
                          ),
                          child: Assets.icons.selectedBookmarkIcon.svg(
                            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          "Отмеченные сообщения",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
          }
        }

        final chatIndex = index - headerItemsCount;
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

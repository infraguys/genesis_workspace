import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/mixins/chat/open_dm_chat_mixin.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/info_panel_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/chat_item.dart';
import 'package:genesis_workspace/features/messenger/view/widgets/header_chat_item.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class _HeaderItem {
  final String title;
  final VoidCallback onTap;
  final Widget icon;
  final Color color;

  _HeaderItem({
    required this.title,
    required this.onTap,
    required this.icon,
    required this.color,
  });
}

class MessengerChatListView extends StatelessWidget with OpenDmChatMixin {
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

  static const int headerItemsCount = 4;
  static const BorderRadius materialBorderRadius = BorderRadius.all(Radius.circular(8));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerItems = <_HeaderItem>[
      _HeaderItem(
        title: context.t.favorite.title,
        onTap: () {
          final myUserId = context.read<ProfileCubit>().state.user?.userId;
          if (myUserId != null) {
            openChat(
              context,
              chatId: -1,
              membersIds: {myUserId},
            );
          }
        },
        icon: Assets.icons.home.svg(
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        color: Color(0xff58A7F7),
      ),
      _HeaderItem(
        title: context.t.starred.title,
        onTap: () {
          if (currentSize(context) <= ScreenSize.lTablet) {
            context.pushNamed(Routes.starred);
          } else {
            context.read<MessengerCubit>().openSection(.starredMessages);
          }
        },
        icon: Assets.icons.selectedBookmarkIcon.svg(
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        color: Color(0xffF04C4C),
      ),
      _HeaderItem(
        title: context.t.mentions.title,
        onTap: () {
          if (currentSize(context) <= ScreenSize.lTablet) {
            context.pushNamed(Routes.mentions);
          } else {
            context.read<MessengerCubit>().openSection(.mentions);
          }
        },
        icon: Icon(
          Icons.alternate_email,
          color: Colors.white,
        ),
        color: Color(0xfff0ca4c),
      ),
      _HeaderItem(
        title: context.t.reactions.title,
        onTap: () {
          if (currentSize(context) <= ScreenSize.lTablet) {
            context.pushNamed(Routes.reactions);
          } else {
            context.read<MessengerCubit>().openSection(.reactions);
          }
        },
        icon: Icon(
          Icons.emoji_emotions_outlined,
          color: Colors.white,
        ),
        color: Color(0xff58a333),
      ),
    ];
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
          final item = headerItems[index];
          return HeaderChatItem(
            title: item.title,
            onTap: item.onTap,
            icon: item.icon,
            color: item.color,
          );
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

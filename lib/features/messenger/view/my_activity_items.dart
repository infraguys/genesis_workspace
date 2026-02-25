import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/mixins/chat/open_chat_mixin.dart';
import 'package:genesis_workspace/features/drafts/bloc/drafts_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/widgets/activity_chat_item.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class _ActivityItem {
  final String title;
  final VoidCallback onTap;
  final Widget icon;
  final Color color;
  final int unreadCount;
  final bool isMuted;

  _ActivityItem({
    required this.title,
    required this.onTap,
    required this.icon,
    required this.color,
    this.unreadCount = 0,
    this.isMuted = false,
  });
}

class MyActivityItems extends StatelessWidget with OpenChatMixin {
  const MyActivityItems({super.key});

  List<_ActivityItem> _activityItems(
    BuildContext context, {
    required int mentionsUnreadCount,
    required int draftsCount,
    required int? myUserId,
    required int? mySelfChatId,
  }) {
    return <_ActivityItem>[
      _ActivityItem(
        title: context.t.favorite.title,
        onTap: () {
          if (myUserId == null) {
            return;
          }
          if (currentSize(context) <= ScreenSize.lTablet) {
            context.pushNamed(
              Routes.chat,
              pathParameters: {
                'chatId': (mySelfChatId ?? -1).toString(),
                'userId': myUserId.toString(),
              },
            );
            return;
          }
          openChat(
            context,
            chatId: mySelfChatId ?? -1,
            membersIds: {myUserId},
          );
        },
        icon: Assets.icons.home.svg(
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        color: Color(0xff58A7F7),
      ),
      _ActivityItem(
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
      _ActivityItem(
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
        unreadCount: mentionsUnreadCount,
      ),
      _ActivityItem(
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
      _ActivityItem(
        title: context.t.drafts.title,
        onTap: () {
          if (currentSize(context) <= ScreenSize.lTablet) {
            context.pushNamed(Routes.drafts);
          } else {
            context.read<MessengerCubit>().openSection(.drafts);
          }
        },
        icon: Assets.icons.pencilFilled.svg(
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        color: Color(0xffB86BEF),
        unreadCount: draftsCount,
        isMuted: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final messengerState = context.select((MessengerCubit cubit) => cubit.state);
    final mentionsUnreadCount = messengerState.mentionsUnreadCount;
    final mySelfChatId = messengerState.mySelfChatId;
    final myUserId = context.select((ProfileCubit cubit) => cubit.state.user?.userId);

    final draftsCount = context.select((DraftsCubit cubit) => cubit.state.drafts.length);
    final items = _activityItems(
      context,
      mentionsUnreadCount: mentionsUnreadCount,
      draftsCount: draftsCount,
      myUserId: myUserId,
      mySelfChatId: mySelfChatId,
    );
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final item = items[index];
        return ActivityChatItem(
          title: item.title,
          onTap: item.onTap,
          icon: item.icon,
          color: item.color,
          unreadCount: item.unreadCount,
          isMuted: item.isMuted,
        );
      },
    );
  }
}

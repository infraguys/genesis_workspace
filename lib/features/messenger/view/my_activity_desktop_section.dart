import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/mixins/chat/open_chat_mixin.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
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

class MyActivityDesktopSection extends StatefulWidget {
  const MyActivityDesktopSection({super.key});

  @override
  State<MyActivityDesktopSection> createState() => _MyActivityDesktopSectionState();
}

class _MyActivityDesktopSectionState extends State<MyActivityDesktopSection> with OpenChatMixin {
  final ExpansibleController _controller = ExpansibleController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          if (myUserId == null) return;
          openChat(
            context,
            chatId: mySelfChatId ?? -1,
            membersIds: {myUserId},
          );
        },
        icon: Assets.icons.home.svg(
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        color: const Color(0xff58A7F7),
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
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        color: const Color(0xffF04C4C),
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
        icon: const Icon(
          Icons.alternate_email,
          color: Colors.white,
        ),
        color: const Color(0xfff0ca4c),
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
        icon: const Icon(
          Icons.emoji_emotions_outlined,
          color: Colors.white,
        ),
        color: const Color(0xff58a333),
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
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        color: const Color(0xffB86BEF),
        unreadCount: draftsCount,
        isMuted: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final messengerState = context.select((MessengerCubit cubit) => cubit.state);
    final int mentionsUnreadCount = messengerState.mentionsUnreadCount;
    final int? mySelfChatId = messengerState.mySelfChatId;
    final int? myUserId = context.select((ProfileCubit cubit) => cubit.state.user?.userId);
    final int draftsCount = context.select((DraftsCubit cubit) => cubit.state.drafts.length);

    final items = _activityItems(
      context,
      mentionsUnreadCount: mentionsUnreadCount,
      draftsCount: draftsCount,
      myUserId: myUserId,
      mySelfChatId: mySelfChatId,
    );

    return ExpansionTile(
      title: Text(context.t.myActivity),
      controller: _controller,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 12,
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: UnreadBadge(count: mentionsUnreadCount),
          ),
          AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Assets.icons.arrowDown.svg(),
          ),
        ],
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
      onExpansionChanged: (bool isExpanded) {
        setState(() => _isExpanded = isExpanded);
      },
      children: items
          .expand(
            (item) => [
              ActivityChatItem(
                title: item.title,
                onTap: item.onTap,
                icon: item.icon,
                color: item.color,
                unreadCount: item.unreadCount,
                isMuted: item.isMuted,
              ),
              const SizedBox(height: 4),
            ],
          )
          .toList(),
    );
  }
}

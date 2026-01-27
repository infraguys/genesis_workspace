import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/mixins/chat/open_chat_mixin.dart';
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

  _ActivityItem({
    required this.title,
    required this.onTap,
    required this.icon,
    required this.color,
  });
}

class MyActivityItems extends StatefulWidget {
  final int mySelfChatId;
  const MyActivityItems({super.key, required this.mySelfChatId});

  @override
  State<MyActivityItems> createState() => _MyActivityItemsState();
}

class _MyActivityItemsState extends State<MyActivityItems> with OpenChatMixin {
  final ExpansibleController _controller = ExpansibleController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _activityItems = <_ActivityItem>[
      _ActivityItem(
        title: context.t.favorite.title,
        onTap: () {
          final myUserId = context.read<ProfileCubit>().state.user?.userId;
          // final int? mySelfChatId = chats
          //     .firstWhereOrNull((chat) => chat.dmIds?.length == 1 && chat.dmIds?.first == myUserId)
          //     ?.id;
          // final int? mySelfChatId = -1;
          if (myUserId != null) {
            openChat(
              context,
              chatId: widget.mySelfChatId,
              membersIds: {myUserId},
            );
          }
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
      ),
    ];
    return ExpansionTile(
      title: Text("Моя активность"),
      controller: _controller,
      trailing: AnimatedRotation(
        turns: _isExpanded ? 0.5 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Assets.icons.arrowDown.svg(),
      ),
      childrenPadding: .symmetric(horizontal: 8),
      onExpansionChanged: (bool isExpanded) {
        setState(() => _isExpanded = isExpanded);
      },
      children: _activityItems
          .expand(
            (item) => [
              ActivityChatItem(title: item.title, onTap: item.onTap, icon: item.icon, color: item.color),
              SizedBox(
                height: 4,
              ),
            ],
          )
          .toList(),
    );
  }
}

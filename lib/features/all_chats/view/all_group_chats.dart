import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/chats/common/widgets/group_chat_tile.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class AllGroupChats extends StatefulWidget {
  const AllGroupChats({super.key});

  @override
  State<AllGroupChats> createState() => _AllGroupChatsState();
}

class _AllGroupChatsState extends State<AllGroupChats> with TickerProviderStateMixin {
  late final AnimationController expandController;
  late final Animation<double> expandAnimation;
  bool isExpanded = true;

  @override
  void initState() {
    super.initState();
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    );
    expandAnimation = CurvedAnimation(
      parent: expandController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
    expandController.value = 1.0;
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  void toggleExpanded() {
    setState(() => isExpanded = !isExpanded);
    if (isExpanded) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = currentSize(context) > ScreenSize.lTablet;

    return BlocBuilder<DirectMessagesCubit, DirectMessagesState>(
      builder: (context, dmsState) {
        final groupChats = dmsState.groupChats;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Групповые чаты',
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    splashRadius: 22,
                    onPressed: toggleExpanded,
                    icon: AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: isExpanded ? 0.5 : 0.0,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                ],
              ),
            ),
            ClipRect(
              child: SizeTransition(
                sizeFactor: expandAnimation,
                axisAlignment: -1.0,
                child: FadeTransition(
                  opacity: expandAnimation,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 500),
                    child: ListView.builder(
                      key: const ValueKey('group-chats-list'),
                      shrinkWrap: true,
                      physics: isDesktop
                          ? const AlwaysScrollableScrollPhysics()
                          : const AlwaysScrollableScrollPhysics(),
                      itemCount: groupChats.length,
                      itemBuilder: (context, index) {
                        final group = groupChats.toList()[index];
                        return GroupChatTile(
                          key: ValueKey('group-${index}-${group.members.length}'),
                          members: group.members,
                          unreadCount: group.unreadMessagesCount,
                          onTap: () {
                            if (isDesktop) {
                              context.read<AllChatsCubit>().selectGroupChat(
                                group.members.map((member) => member.userId).toSet(),
                              );
                            } else {
                              final userIds = group.members.map((member) => member.userId).toList();
                              final userIdsString = userIds.join(',');
                              context.pushNamed(
                                Routes.groupChat,
                                pathParameters: {'userIds': userIdsString},
                                extra: {'unreadMessagesCount': group.unreadMessagesCount},
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

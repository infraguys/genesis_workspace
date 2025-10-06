import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/all_chats/view/select_folders_dialog.dart';
import 'package:genesis_workspace/features/chats/common/widgets/user_tile.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class AllChatsDms extends StatefulWidget {
  final Set<int>? filteredDms;
  final FolderItemEntity selectedFolder;
  final bool embeddedInParentScroll;

  const AllChatsDms({
    super.key,
    required this.filteredDms,
    this.embeddedInParentScroll = false,
    required this.selectedFolder,
  });

  @override
  State<AllChatsDms> createState() => _AllChatsDmsState();
}

class _AllChatsDmsState extends State<AllChatsDms> with TickerProviderStateMixin {
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

  List<DmUserEntity> filterUsers(DirectMessagesState directMessagesState) {
    final filteredByFolder = (widget.filteredDms == null)
        ? directMessagesState.filteredRecentDmsUsers
        : directMessagesState.filteredRecentDmsUsers
              .where((user) => widget.filteredDms!.contains(user.userId))
              .toList();

    final pinnedChats = widget.selectedFolder.pinnedChats;
    if (pinnedChats.isEmpty) return filteredByFolder;

    // Создаём быстрый доступ: chatId → orderIndex
    final pinnedOrderByChatId = {
      for (int i = 0; i < pinnedChats.length; i++) pinnedChats[i].chatId: i,
    };

    // Сортируем напрямую
    filteredByFolder.sort((a, b) {
      final aOrder = pinnedOrderByChatId[a.userId];
      final bOrder = pinnedOrderByChatId[b.userId];

      if (aOrder != null && bOrder != null) {
        return aOrder.compareTo(bOrder); // оба закреплены — сортируем по порядку
      }
      if (aOrder != null) return -1; // a закреплён — идёт раньше
      if (bOrder != null) return 1; // b закреплён — идёт позже
      return 0; // оба не закреплены — порядок остаётся как есть
    });

    return filteredByFolder;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = currentSize(context) > ScreenSize.lTablet;

    return BlocBuilder<DirectMessagesCubit, DirectMessagesState>(
      builder: (context, directMessagesState) {
        final List<DmUserEntity> users = filterUsers(directMessagesState);

        if (users.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.t.navBar.directMessages,
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
                    constraints: BoxConstraints(maxHeight: 500),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: widget.embeddedInParentScroll
                          ? const NeverScrollableScrollPhysics()
                          : const AlwaysScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (BuildContext context, int index) {
                        final DmUserEntity user = users[index];
                        final GlobalKey<CustomPopupState> popupKey = GlobalKey<CustomPopupState>();
                        final isPinned = widget.selectedFolder.pinnedChats.any(
                          (chat) => chat.chatId == user.userId,
                        );

                        return CustomPopup(
                          key: popupKey,
                          position: PopupPosition.auto,
                          contentPadding: EdgeInsets.zero,
                          isLongPress: true,
                          content: Container(
                            width: 240,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant.withOpacity(0.5),
                              ),
                              boxShadow: kElevationToShadow[3],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  isPinned
                                      ? ListTile(
                                          leading: const Icon(Icons.push_pin_outlined),
                                          title: Text('Unpin chat'),
                                          onTap: () async {
                                            context.pop();
                                            final pinnedChatId = widget.selectedFolder.pinnedChats
                                                .firstWhere((chat) => chat.chatId == user.userId)
                                                .id;
                                            await context.read<AllChatsCubit>().unpinChat(
                                              pinnedChatId,
                                            );
                                          },
                                        )
                                      : ListTile(
                                          leading: const Icon(Icons.push_pin),
                                          title: Text('Pin chat'),
                                          onTap: () async {
                                            context.pop();
                                            await context.read<AllChatsCubit>().pinChat(
                                              chatId: user.userId,
                                            );
                                          },
                                        ),
                                  ListTile(
                                    leading: const Icon(Icons.folder_open),
                                    title: Text(context.t.folders.addToFolder),
                                    onTap: () async {
                                      context.pop();
                                      await context.read<AllChatsCubit>().loadFolders();
                                      await showDialog(
                                        context: context,
                                        builder: (_) => SelectFoldersDialog(
                                          loadSelectedFolderIds: () => context
                                              .read<AllChatsCubit>()
                                              .getFolderIdsForDm(user.userId),
                                          onSave: (selectedFolderIds) => context
                                              .read<AllChatsCubit>()
                                              .setFoldersForDm(user.userId, selectedFolderIds),
                                          folders: context.read<AllChatsCubit>().state.folders,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onSecondaryTap: () => popupKey.currentState?.show(),
                            child: UserTile(
                              key: ValueKey(user.userId),
                              isPinned: isPinned,
                              user: user,
                              onTap: () {
                                if (isDesktop) {
                                  context.read<AllChatsCubit>().selectDmChat(user);
                                } else {
                                  context.pushNamed(
                                    Routes.chat,
                                    pathParameters: {'userId': user.userId.toString()},
                                    extra: {'unreadMessagesCount': user.unreadMessages.length},
                                  );
                                }
                              },
                            ),
                          ),
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

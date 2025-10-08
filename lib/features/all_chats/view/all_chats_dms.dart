import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/data/all_chats/tables/pinned_chats_table.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/all_chats/view/select_folders_dialog.dart';
import 'package:genesis_workspace/features/chats/common/widgets/user_tile.dart';
import 'package:genesis_workspace/features/chats/common/widgets/dm_search_field.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class AllChatsDms extends StatefulWidget {
  final Set<int>? filteredDms;
  final FolderItemEntity selectedFolder;
  final bool embeddedInParentScroll;
  final bool isEditPinning;

  const AllChatsDms({
    super.key,
    required this.filteredDms,
    this.embeddedInParentScroll = false,
    required this.selectedFolder,
    required this.isEditPinning,
  });

  @override
  State<AllChatsDms> createState() => _AllChatsDmsState();
}

class _AllChatsDmsState extends State<AllChatsDms> with TickerProviderStateMixin {
  late final AnimationController expandController;
  late final Animation<double> expandAnimation;
  bool isExpanded = true;
  List<DmUserEntity>? optimisticUsers;
  bool isReorderingInProgress = false;
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
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

  List<DmUserEntity> filterUsers(List<DmUserEntity> usersList) {
    final List<DmUserEntity> baseList =
        (widget.filteredDms == null || widget.selectedFolder.id == 0)
        ? usersList
        : usersList.where((user) => widget.filteredDms!.contains(user.userId)).toList();

    final List<PinnedChatEntity> pinnedChats = widget.selectedFolder.pinnedChats
        .where((chat) => chat.type == PinnedChatType.dm)
        .toList();
    final Map<int, PinnedChatEntity> pinnedByChatId = {
      for (final pinned in pinnedChats) pinned.chatId: pinned,
    };

    int compareByOrderAndPinnedAt(PinnedChatEntity? a, PinnedChatEntity? b) {
      final bool aPinned = a != null;
      final bool bPinned = b != null;
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      if (!aPinned && !bPinned) return 0;

      final int? aOrder = a!.orderIndex;
      final int? bOrder = b!.orderIndex;

      if (aOrder != null && bOrder != null) {
        if (aOrder != bOrder) return aOrder.compareTo(bOrder);
        return b.pinnedAt.compareTo(a.pinnedAt);
      }
      if (aOrder != null && bOrder == null) return -1;
      if (aOrder == null && bOrder != null) return 1;

      return b.pinnedAt.compareTo(a.pinnedAt);
    }

    if (widget.isEditPinning) {
      final List<DmUserEntity> onlyPinned =
          baseList.where((u) => pinnedByChatId.containsKey(u.userId)).toList()..sort(
            (a, b) => compareByOrderAndPinnedAt(pinnedByChatId[a.userId], pinnedByChatId[b.userId]),
          );
      return onlyPinned;
    }

    if (pinnedByChatId.isEmpty) return baseList;

    final Map<int, int> originalIndexByUserId = {
      for (int i = 0; i < baseList.length; i++) baseList[i].userId: i,
    };

    baseList.sort((a, b) {
      final int pinnedCompare = compareByOrderAndPinnedAt(
        pinnedByChatId[a.userId],
        pinnedByChatId[b.userId],
      );
      if (pinnedCompare != 0) return pinnedCompare;
      return originalIndexByUserId[a.userId]!.compareTo(originalIndexByUserId[b.userId]!);
    });

    return baseList;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = currentSize(context) > ScreenSize.lTablet;

    return BlocBuilder<DirectMessagesCubit, DirectMessagesState>(
      buildWhen: (_, _) => !isReorderingInProgress,
      builder: (context, directMessagesState) {
        final List<DmUserEntity> baseFiltered = directMessagesState.showAllUsers
            ? directMessagesState.filteredUsers
            : directMessagesState.filteredRecentDmsUsers;
        final List<DmUserEntity> filtered = filterUsers(baseFiltered);
        final List<DmUserEntity> users = optimisticUsers ?? filtered;

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
                  Tooltip(
                    message: directMessagesState.showAllUsers
                        ? context.t.showRecentDialogs
                        : context.t.showAllUsers,
                    child: IconButton(
                      splashRadius: 22,
                      onPressed: context.read<DirectMessagesCubit>().toggleShowAllUsers,
                      icon: Icon(
                        directMessagesState.showAllUsers ? Icons.history : Icons.groups,
                      ),
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
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: DmSearchField(
                          searchController: _searchController,
                          searchUsers: context.read<DirectMessagesCubit>().searchUsers,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 500),
                        child: widget.isEditPinning
                            ? ReorderableListView.builder(
                                buildDefaultDragHandles: false,
                                shrinkWrap: true,
                                physics: widget.embeddedInParentScroll
                                    ? const NeverScrollableScrollPhysics()
                                    : const AlwaysScrollableScrollPhysics(),
                                itemCount: users.length,
                                onReorder: (int oldIndex, int newIndex) async {
                                  if (newIndex > oldIndex) newIndex -= 1;

                              final List<DmUserEntity> local = List<DmUserEntity>.from(
                                optimisticUsers ?? users,
                              );
                              final DmUserEntity moved = local.removeAt(oldIndex);
                              local.insert(newIndex, moved);

                              setState(() {
                                isReorderingInProgress = true;
                                optimisticUsers = local;
                              });

                              final int movedChatId = moved.userId;
                              final int? previousChatId = (newIndex - 1) >= 0
                                  ? local[newIndex - 1].userId
                                  : null;
                              final int? nextChatId = (newIndex + 1) < local.length
                                  ? local[newIndex + 1].userId
                                  : null;

                              try {
                                await context.read<AllChatsCubit>().reorderPinnedChats(
                                  folderId: widget.selectedFolder.id ?? 0,
                                  movedChatId: movedChatId,
                                  previousChatId: previousChatId,
                                  nextChatId: nextChatId,
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    isReorderingInProgress = false;
                                    optimisticUsers = null;
                                  });
                                }
                              }
                            },
                            proxyDecorator: (child, index, animation) {
                              return Material(elevation: 3, child: child);
                            },
                            itemBuilder: (BuildContext context, int index) {
                              final DmUserEntity user = users[index];
                              return KeyedSubtree(
                                key: ValueKey<int>(user.userId),
                                child: UserTile(
                                  key: ValueKey('pinned-${user.userId}'),
                                  user: user,
                                  isPinned: true,
                                  isEditPinning: true,
                                  trailingOverride: ReorderableDragStartListener(
                                    index: index,
                                    child: Icon(
                                      Icons.drag_handle_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: widget.embeddedInParentScroll
                                ? const NeverScrollableScrollPhysics()
                                : const AlwaysScrollableScrollPhysics(),
                            itemCount: users.length,
                            itemBuilder: (BuildContext context, int index) {
                              final DmUserEntity user = users[index];
                              final GlobalKey<CustomPopupState> popupKey =
                                  GlobalKey<CustomPopupState>();
                              final bool isPinned = widget.selectedFolder.pinnedChats.any(
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
                                                title: Text(context.t.chat.unpinChat),
                                                onTap: () async {
                                                  context.pop();
                                                  final pinnedChatId = widget
                                                      .selectedFolder
                                                      .pinnedChats
                                                      .firstWhere(
                                                        (chat) => chat.chatId == user.userId,
                                                      )
                                                      .id;
                                                  await context.read<AllChatsCubit>().unpinChat(
                                                    pinnedChatId,
                                                  );
                                                },
                                              )
                                            : ListTile(
                                                leading: const Icon(Icons.push_pin),
                                                title: Text(context.t.chat.pinChat),
                                                onTap: () async {
                                                  context.pop();
                                                  await context.read<AllChatsCubit>().pinChat(
                                                    chatId: user.userId,
                                                    type: PinnedChatType.dm,
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
                                                onSave: (selectedFolderIds) =>
                                                    context.read<AllChatsCubit>().setFoldersForDm(
                                                      user.userId,
                                                      selectedFolderIds,
                                                    ),
                                                folders: context
                                                    .read<AllChatsCubit>()
                                                    .state
                                                    .folders,
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
                                          extra: {
                                            'unreadMessagesCount': user.unreadMessages.length,
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                      ),
                    ],
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

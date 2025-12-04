import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/mixins/chat/open_dm_chat_mixin.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/domain/users/entities/group_chat_entity.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/chats/common/widgets/group_chat_tile.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class AllGroupChats extends StatefulWidget {
  final Set<int>? filteredGroupChatIds;
  final FolderItemEntity selectedFolder;
  final bool embeddedInParentScroll;
  final bool isEditPinning;

  const AllGroupChats({
    super.key,
    required this.selectedFolder,
    required this.isEditPinning,
    this.filteredGroupChatIds,
    this.embeddedInParentScroll = false,
  });

  @override
  State<AllGroupChats> createState() => _AllGroupChatsState();
}

class _AllGroupChatsState extends State<AllGroupChats> with TickerProviderStateMixin, OpenDmChatMixin {
  late final AnimationController expandController;
  late final Animation<double> expandAnimation;
  bool isExpanded = true;

  List<GroupChatEntity>? optimisticGroups;
  bool isReorderingInProgress = false;

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
      buildWhen: (_, __) => !isReorderingInProgress,
      builder: (context, dmsState) {
        final List<GroupChatEntity> baseList = (widget.filteredGroupChatIds == null || widget.selectedFolder.id == 0)
            ? [...dmsState.groupChats]
            : [
                ...dmsState.groupChats,
              ].where((group) => widget.filteredGroupChatIds!.contains(group.id)).toList();

        final List<PinnedChatEntity> pinnedChats = widget.selectedFolder.pinnedChats
            // .where((chat) => chat.type == PinnedChatType.group)
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
            // return b.pinnedAt.compareTo(a.pinnedAt);
          }
          if (aOrder != null && bOrder == null) return -1;
          if (aOrder == null && bOrder != null) return 1;

          // return b.pinnedAt.compareTo(a.pinnedAt);
          return 1;
        }

        List<GroupChatEntity> filtered;
        if (widget.isEditPinning) {
          filtered = baseList.where((group) => pinnedByChatId.containsKey(group.id)).toList()
            ..sort((a, b) => compareByOrderAndPinnedAt(pinnedByChatId[a.id], pinnedByChatId[b.id]));
        } else {
          if (pinnedByChatId.isEmpty) {
            filtered = baseList;
          } else {
            final Map<int, int> originalIndexById = {
              for (int i = 0; i < baseList.length; i++) baseList[i].id: i,
            };
            filtered = List<GroupChatEntity>.from(baseList);
            filtered.sort((a, b) {
              final int pinnedCompare = compareByOrderAndPinnedAt(
                pinnedByChatId[a.id],
                pinnedByChatId[b.id],
              );
              if (pinnedCompare != 0) return pinnedCompare;
              return originalIndexById[a.id]!.compareTo(originalIndexById[b.id]!);
            });
          }
        }

        final List<GroupChatEntity> groups = optimisticGroups ?? filtered;

        if (groups.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      spacing: 8,
                      children: [
                        Text(
                          context.t.navBar.groupChats,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                    child: widget.isEditPinning
                        ? ReorderableListView.builder(
                            buildDefaultDragHandles: false,
                            shrinkWrap: true,
                            physics: widget.embeddedInParentScroll
                                ? const NeverScrollableScrollPhysics()
                                : const AlwaysScrollableScrollPhysics(),
                            proxyDecorator: (child, index, animation) {
                              return Material(elevation: 3, child: child);
                            },
                            itemCount: groups.length,
                            onReorder: (int oldIndex, int newIndex) async {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final List<GroupChatEntity> local = List<GroupChatEntity>.from(
                                optimisticGroups ?? groups,
                              );
                              final GroupChatEntity moved = local.removeAt(oldIndex);
                              local.insert(newIndex, moved);

                              if (mounted) {
                                setState(() {
                                  isReorderingInProgress = true;
                                  optimisticGroups = local;
                                });
                              }

                              int? chatIdForIndex(int idx) {
                                if (idx < 0 || idx >= local.length) return null;
                                return local[idx].id;
                              }

                              final int movedChatId = moved.id;
                              final int? previousChatId = chatIdForIndex(newIndex - 1);
                              final int? nextChatId = chatIdForIndex(newIndex + 1);

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
                                    optimisticGroups = null;
                                    isReorderingInProgress = false;
                                  });
                                }
                              }
                            },
                            itemBuilder: (context, index) {
                              final group = groups[index];
                              return KeyedSubtree(
                                key: ValueKey<int>(group.id),
                                child: GroupChatTile(
                                  key: ValueKey('group-${group.id}'),
                                  members: group.members,
                                  unreadCount: group.unreadMessagesCount,
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
                            key: const ValueKey('group-chats-list'),
                            shrinkWrap: true,
                            physics: widget.embeddedInParentScroll
                                ? const NeverScrollableScrollPhysics()
                                : const AlwaysScrollableScrollPhysics(),
                            itemCount: groups.length,
                            itemBuilder: (context, index) {
                              final group = groups[index];
                              final bool isPinned = pinnedByChatId.containsKey(group.id);
                              final GlobalKey<CustomPopupState> popupKey = GlobalKey<CustomPopupState>();
                              return CustomPopup(
                                key: popupKey,
                                position: PopupPosition.auto,
                                contentPadding: EdgeInsets.zero,
                                isLongPress: true,
                                content: Container(
                                  width: 220,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant.withOpacity(0.5),
                                    ),
                                    boxShadow: kElevationToShadow[3],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        isPinned
                                            ? ListTile(
                                                leading: const Icon(
                                                  Icons.push_pin_outlined,
                                                  size: 20,
                                                ),
                                                title: Text(context.t.chat.unpinChat),
                                                onTap: () async {
                                                  context.pop();
                                                  // final pinnedChatId = widget
                                                  //     .selectedFolder
                                                  //     .pinnedChats
                                                  //     .firstWhere((chat) => chat.chatId == group.id)
                                                  //     .id;
                                                  // await context.read<AllChatsCubit>().unpinChat(
                                                  //   pinnedChatId,
                                                  // );
                                                },
                                              )
                                            : ListTile(
                                                leading: const Icon(Icons.push_pin, size: 20),
                                                title: Text(context.t.chat.pinChat),
                                                onTap: () async {
                                                  context.pop();

                                                  // await context.read<AllChatsCubit>().pinChat(
                                                  //   chatId: group.id,
                                                  //   type: PinnedChatType.group,
                                                  // );
                                                },
                                              ),
                                        ListTile(
                                          leading: const Icon(Icons.folder_open, size: 20),
                                          title: Text(context.t.folders.addToFolder),
                                          onTap: () async {
                                            context.pop();

                                            await context.read<AllChatsCubit>().loadFolders();
                                            // await showDialog(
                                            //   context: context,
                                            //   builder: (_) => SelectFoldersDialog(
                                            //     loadSelectedFolderIds: () => context
                                            //         .read<AllChatsCubit>()
                                            //         .getFolderIdsForGroupChat(group.id),
                                            //     onSave: (selectedFolderIds) => context
                                            //         .read<AllChatsCubit>()
                                            //         .setFoldersForGroupChat(
                                            //           group.id,
                                            //           selectedFolderIds,
                                            //         ),
                                            //     folders: context
                                            //         .read<AllChatsCubit>()
                                            //         .state
                                            //         .folders,
                                            //   ),
                                            // );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                child: GestureDetector(
                                  onSecondaryTap: () => popupKey.currentState?.show(),
                                  child: GroupChatTile(
                                    key: ValueKey('group-${group.id}'),
                                    members: group.members,
                                    unreadCount: group.unreadMessagesCount,
                                    isPinned: isPinned,
                                    onTap: () {
                                      openChat(
                                        context,
                                        group.members.map((member) => member.userId).toSet(),
                                        unreadMessagesCount: group.unreadMessagesCount,
                                      );
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

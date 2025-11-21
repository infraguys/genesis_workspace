import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/chat_type.dart';
import 'package:genesis_workspace/core/mixins/chat/open_dm_chat_mixin.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/features/all_chats/view/create_folder_dialog.dart';
import 'package:genesis_workspace/features/channel_chat/channel_chat.dart';
import 'package:genesis_workspace/features/chat/chat.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/chat_item.dart';
import 'package:genesis_workspace/features/messenger/view/chat_reorder_item.dart';
import 'package:genesis_workspace/features/messenger/view/chat_topics_list.dart';
import 'package:genesis_workspace/features/messenger/view/folder_item.dart';
import 'package:genesis_workspace/features/messenger/view/messenger_app_bar.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class MessengerView extends StatefulWidget {
  const MessengerView({super.key});

  @override
  State<MessengerView> createState() => _MessengerViewState();
}

class _MessengerViewState extends State<MessengerView> with SingleTickerProviderStateMixin, OpenDmChatMixin {
  static const Duration _searchAnimationDuration = Duration(milliseconds: 220);
  Future<void>? _future;
  final TextEditingController _searchController = TextEditingController();

  bool _isEditPinning = false;
  List<ChatEntity>? _optimisticPinnedChats;
  bool _isPinnedReorderInProgress = false;
  bool _isSearchVisible = true;
  late final AnimationController _searchBarController;
  late final Animation<double> _searchBarAnimation;
  String _searchQuery = '';

  late final ScrollController _chatsController;
  late final ScrollController _topicsController;

  bool _showTopics = false;

  Future<void> createNewFolder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (dialogContext) => CreateFolderDialog(
        onSubmit: (folder) async {
          await context.read<MessengerCubit>().addFolder(folder);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  Future<void> editFolder(BuildContext context, FolderItemEntity folder) {
    context.pop();
    return showDialog(
      context: context,
      builder: (dialogContext) => CreateFolderDialog(
        initial: folder,
        onSubmit: (updated) async {
          await context.read<MessengerCubit>().updateFolder(updated);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  void editPinning() {
    setState(() {
      _isEditPinning = true;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    context.read<MessengerCubit>().searchChats(query);
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  Future<void> getInitialData() async {
    await Future.wait([
      context.read<MessengerCubit>().loadFolders(),
      context.read<MessengerCubit>().getInitialMessages(),
    ]);
    if (mounted) {
      unawaited(context.read<MessengerCubit>().lazyLoadAllMessages());
    }
  }

  void _checkUser() {
    if (context.read<MessengerCubit>().state.selfUser == null) {
      final user = context.read<ProfileCubit>().state.user;
      if (user != null) {
        context.read<MessengerCubit>().setSelfUser(user);
      }
    }
  }

  @override
  void initState() {
    _checkUser();
    _searchBarController = AnimationController(
      vsync: this,
      duration: _searchAnimationDuration,
      value: 1,
    );
    _searchBarAnimation = CurvedAnimation(
      parent: _searchBarController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _searchBarController.addListener(() => setState(() {}));
    _chatsController = ScrollController();
    _topicsController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    _searchController.dispose();
    _chatsController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;

    final ScreenSize screenSize = currentSize(context);
    final bool isLargeScreen = screenSize > ScreenSize.tablet;
    final bool isTabletOrSmaller = !isLargeScreen;
    final double searchVisibility = _searchBarAnimation.value;

    final EdgeInsets listPadding = EdgeInsets.symmetric(horizontal: isTabletOrSmaller ? 20 : 8).copyWith(
      top: isTabletOrSmaller ? 20 : 0,
      bottom: 20,
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          setState(() {
            _showTopics = false;
          });
        }
      },
      child: BlocListener<OrganizationsCubit, OrganizationsState>(
        listenWhen: (previous, current) => previous.selectedOrganizationId != current.selectedOrganizationId,
        listener: (context, state) {
          context.read<MessengerCubit>().resetState();
          context.read<MessengerCubit>().searchChats('');
          setState(() {
            _searchQuery = '';
            _searchController.clear();
            _future = getInitialData();
          });
          unawaited(
            Future.wait([
              context.read<RealTimeCubit>().ensureConnection(),
              context.read<MessengerCubit>().getUnreadMessages(),
            ]),
          );
        },
        child: BlocListener<ProfileCubit, ProfileState>(
          listenWhen: (prev, current) => prev.user != current.user,
          listener: (context, profileState) {
            if (profileState.user != null) {
              context.read<MessengerCubit>().setSelfUser(profileState.user!);
            }
          },
          child: FutureBuilder(
            future: _future ?? Future.value(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return BlocBuilder<MessengerCubit, MessengerState>(
                builder: (context, state) {
                  final List<ChatEntity> baseChats = state.filteredChatIds == null
                      ? state.chats
                      : state.chats.where((chat) => state.filteredChatIds!.contains(chat.id)).toList();
                  final List<ChatEntity> visibleChats = state.filteredChats ?? baseChats;
                  final List<ChatEntity> pinnedChatsForEdit =
                      _optimisticPinnedChats ?? _pinnedChatsForEdit(visibleChats, state.pinnedChats);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (isLargeScreen)
                        Padding(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: 60,
                            child: Column(
                              children: [
                                Expanded(
                                  child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      itemCount: state.folders.length,
                                      separatorBuilder: (_, __) => SizedBox(height: 28),
                                      itemBuilder: (BuildContext context, int index) {
                                        final FolderItemEntity folder = state.folders[index];
                                        final bool isSelected = state.selectedFolderIndex == index;
                                        Widget icon;
                                        final String title = index == 0 ? context.t.folders.all : folder.title!;
                                        if (index == 0) {
                                          icon = Assets.icons.allChats.svg(
                                            colorFilter: isSelected
                                                ? ColorFilter.mode(textColors.text100, BlendMode.srcIn)
                                                : null,
                                          );
                                        } else if (isSelected) {
                                          icon = Assets.icons.folderOpen.svg();
                                        } else {
                                          icon = Assets.icons.folder.svg();
                                        }
                                        return FolderItem(
                                          title: title,
                                          folder: folder,
                                          isSelected: isSelected,
                                          icon: icon,
                                          onTap: () {
                                            context.read<MessengerCubit>().selectFolder(index);
                                          },
                                          onEdit: (folder.systemType == null)
                                              ? () => editFolder(context, folder)
                                              : null,
                                          onOrderPinning: () {
                                            context.pop();
                                            context.read<MessengerCubit>().selectFolder(index);
                                            editPinning();
                                          },
                                          onDelete: (folder.systemType == null)
                                              ? () async {
                                                  context.pop();
                                                  final confirmed = await showDialog<bool>(
                                                    context: context,
                                                    builder: (dialogContext) => AlertDialog(
                                                      title: Text(context.t.folders.deleteConfirmTitle),
                                                      content: Text(
                                                        context.t.folders.deleteConfirmText(
                                                          folderName: folder.title ?? '',
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.of(dialogContext).pop(false),
                                                          child: Text(context.t.folders.cancel),
                                                        ),
                                                        FilledButton(
                                                          onPressed: () => Navigator.of(dialogContext).pop(true),
                                                          child: Text(context.t.folders.delete),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  if (confirmed == true) {
                                                    await context.read<MessengerCubit>().deleteFolder(
                                                      folder,
                                                    );
                                                  }
                                                }
                                              : null,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 28),
                                IconButton(
                                  onPressed: () {
                                    createNewFolder(context);
                                  },
                                  icon: Assets.icons.add.svg(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: isTabletOrSmaller ? MediaQuery.sizeOf(context).width : 315,
                        ),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: isTabletOrSmaller ? theme.colorScheme.background : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MessengerAppBar(
                                  selectedChatLabel: state.selectedChat?.displayTitle,
                                  showTopics: _showTopics,
                                  onTapBack: () {
                                    setState(() {
                                      _showTopics = false;
                                    });
                                  },
                                  isLargeScreen: isLargeScreen,
                                  searchVisibility: searchVisibility,
                                  folders: state.folders,
                                  selectedFolderIndex: state.selectedFolderIndex,
                                  onSelectFolder: (index) => context.read<MessengerCubit>().selectFolder(index),
                                  onCreateFolder: () => unawaited(createNewFolder(context)),
                                  onEditFolder: (folder) async {
                                    await editFolder(context, folder);
                                  },
                                  onOrderPinning: _handleOrderPinning,
                                  onDeleteFolder: _handleFolderDelete,
                                  isEditPinning: _isEditPinning,
                                  onStopEditingPins: () => setState(() => _isEditPinning = false),
                                  showSearchField: _isSearchVisible,
                                  selfUserId: state.selfUser?.userId ?? -1,
                                  onSearchChanged: _onSearchChanged,
                                  onClearSearch: _clearSearch,
                                  searchController: _searchController,
                                  searchQuery: _searchQuery,
                                  isLoadingMore: !state.foundOldestMessage,
                                ),
                                if (visibleChats.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Center(
                                      child: Text(context.t.folders.folderIsEmpty),
                                    ),
                                  ),
                                Expanded(
                                  child: Stack(
                                    children: [
                                      NotificationListener<UserScrollNotification>(
                                        onNotification: _onUserScroll,
                                        child: _isEditPinning
                                            ? ReorderableListView.builder(
                                                padding: listPadding,
                                                itemCount: pinnedChatsForEdit.length,
                                                buildDefaultDragHandles: false,
                                                onReorder: (oldIndex, newIndex) => _handlePinnedChatReorder(
                                                  currentState: state,
                                                  pinnedChats: pinnedChatsForEdit,
                                                  oldIndex: oldIndex,
                                                  newIndex: newIndex,
                                                ),
                                                proxyDecorator: (child, index, animation) {
                                                  return Material(
                                                    elevation: 4,
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: child,
                                                  );
                                                },
                                                itemBuilder: (context, index) {
                                                  final chat = pinnedChatsForEdit[index];
                                                  return KeyedSubtree(
                                                    key: ValueKey('pinned-chat-${chat.id}'),
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                        bottom: index == pinnedChatsForEdit.length - 1 ? 0 : 4,
                                                      ),
                                                      child: ChatReorderItem(
                                                        chat: chat,
                                                        index: index,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : ListView.separated(
                                                padding: listPadding,
                                                itemCount: visibleChats.length,
                                                separatorBuilder: (_, __) => SizedBox(height: 4),
                                                controller: _chatsController,
                                                itemBuilder: (BuildContext context, int index) {
                                                  final chat = visibleChats[index];
                                                  return ChatItem(
                                                    key: ValueKey(chat.id),
                                                    chat: chat,
                                                    selectedChatId: state.selectedChat?.id,
                                                    showTopics: _showTopics,
                                                    onTap: () async {
                                                      if (isTabletOrSmaller) {
                                                        if (chat.type == ChatType.channel) {
                                                          setState(() {
                                                            _showTopics = !_showTopics;
                                                          });
                                                        } else {
                                                          openChat(context, chat.dmIds?.toSet() ?? {});
                                                        }
                                                      } else {
                                                        context.read<MessengerCubit>().selectChat(chat);
                                                      }
                                                    },
                                                  );
                                                },
                                              ),
                                      ),
                                      ChatTopicsList(
                                        showTopics: _showTopics,
                                        isPending: state.selectedChat?.topics == null,
                                        selectedChat: state.selectedChat,
                                        listPadding: _isSearchVisible ? 350 : 300,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isLargeScreen) SizedBox(width: 4),
                      if (isLargeScreen)
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (state.selectedChat?.dmIds != null) {
                                return Chat(
                                  key: ObjectKey(
                                    state.selectedChat!.id,
                                  ),
                                  userIds: state.selectedChat!.dmIds!,
                                  unreadMessagesCount: state.selectedChat?.unreadMessages.length,
                                );
                              }
                              if (state.selectedChat?.streamId != null) {
                                return ChannelChat(
                                  key: ObjectKey(
                                    state.selectedChat!.id,
                                  ),
                                  channelId: state.selectedChat!.streamId!,
                                  topicName: state.selectedTopic,
                                  unreadMessagesCount: state.selectedChat?.unreadMessages.length,
                                );
                              }
                              return Center(child: Text(context.t.selectAnyChat));
                            },
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  bool _onUserScroll(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (notification.direction == ScrollDirection.reverse && _isSearchVisible) {
      setState(() => _isSearchVisible = false);
      _searchBarController.reverse();
    } else if (notification.direction == ScrollDirection.forward && !_isSearchVisible) {
      setState(() => _isSearchVisible = true);
      _searchBarController.forward();
    }
    return false;
  }

  void _handleOrderPinning(BuildContext popupContext, int index) {
    popupContext.pop();
    popupContext.read<MessengerCubit>().selectFolder(index);
    editPinning();
  }

  Future<void> _handleFolderDelete(BuildContext popupContext, FolderItemEntity folder) async {
    popupContext.pop();
    final confirmed = await showDialog<bool>(
      context: popupContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(popupContext.t.folders.deleteConfirmTitle),
        content: Text(
          popupContext.t.folders.deleteConfirmText(
            folderName: folder.title ?? '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(popupContext.t.folders.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(popupContext.t.folders.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await popupContext.read<MessengerCubit>().deleteFolder(folder);
    }
  }

  List<ChatEntity> _pinnedChatsForEdit(List<ChatEntity> chats, List<PinnedChatEntity> pinnedMeta) {
    if (pinnedMeta.isEmpty) {
      return chats.where((chat) => chat.isPinned).toList();
    }
    final Map<int, PinnedChatEntity> pinnedByChatId = {
      for (final pinned in pinnedMeta) pinned.chatId: pinned,
    };

    int comparePinnedMeta(PinnedChatEntity? a, PinnedChatEntity? b) {
      final bool aPinned = a != null;
      final bool bPinned = b != null;
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      if (!aPinned && !bPinned) return 0;

      final int? aOrder = a!.orderIndex;
      final int? bOrder = b!.orderIndex;

      if (aOrder != null && bOrder != null && aOrder != bOrder) {
        return aOrder.compareTo(bOrder);
      }
      if (aOrder != null && bOrder == null) return -1;
      if (aOrder == null && bOrder != null) return 1;

      return b!.pinnedAt.compareTo(a.pinnedAt);
    }

    final List<ChatEntity> pinnedChats = chats.where((chat) => pinnedByChatId.containsKey(chat.id)).toList()
      ..sort((a, b) => comparePinnedMeta(pinnedByChatId[a.id], pinnedByChatId[b.id]));
    return pinnedChats;
  }

  Future<void> _handlePinnedChatReorder({
    required MessengerState currentState,
    required List<ChatEntity> pinnedChats,
    required int oldIndex,
    required int newIndex,
  }) async {
    if (_isPinnedReorderInProgress) return;
    int adjustedNewIndex = newIndex;
    if (adjustedNewIndex > oldIndex) adjustedNewIndex -= 1;
    final List<ChatEntity> local = List<ChatEntity>.from(pinnedChats);
    final ChatEntity moved = local.removeAt(oldIndex);
    local.insert(adjustedNewIndex, moved);

    setState(() {
      _isPinnedReorderInProgress = true;
      _optimisticPinnedChats = local;
    });

    if (currentState.folders.isEmpty || currentState.selectedFolderIndex >= currentState.folders.length) {
      if (!mounted) return;
      setState(() {
        _isPinnedReorderInProgress = false;
        _optimisticPinnedChats = null;
      });
      return;
    }
    final int? folderId = currentState.folders[currentState.selectedFolderIndex].id;
    if (folderId == null) {
      if (!mounted) return;
      setState(() {
        _isPinnedReorderInProgress = false;
        _optimisticPinnedChats = null;
      });
      return;
    }

    final int movedChatId = moved.id;
    final int? previousChatId = adjustedNewIndex > 0 ? local[adjustedNewIndex - 1].id : null;
    final int? nextChatId = (adjustedNewIndex + 1) < local.length ? local[adjustedNewIndex + 1].id : null;

    try {
      await context.read<MessengerCubit>().reorderPinnedChats(
        folderId: folderId,
        movedChatId: movedChatId,
        previousChatId: previousChatId,
        nextChatId: nextChatId,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isPinnedReorderInProgress = false;
        _optimisticPinnedChats = null;
      });
    }
  }
}

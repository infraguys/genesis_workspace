import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/all_chats/view/all_chats_channels.dart';
import 'package:genesis_workspace/features/all_chats/view/all_chats_dms.dart';
import 'package:genesis_workspace/features/all_chats/view/all_group_chats.dart';
import 'package:genesis_workspace/features/all_chats/view/create_folder_dialog.dart';
import 'package:genesis_workspace/features/all_chats/view/folder_pill.dart';
import 'package:genesis_workspace/features/channel_chat/channel_chat.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';
import 'package:genesis_workspace/features/chat/chat.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class AllChatsView extends StatefulWidget {
  final int? initialUserId;
  final int? initialChannelId;
  final String? initialTopicName;

  const AllChatsView({super.key, this.initialUserId, this.initialChannelId, this.initialTopicName});

  @override
  State<AllChatsView> createState() => _AllChatsViewState();
}

class _AllChatsViewState extends State<AllChatsView> {
  final double _sidebarMinWidth = 220;
  final double _sidebarMaxWidth = 600;
  final double _defaultWidth = 350;
  final double _dragHandleVisualWidth = 2;
  final double _dragHandleHitWidth = 10;

  late double _sidebarWidth;
  bool _isHandleHovered = false;
  bool _isDragging = false;
  bool _isEditPinning = false;

  late final Future _future;
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _foldersScrollController = ScrollController();

  // Folder members are now provided by AllChatsCubit state

  Color _currentFolderBackground(
    BuildContext context, {
    required int selectedIndex,
    required List<FolderItemEntity> folders,
  }) {
    if (folders.isNotEmpty && selectedIndex != 0) {
      if (folders[selectedIndex].backgroundColor == null) {
        return Theme.of(context).colorScheme.surface.withValues(alpha: 0.10);
      }
      final Color base = folders[selectedIndex].backgroundColor!;
      return base.withValues(alpha: 0.10);
    } else {
      return Theme.of(context).colorScheme.surface.withValues(alpha: 0.10);
    }
  }

  void _updateWidth(double deltaDx) {
    final double next = (_sidebarWidth + deltaDx).clamp(_sidebarMinWidth, _sidebarMaxWidth);
    if (next != _sidebarWidth) {
      setState(() => _sidebarWidth = next);
    }
  }

  Future<void> createNewFolder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (dialogContext) => CreateFolderDialog(
        onSubmit: (folder) async {
          await context.read<AllChatsCubit>().addFolder(folder);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  Future<void> editFolder(BuildContext context, FolderItemEntity folder) {
    return showDialog(
      context: context,
      builder: (dialogContext) => CreateFolderDialog(
        initial: folder,
        onSubmit: (updated) async {
          await context.read<AllChatsCubit>().updateFolder(updated);
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

  void stopEditPinning() {
    setState(() {
      _isEditPinning = false;
    });
  }

  @override
  void initState() {
    _sidebarWidth = _defaultWidth.clamp(_sidebarMinWidth, _sidebarMaxWidth).toDouble();
    if (widget.initialUserId != null) {
      context.read<DirectMessagesCubit>().selectUserChat(userId: widget.initialUserId);
    }
    _future = Future.wait([
      context.read<DirectMessagesCubit>().getUsers(),
      context.read<ChannelsCubit>().getChannels(
        initialChannelId: widget.initialChannelId,
        initialTopicName: widget.initialTopicName,
      ),
      context.read<AllChatsCubit>().loadFolders(),
    ]);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color borderIdleColor = Colors.grey.shade300;
    final Color borderActiveColor = theme.colorScheme.primary;
    final Color borderColor = (_isHandleHovered || _isDragging)
        ? borderActiveColor
        : borderIdleColor;

    final bool isDesktopWidth = currentSize(context) > ScreenSize.lTablet;

    final PreferredSizeWidget? appBar = isDesktopWidth
        ? null
        : AppBar(
            title: Text(context.t.navBar.allChats),
            centerTitle: isDesktopWidth,
            toolbarHeight: 44,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: theme.colorScheme.surface,
            actions: [
              IconButton(
                onPressed: () {
                  createNewFolder(context);
                },
                icon: Icon(Icons.add),
              ),
              if (_isEditPinning)
                IconButton(
                  onPressed: () {
                    stopEditPinning();
                  },
                  icon: Icon(Icons.check, color: Colors.green),
                ),
            ],
          );

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            if (profileState.user != null) {
              context.read<ChannelsCubit>().setSelfUser(profileState.user);
              context.read<DirectMessagesCubit>().setSelfUser(profileState.user);
            }
            return FutureBuilder(
              future: _future,
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return BlocBuilder<AllChatsCubit, AllChatsState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isDesktopWidth
                                ? _sidebarWidth
                                : MediaQuery.sizeOf(context).width,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: borderColor,
                                  width: _dragHandleVisualWidth,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (isDesktopWidth) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          context.t.folders.title,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        _isEditPinning
                                            ? IconButton(
                                                onPressed: () {
                                                  stopEditPinning();
                                                },
                                                icon: Icon(Icons.check, color: Colors.green),
                                              )
                                            : IconButton(
                                                onPressed: () => createNewFolder(context),
                                                icon: const Icon(Icons.add),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                                _FoldersList(
                                  foldersScrollController: _foldersScrollController,
                                  state: state,
                                  editFolder: editFolder,
                                  editPinning: editPinning,
                                ),
                                Expanded(
                                  child: TweenAnimationBuilder<Color?>(
                                    tween: ColorTween(
                                      begin: _currentFolderBackground(
                                        context,
                                        selectedIndex: state.selectedFolderIndex,
                                        folders: state.folders,
                                      ),
                                      end: _currentFolderBackground(
                                        context,
                                        selectedIndex: state.selectedFolderIndex,
                                        folders: state.folders,
                                      ),
                                    ),
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    builder: (context, color, _) {
                                      return ScrollConfiguration(
                                        behavior: ScrollConfiguration.of(
                                          context,
                                        ).copyWith(scrollbars: false),
                                        child: SingleChildScrollView(
                                          child: Container(
                                            color: color,
                                            child: state.isEmptyFolder
                                                ? Center(
                                                    child: Text(context.t.folders.folderIsEmpty),
                                                  )
                                                : Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      AllChatsDms(
                                                        key: const ValueKey('dms-chats'),
                                                        filteredDms: state.filterDmUserIds,
                                                        selectedFolder: state
                                                            .folders[state.selectedFolderIndex],
                                                        isEditPinning: _isEditPinning,
                                                      ),
                                                      AllGroupChats(
                                                        key: const ValueKey('group-chats'),
                                                        filteredGroupChatIds:
                                                            state.filterGroupChatIds,
                                                        selectedFolder: state
                                                            .folders[state.selectedFolderIndex],
                                                        isEditPinning: _isEditPinning,
                                                      ),
                                                      const Divider(height: 1),
                                                      AllChatsChannels(
                                                        key: const ValueKey('channels-chats'),
                                                        filterChannelIds: state.filterChannelIds,
                                                        selectedFolder: state
                                                            .folders[state.selectedFolderIndex],
                                                        isEditPinning: _isEditPinning,
                                                      ),
                                                    ],
                                                  ),
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
                        if (isDesktopWidth)
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: BlocBuilder<AllChatsCubit, AllChatsState>(
                                    buildWhen: (prev, current) =>
                                        prev.selectedDmChat != current.selectedDmChat ||
                                        prev.selectedChannel != current.selectedChannel ||
                                        prev.selectedTopic != current.selectedTopic ||
                                        prev.selectedGroupChat != current.selectedGroupChat,
                                    builder: (context, selectedChatState) {
                                      if (selectedChatState.selectedDmChat != null) {
                                        return Chat(
                                          key: ObjectKey(selectedChatState.selectedDmChat!.userId),
                                          userIds: [selectedChatState.selectedDmChat!.userId],
                                          unreadMessagesCount: selectedChatState
                                              .selectedDmChat!
                                              .unreadMessages
                                              .length,
                                        );
                                      }
                                      if (selectedChatState.selectedChannel != null) {
                                        return ChannelChat(
                                          key: ObjectKey(
                                            selectedChatState.selectedChannel!.streamId,
                                          ),
                                          channelId: selectedChatState.selectedChannel!.streamId,
                                          topicName: selectedChatState.selectedTopic?.name,
                                        );
                                      }
                                      if (selectedChatState.selectedGroupChat != null) {
                                        return Chat(
                                          key: ObjectKey(
                                            selectedChatState.selectedGroupChat.hashCode,
                                          ),
                                          userIds: selectedChatState.selectedGroupChat!.toList(),
                                        );
                                      }
                                      return Center(child: Text(context.t.selectAnyChat));
                                    },
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  width: _dragHandleHitWidth,
                                  child: MouseRegion(
                                    onEnter: (_) => setState(() => _isHandleHovered = true),
                                    onExit: (_) => setState(() => _isHandleHovered = false),
                                    cursor: SystemMouseCursors.resizeColumn,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onHorizontalDragStart: (_) =>
                                          setState(() => _isDragging = true),
                                      onHorizontalDragUpdate: (details) =>
                                          _updateWidth(details.delta.dx),
                                      onHorizontalDragEnd: (_) =>
                                          setState(() => _isDragging = false),
                                      onDoubleTap: () {
                                        setState(() {
                                          _sidebarWidth = _defaultWidth
                                              .clamp(_sidebarMinWidth, _sidebarMaxWidth)
                                              .toDouble();
                                        });
                                      },
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FoldersList extends StatelessWidget {
  final ScrollController foldersScrollController;
  final AllChatsState state;
  final Function editFolder;
  final Function editPinning;

  const _FoldersList({
    super.key,
    required this.foldersScrollController,
    required this.state,
    required this.editFolder,
    required this.editPinning,
  });

  int _computeUnreadForFolder({
    required FolderItemEntity folder,
    required ChannelsState channelsState,
    required DirectMessagesState dmsState,
    required Map<int, FolderMembers> folderMembers,
  }) {
    if (folder.id == 0 || folder.systemType == SystemFolderType.all) {
      final int dmUnread = dmsState.users.fold(0, (sum, u) => sum + u.unreadMessages.length);
      final int chUnread = channelsState.channels
          .where((c) => !c.isMuted)
          .fold(0, (sum, c) => sum + c.unreadMessages.length);
      final int groupUnread = dmsState.groupChats.fold(0, (sum, g) => sum + g.unreadMessagesCount);
      return dmUnread + chUnread + groupUnread;
    }

    final int? fid = folder.id;
    if (fid == null) return 0;
    final FolderMembers? members = folderMembers[fid];
    if (members == null) return 0;
    final Set<int> dmIds = members.dmUserIds.toSet();
    final Set<int> chIds = members.channelIds.toSet();
    final Set<int> groupIds = members.groupChatIds.toSet();
    final int dmUnread = dmsState.users
        .where((u) => dmIds.contains(u.userId))
        .fold(0, (sum, u) => sum + u.unreadMessages.length);
    final int chUnread = channelsState.channels
        .where((c) => chIds.contains(c.streamId) && !c.isMuted)
        .fold(0, (sum, c) => sum + c.unreadMessages.length);
    final int groupUnread = dmsState.groupChats
        .where((group) => groupIds.contains(group.id))
        .fold(0, (sum, group) => sum + group.unreadMessagesCount);
    return dmUnread + chUnread + groupUnread;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: BlocBuilder<ChannelsCubit, ChannelsState>(
          builder: (context, channelsState) =>
              BlocBuilder<DirectMessagesCubit, DirectMessagesState>(
                builder: (context, dmsState) => ListView.builder(
                  controller: foldersScrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.folders.length,
                  itemBuilder: (context, index) {
                    final FolderItemEntity folder = state.folders[index];
                    final bool isSelected = state.selectedFolderIndex == index;
                    final int unread = _computeUnreadForFolder(
                      folder: folder,
                      channelsState: channelsState,
                      dmsState: dmsState,
                      folderMembers: state.folderMembersById,
                    );

                    return FolderPill(
                      isSelected: isSelected,
                      folder: index == 0 ? folder.copyWith(title: context.t.folders.all) : folder,
                      unreadCount: unread,
                      onTap: () => context.read<AllChatsCubit>().selectFolder(index),
                      onEdit: (folder.systemType == null)
                          ? () => editFolder(context, folder)
                          : null,
                      onEditPinning: () => editPinning(),
                      onDelete: (folder.systemType == null)
                          ? () async {
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
                                await context.read<AllChatsCubit>().deleteFolder(folder);
                              }
                            }
                          : null,
                    );
                  },
                ),
              ),
        ),
      ),
    );
  }
}

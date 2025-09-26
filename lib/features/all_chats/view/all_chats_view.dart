import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/all_chats/view/all_chats_channels.dart';
import 'package:genesis_workspace/features/all_chats/view/all_chats_dms.dart';
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

  late final Future _future;
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _foldersScrollController = ScrollController();

  Color _currentFolderBackground(
    BuildContext context, {
    required int selectedIndex,
    required List<FolderItemEntity> folders,
  }) {
    if (folders.isNotEmpty) {
      if (folders[selectedIndex].backgroundColor == null) {
        return Theme.of(context).colorScheme.surface;
      }
      final Color base = folders[selectedIndex].backgroundColor!;
      return base.withValues(alpha: 0.10);
    } else {
      return Theme.of(context).colorScheme.surface;
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
    final Color borderIdleColor = Colors.grey.shade300;
    final Color borderActiveColor = Theme.of(context).colorScheme.primary;
    final Color borderColor = (_isHandleHovered || _isDragging)
        ? borderActiveColor
        : borderIdleColor;

    final bool isDesktopWidth = currentSize(context) > ScreenSize.lTablet;

    final PreferredSizeWidget appBar = isDesktopWidth
        ? WorkspaceAppBar(title: context.t.navBar.allChats)
        : AppBar(
            title: Text(context.t.navBar.allChats),
            centerTitle: false,
            toolbarHeight: 44,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  createNewFolder(context);
                },
                icon: Icon(Icons.add),
              ),
            ],
          );

    return Scaffold(
      appBar: appBar,
      body: BlocBuilder<ProfileCubit, ProfileState>(
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
                buildWhen: (prev, cur) =>
                    prev.selectedFolderIndex != cur.selectedFolderIndex ||
                    prev.folders != cur.folders ||
                    prev.filterDmUserIds != cur.filterDmUserIds ||
                    prev.filterChannelIds != cur.filterChannelIds,
                builder: (context, state) {
                  if (isDesktopWidth) {
                    return Row(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: _sidebarWidth),
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        context.t.folders.title,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      IconButton(
                                        onPressed: () => createNewFolder(context),
                                        icon: const Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 46,
                                  child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(
                                      context,
                                    ).copyWith(scrollbars: false),
                                    child: ListView.builder(
                                      controller: _foldersScrollController,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: state.folders.length,
                                      itemBuilder: (context, index) {
                                        final FolderItemEntity folder = state.folders[index];
                                        final bool isSelected = state.selectedFolderIndex == index;
                                        return FolderPill(
                                          isSelected: isSelected,
                                          folder: folder,
                                          onTap: () =>
                                              context.read<AllChatsCubit>().selectFolder(index),
                                          onEdit: (folder.systemType == null)
                                              ? () => editFolder(context, folder)
                                              : null,
                                          onDelete: (folder.systemType == null)
                                              ? () async {
                                                  final confirmed = await showDialog<bool>(
                                                    context: context,
                                                    builder: (dialogContext) => AlertDialog(
                                                      title: Text(
                                                        context.t.folders.deleteConfirmTitle,
                                                      ),
                                                      content: Text(
                                                        context.t.folders.deleteConfirmText(
                                                          folderName: folder.title ?? '',
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.of(
                                                            dialogContext,
                                                          ).pop(false),
                                                          child: Text(context.t.folders.cancel),
                                                        ),
                                                        FilledButton(
                                                          onPressed: () =>
                                                              Navigator.of(dialogContext).pop(true),
                                                          child: Text(context.t.folders.delete),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  if (confirmed == true) {
                                                    await context
                                                        .read<AllChatsCubit>()
                                                        .deleteFolder(folder);
                                                  }
                                                }
                                              : null,
                                        );
                                      },
                                    ),
                                  ),
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
                                                        filteredDms: state.filterDmUserIds,
                                                      ),
                                                      const Divider(height: 1),
                                                      AllChatsChannels(
                                                        filterChannelIds: state.filterChannelIds,
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
                                        prev.selectedTopic != current.selectedTopic,
                                    builder: (context, selectedChatState) {
                                      if (selectedChatState.selectedDmChat != null) {
                                        return Chat(
                                          key: ObjectKey(selectedChatState.selectedDmChat!.userId),
                                          userId: selectedChatState.selectedDmChat!.userId,
                                          unreadMessagesCount: selectedChatState
                                              .selectedDmChat
                                              ?.unreadMessages
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
                                      return Center(child: Text(context.t.selectAnyChat));
                                    },
                                  ),
                                ),
                                // ресайз-хэндл без изменений
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
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 46,
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(
                                    context,
                                  ).copyWith(scrollbars: false),
                                  child: ListView.builder(
                                    controller: _foldersScrollController,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ).copyWith(right: 64),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: state.folders.length,
                                    itemBuilder: (context, index) {
                                      final FolderItemEntity folder = state.folders[index];
                                      final bool isSelected = state.selectedFolderIndex == index;

                                      return FolderPill(
                                        isSelected: isSelected,
                                        folder: folder,
                                        onTap: () =>
                                            context.read<AllChatsCubit>().selectFolder(index),
                                        onEdit: (folder.systemType == null)
                                            ? () => editFolder(context, folder)
                                            : null,
                                        onDelete: (folder.systemType == null)
                                            ? () async {
                                                final confirmed = await showDialog<bool>(
                                                  context: context,
                                                  builder: (dialogContext) => AlertDialog(
                                                    title: Text(
                                                      context.t.folders.deleteConfirmTitle,
                                                    ),
                                                    content: Text(
                                                      context.t.folders.deleteConfirmText(
                                                        folderName: folder.title ?? '',
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(dialogContext).pop(false),
                                                        child: Text(context.t.folders.cancel),
                                                      ),
                                                      FilledButton(
                                                        onPressed: () =>
                                                            Navigator.of(dialogContext).pop(true),
                                                        child: Text(context.t.folders.delete),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirmed == true) {
                                                  await context.read<AllChatsCubit>().deleteFolder(
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
                            ),
                            SliverToBoxAdapter(
                              child: AllChatsDms(
                                filteredDms: state.filterDmUserIds,
                                embeddedInParentScroll: true,
                              ),
                            ),
                            // Channels (встроено в общий скролл)
                            SliverToBoxAdapter(
                              child: AllChatsChannels(
                                filterChannelIds: state.filterChannelIds,
                                embeddedInParentScroll: true,
                              ),
                            ),
                            if (state.isEmptyFolder)
                              SliverPadding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                sliver: SliverToBoxAdapter(
                                  child: Center(child: Text(context.t.folders.folderIsEmpty)),
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
    );
  }
}

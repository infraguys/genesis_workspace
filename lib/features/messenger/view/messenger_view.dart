import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/features/all_chats/view/create_folder_dialog.dart';
import 'package:genesis_workspace/features/channel_chat/channel_chat.dart';
import 'package:genesis_workspace/features/chat/chat.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/chat_item.dart';
import 'package:genesis_workspace/features/messenger/view/chat_reorder_item.dart';
import 'package:genesis_workspace/features/messenger/view/folder_item.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class MessengerView extends StatefulWidget {
  const MessengerView({super.key});

  @override
  State<MessengerView> createState() => _MessengerViewState();
}

class _MessengerViewState extends State<MessengerView> {
  Future<void>? _future;

  bool _isEditPinning = false;
  List<ChatEntity>? _optimisticPinnedChats;
  bool _isPinnedReorderInProgress = false;

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

  Future<void> getInitialData() async {
    await Future.wait([
      context.read<MessengerCubit>().loadFolders(),
      context.read<MessengerCubit>().getMessages(),
    ]);
  }

  @override
  void initState() {
    _future = getInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    final cardColors = Theme.of(context).extension<CardColors>()!;

    return BlocListener<OrganizationsCubit, OrganizationsState>(
      listenWhen: (previous, current) => previous.selectedOrganizationId != current.selectedOrganizationId,
      listener: (context, state) {
        context.read<MessengerCubit>().resetState();
        setState(() {
          _future = getInitialData();
        });
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
                final List<ChatEntity> visibleChats = state.filteredChatIds == null
                    ? state.chats
                    : state.chats.where((chat) => state.filteredChatIds!.contains(chat.id)).toList();
                final List<ChatEntity> pinnedChatsForEdit =
                    _optimisticPinnedChats ?? _pinnedChatsForEdit(visibleChats, state.pinnedChats);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (currentSize(context) > ScreenSize.tablet)
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: 60,
                          child: CustomScrollView(
                            slivers: [
                              SliverList.separated(
                                itemCount: state.folders.length,
                                separatorBuilder: (_, _) => SizedBox(height: 28),
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
                                    onEdit: (folder.systemType == null) ? () => editFolder(context, folder) : null,
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
                              SliverToBoxAdapter(child: SizedBox(height: 28)),
                              SliverToBoxAdapter(
                                child: IconButton(
                                  onPressed: () {
                                    createNewFolder(context);
                                  },
                                  icon: Assets.icons.add.svg(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: currentSize(context) <= ScreenSize.tablet ? MediaQuery.sizeOf(context).width : 315,
                      ),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: currentSize(context) <= ScreenSize.tablet
                            ? theme.colorScheme.background
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: CustomScrollView(
                          slivers: [
                            SliverAppBar(
                              automaticallyImplyLeading: false,
                              backgroundColor: currentSize(context) <= ScreenSize.tablet
                                  ? theme.colorScheme.background
                                  : theme.colorScheme.surface,
                              elevation: 0,
                              scrolledUnderElevation: 10,
                              titleSpacing: 0,
                              centerTitle: currentSize(context) <= ScreenSize.tablet,
                              floating: true,
                              snap: true,
                              pinned: false,
                              leading: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {},
                                icon: Assets.icons.menu.svg(
                                  width: 32,
                                  height: 32,
                                  colorFilter: ColorFilter.mode(
                                    theme.colorScheme.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              actionsPadding: EdgeInsets.symmetric(horizontal: 8),
                              title: currentSize(context) > ScreenSize.tablet
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 20,
                                      ).copyWith(bottom: 0),
                                      child: Text(
                                        state.selectedFolderIndex != 0
                                            ? state.folders[state.selectedFolderIndex].title!
                                            : context.t.messengerView.chatsAndChannels,
                                        style: theme.textTheme.labelLarge?.copyWith(fontSize: 16),
                                      ),
                                    )
                                  : Text(
                                      context.t.messenger,
                                      style: theme.textTheme.labelLarge?.copyWith(fontSize: 16),
                                    ),
                              actions: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {},
                                  icon: Assets.icons.editSquare.svg(width: 32, height: 32),
                                ),
                                if (_isEditPinning)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isEditPinning = false;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                  ),
                              ],
                              bottom: PreferredSize(
                                preferredSize: Size.fromHeight(
                                  currentSize(context) <= ScreenSize.tablet ? 96 : 48,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: currentSize(context) > ScreenSize.tablet
                                          ? EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 12)
                                          : EdgeInsets.symmetric(horizontal: 20).copyWith(top: 14, bottom: 20),
                                      child: Row(
                                        spacing: 8,
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 36,
                                              child: TextField(
                                                style: TextStyle(fontSize: 14),
                                                decoration: InputDecoration(
                                                  hintText: context.t.general.find,
                                                  suffixIcon: currentSize(context) > ScreenSize.tablet
                                                      ? Align(
                                                          widthFactor: 1.0,
                                                          heightFactor: 1.0,
                                                          child: Assets.icons.search.svg(
                                                            width: 20,
                                                            height: 20,
                                                          ),
                                                        )
                                                      : null,
                                                  prefixIcon: currentSize(context) <= ScreenSize.tablet
                                                      ? Align(
                                                          widthFactor: 1.0,
                                                          heightFactor: 1.0,
                                                          child: Assets.icons.search.svg(
                                                            width: 20,
                                                            height: 20,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (currentSize(context) > ScreenSize.tablet)
                                            SizedBox(
                                              height: 32,
                                              width: 32,
                                              child: IconButton(
                                                onPressed: () {
                                                  unawaited(createNewFolder(context));
                                                },
                                                icon: Assets.icons.add.svg(),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (currentSize(context) <= ScreenSize.tablet)
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: theme.dividerColor,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        height: 24,
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          physics: BouncingScrollPhysics(),
                                          padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: state.folders.length + 1,
                                          separatorBuilder: (_, __) => SizedBox(width: 32),
                                          itemBuilder: (context, index) {
                                            if (index == state.folders.length) {
                                              return GestureDetector(
                                                onTap: () => unawaited(createNewFolder(context)),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  spacing: 4,
                                                  children: [
                                                    Text(
                                                      context.t.folders.create,
                                                      style: theme.textTheme.labelLarge?.copyWith(
                                                        color: textColors.text100,
                                                      ),
                                                    ),
                                                    Assets.icons.add.svg(
                                                      width: 14,
                                                      height: 14,
                                                      colorFilter: ColorFilter.mode(
                                                        textColors.text100,
                                                        BlendMode.srcIn,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                            final folder = state.folders[index];
                                            final bool isSelected = state.selectedFolderIndex == index;
                                            final String title = index == 0
                                                ? context.t.folders.all
                                                : folder.title ?? '';
                                            return FolderItem(
                                              title: title,
                                              folder: folder,
                                              isSelected: isSelected,
                                              onTap: () => context.read<MessengerCubit>().selectFolder(index),
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
                                  ],
                                ),
                              ),
                            ),
                            if (visibleChats.isEmpty)
                              SliverPadding(
                                padding: EdgeInsetsGeometry.symmetric(vertical: 20),
                                sliver: SliverToBoxAdapter(
                                  child: Center(
                                    child: Text(context.t.folders.folderIsEmpty),
                                  ),
                                ),
                              ),
                            SliverPadding(
                              padding: EdgeInsetsGeometry.symmetric(horizontal: 8, vertical: 20),
                              sliver: _isEditPinning
                                  ? SliverReorderableList(
                                      itemCount: pinnedChatsForEdit.length,
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
                                    )
                                  : SliverList.separated(
                                      itemCount: visibleChats.length,
                                      separatorBuilder: (_, _) => SizedBox(height: 4),
                                      itemBuilder: (BuildContext context, int index) {
                                        final chat = visibleChats[index];
                                        return ChatItem(
                                          key: ValueKey(chat.id),
                                          chat: chat,
                                          onTap: () {
                                            context.read<MessengerCubit>().selectChat(chat);
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (currentSize(context) > ScreenSize.tablet) ...[
                      SizedBox(width: 4),
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
                  ],
                );
              },
            );
          },
        ),
      ),
    );
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

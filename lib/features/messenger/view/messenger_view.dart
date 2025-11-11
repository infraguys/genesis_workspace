import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/features/all_chats/view/create_folder_dialog.dart';
import 'package:genesis_workspace/features/channel_chat/channel_chat.dart';
import 'package:genesis_workspace/features/chat/chat.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/chat_item.dart';
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
      // context.read<MessengerCubit>().getPinnedChats(),
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
                final List<ChatEntity> visibleChats = (state.filteredChatIds?.isEmpty ?? true)
                    ? state.chats
                    : state.chats.where((chat) => state.filteredChatIds!.contains(chat.id)).toList();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
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
                      constraints: BoxConstraints(maxWidth: 315),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: CustomScrollView(
                          slivers: [
                            SliverAppBar(
                              automaticallyImplyLeading: false,
                              backgroundColor: theme.colorScheme.surface,
                              elevation: 0,
                              scrolledUnderElevation: 0,
                              titleSpacing: 0,
                              // toolbarHeight: 24,
                              centerTitle: false,
                              floating: true,
                              snap: true,
                              pinned: true,
                              title: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 20,
                                ).copyWith(bottom: 0),
                                child: Text(
                                  'Чаты и каналы',
                                  style: theme.textTheme.labelLarge?.copyWith(fontSize: 16),
                                ),
                              ),
                              bottom: PreferredSize(
                                preferredSize: Size.fromHeight(56),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 12),
                                  child: Row(
                                    spacing: 8,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          style: TextStyle(fontSize: 14),
                                          decoration: InputDecoration(
                                            hintText: context.t.general.find,
                                            constraints: BoxConstraints(maxHeight: 32),
                                            suffixIcon: Align(
                                              widthFactor: 1.0,
                                              heightFactor: 1.0,
                                              child: Assets.icons.search.svg(
                                                width: 20,
                                                height: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
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
                              ),
                            ),
                            if (visibleChats.isEmpty)
                              SliverToBoxAdapter(
                                child: Center(
                                  child: Text(context.t.folders.folderIsEmpty),
                                ),
                              ),
                            SliverPadding(
                              padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
                              sliver: SliverList.separated(
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}

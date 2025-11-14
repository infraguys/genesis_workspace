import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/mixins/chat/open_dm_chat_mixin.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/features/all_chats/view/create_group_chat_dialog.dart';
import 'package:genesis_workspace/features/messenger/view/folder_item.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MessengerAppBar extends StatelessWidget with OpenDmChatMixin {
  const MessengerAppBar({
    super.key,
    required this.theme,
    required this.textColors,
    required this.isLargeScreen,
    required this.searchSectionPadding,
    required this.searchSectionHeight,
    required this.searchVisibility,
    required this.folders,
    required this.selectedFolderIndex,
    required this.onSelectFolder,
    required this.onCreateFolder,
    required this.onEditFolder,
    required this.onOrderPinning,
    required this.onDeleteFolder,
    required this.isEditPinning,
    required this.onStopEditingPins,
    required this.showSearchField,
    required this.selfUserId,
  });

  final ThemeData theme;
  final TextColors textColors;
  final bool isLargeScreen;
  final EdgeInsetsGeometry searchSectionPadding;
  final double searchSectionHeight;
  final double searchVisibility;
  final List<FolderItemEntity> folders;
  final int selectedFolderIndex;
  final void Function(int index) onSelectFolder;
  final VoidCallback onCreateFolder;
  final Future<void> Function(FolderItemEntity folder)? onEditFolder;
  final void Function(BuildContext context, int index) onOrderPinning;
  final Future<void> Function(BuildContext context, FolderItemEntity folder)? onDeleteFolder;
  final bool isEditPinning;
  final VoidCallback onStopEditingPins;
  final bool showSearchField;
  final int selfUserId;

  bool get isTabletOrSmaller => !isLargeScreen;

  @override
  Widget build(BuildContext context) {
    final double searchHeight = searchSectionHeight * searchVisibility;
    final double foldersStripHeight = isTabletOrSmaller ? 24 : 0;
    final double appBarBottomHeight = searchHeight + foldersStripHeight;
    final t = context.t;
    final String largeScreenTitle = selectedFolderIndex != 0
        ? folders[selectedFolderIndex].title ?? ''
        : t.messengerView.chatsAndChannels;

    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: isTabletOrSmaller ? theme.colorScheme.background : theme.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 10,
      titleSpacing: 0,
      centerTitle: isTabletOrSmaller,
      floating: !isTabletOrSmaller,
      snap: false,
      pinned: isTabletOrSmaller,
      leading: isTabletOrSmaller
          ? IconButton(
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
            )
          : null,
      actionsPadding: EdgeInsets.symmetric(horizontal: 8),
      title: isLargeScreen
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20).copyWith(bottom: 0),
              child: Text(
                largeScreenTitle,
                style: theme.textTheme.labelLarge?.copyWith(fontSize: 16),
              ),
            )
          : Text(
              t.messenger,
              style: theme.textTheme.labelLarge?.copyWith(fontSize: 16),
            ),
      actions: [
        if (isTabletOrSmaller)
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              try {
                await showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return CreateGroupChatDialog(
                      onCreate: (membersIds) {
                        Navigator.of(dialogContext).pop();
                        openChat(context, {...membersIds, selfUserId});
                      },
                    );
                  },
                );
              } catch (e) {
                inspect(e);
              } finally {
                // context.read<DirectMessagesCubit>().setCreateGroupChatOpened(false);
              }
            },
            icon: Assets.icons.editSquare.svg(width: 32, height: 32),
          ),
        if (isEditPinning)
          IconButton(
            onPressed: onStopEditingPins,
            icon: Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(appBarBottomHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: searchVisibility.clamp(0.0, 1.0),
                child: Opacity(
                  opacity: showSearchField ? searchVisibility.clamp(0.0, 1.0) : 0,
                  child: Padding(
                    padding: searchSectionPadding,
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: isTabletOrSmaller ? 36 : 32,
                            child: TextField(
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: t.general.find,
                                suffixIcon: isLargeScreen
                                    ? Align(
                                        widthFactor: 1.0,
                                        heightFactor: 1.0,
                                        child: Assets.icons.search.svg(
                                          width: 20,
                                          height: 20,
                                        ),
                                      )
                                    : null,
                                prefixIcon: isTabletOrSmaller
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
                        if (isLargeScreen)
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: onCreateFolder,
                              icon: Assets.icons.newWindow.svg(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (isTabletOrSmaller)
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
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: folders.length + 1,
                  separatorBuilder: (_, int index) => SizedBox(width: index == folders.length - 1 ? 8 : 32),
                  itemBuilder: (context, index) {
                    if (index == folders.length) {
                      return IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: onCreateFolder,
                        icon: Assets.icons.add.svg(
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(
                            textColors.text100,
                            BlendMode.srcIn,
                          ),
                        ),
                      );
                    }
                    final folder = folders[index];
                    final bool isSelected = selectedFolderIndex == index;
                    final String title = index == 0 ? t.folders.all : folder.title ?? '';
                    return FolderItem(
                      title: title,
                      folder: folder,
                      isSelected: isSelected,
                      onTap: () => onSelectFolder(index),
                      onEdit: (folder.systemType == null && onEditFolder != null) ? () => onEditFolder!(folder) : null,
                      onOrderPinning: () => onOrderPinning(context, index),
                      onDelete: (folder.systemType == null && onDeleteFolder != null)
                          ? () => onDeleteFolder!(context, folder)
                          : null,
                      icon: const SizedBox.shrink(),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

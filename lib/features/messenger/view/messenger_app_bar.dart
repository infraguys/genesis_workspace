import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/enums/folder_system_type.dart';
import 'package:genesis_workspace/core/mixins/chat/open_chat_mixin.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/features/messenger/view/folder_item.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MessengerAppBar extends StatelessWidget with OpenChatMixin {
  const MessengerAppBar({
    super.key,
    required this.isLargeScreen,
    required this.searchVisibility,
    required this.folders,
    required this.selectedFolderIndex,
    required this.onSelectFolder,
    required this.onCreateFolder,
    required this.onEditFolder,
    required this.onOrderPinning,
    required this.onDeleteFolder,
    required this.isEditPinning,
    required this.isSavingPinnedOrder,
    required this.onStopEditingPins,
    required this.showSearchField,
    required this.selfUserId,
    required this.showTopics,
    required this.onTapBack,
    required this.onClearSearch,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    this.selectedChatLabel,
    required this.isLoadingMore,
    required this.onShowChats,
  });

  final bool isLargeScreen;
  final double searchVisibility;
  final List<FolderEntity> folders;
  final int selectedFolderIndex;
  final void Function(int index) onSelectFolder;
  final VoidCallback onCreateFolder;
  final Future<void> Function(FolderEntity folder)? onEditFolder;
  final void Function(BuildContext context, int index) onOrderPinning;
  final Future<void> Function(BuildContext context, FolderEntity folder)? onDeleteFolder;
  final bool isEditPinning;
  final bool isSavingPinnedOrder;
  final VoidCallback onStopEditingPins;
  final bool showSearchField;
  final int selfUserId;
  final bool showTopics;
  final VoidCallback onTapBack;
  final String? selectedChatLabel;
  final VoidCallback onClearSearch;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final bool isLoadingMore;
  final ValueChanged<Offset> onShowChats;

  bool get isTabletOrSmaller => !isLargeScreen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    final t = context.t;
    final String largeScreenTitle = selectedFolderIndex != 0
        ? folders[selectedFolderIndex].title
        : t.messengerView.chatsAndChannels;

    final Widget titleWidget = BlocBuilder<RealTimeCubit, RealTimeState>(
      builder: (context, state) {
        return isLargeScreen
            ? Text(
                state.isConnecting ? "${context.t.connecting}..." : largeScreenTitle,
                style: theme.textTheme.labelLarge?.copyWith(fontSize: 16),
              )
            : Text(
                state.isConnecting
                    ? "${context.t.connecting}..."
                    : showTopics
                    ? selectedChatLabel!
                    : context.t.messenger,
                style: theme.textTheme.labelLarge?.copyWith(fontSize: 16),
              );
      },
    );

    final List<Widget> actions = [];
    if (isTabletOrSmaller) {
      actions.add(
        InkWell(
          customBorder: const CircleBorder(),
          onTapDown: (details) => onShowChats(details.globalPosition),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Assets.icons.editSquare.svg(width: 32, height: 32),
          ),
        ),
      );
    }
    if (isEditPinning) {
      actions.add(
        isSavingPinnedOrder
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                onPressed: onStopEditingPins,
                icon: Icon(
                  Icons.check,
                  color: Colors.green,
                ),
              ),
      );
    }

    final double clampedVisibility = searchVisibility.clamp(0.0, 1.0);

    return Material(
      color: isTabletOrSmaller ? theme.colorScheme.background : theme.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 20.0,
            width: double.infinity,
          ),
          Padding(
            padding: isLargeScreen
                ? EdgeInsets.symmetric(horizontal: 8).copyWith(top: 20, bottom: 8)
                : EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                if (isTabletOrSmaller) ...[
                  IconButton(
                    onPressed: () {
                      if (showTopics) {
                        onTapBack();
                        return;
                      }
                      Scaffold.of(context).openDrawer();
                    },
                    icon: showTopics
                        ? Icon(Icons.arrow_back_ios)
                        : Assets.icons.menu.svg(
                            width: 32,
                            height: 32,
                            colorFilter: ColorFilter.mode(
                              theme.colorScheme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                  ),
                  SizedBox(width: 8),
                ],
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: BlocBuilder<RealTimeCubit, RealTimeState>(
                      builder: (context, state) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            isTabletOrSmaller
                                ? Center(child: titleWidget)
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: titleWidget,
                                  ),
                            if (isLoadingMore || state.isConnecting)
                              SizedBox(
                                height: 14,
                                child: CupertinoActivityIndicator(
                                  radius: 7,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                if (actions.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions
                        .map(
                          (action) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: action,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
          ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: clampedVisibility,
              child: Opacity(
                opacity: showSearchField ? clampedVisibility : 0,
                child: Padding(
                  padding: isLargeScreen
                      ? EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 12)
                      : EdgeInsets.symmetric(horizontal: 20).copyWith(top: 14, bottom: 20),
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: isTabletOrSmaller ? 36 : 32,
                          child: TextField(
                            controller: searchController,
                            style: TextStyle(fontSize: 14),
                            onChanged: onSearchChanged,
                            decoration: InputDecoration(
                              hintText: t.general.find,
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      onPressed: onClearSearch,
                                      padding: .zero,
                                      iconSize: 20,
                                      icon: Icon(
                                        Icons.close,
                                      ),
                                    )
                                  : isLargeScreen
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
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTapDown: (details) => onShowChats(details.globalPosition),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Assets.icons.newWindow.svg(),
                              ),
                            ),
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
                  final String title = index == 0 ? t.folders.all : folder.title;
                  return FolderItem(
                    title: title,
                    folder: folder,
                    isSelected: isSelected,
                    onTap: () {
                      onSelectFolder(index);
                      if (showTopics) {
                        onTapBack();
                      }
                    },
                    onEdit: (folder.systemType != FolderSystemType.all && onEditFolder != null)
                        ? () => onEditFolder!(folder)
                        : null,
                    onOrderPinning: () => onOrderPinning(context, index),
                    onDelete: (folder.systemType != FolderSystemType.all && onDeleteFolder != null)
                        ? () => onDeleteFolder!(context, folder)
                        : null,
                    icon: const SizedBox.shrink(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

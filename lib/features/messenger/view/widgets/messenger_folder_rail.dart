import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/enums/folder_system_type.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/features/messenger/view/folder_item.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MessengerFolderRail extends StatelessWidget {
  const MessengerFolderRail({
    super.key,
    required this.folders,
    required this.selectedFolderIndex,
    required this.onSelectFolder,
    required this.onCreateFolder,
    required this.onEditFolder,
    required this.onOrderPinning,
    required this.onDeleteFolder,
  });

  final List<FolderEntity> folders;
  final int selectedFolderIndex;
  final ValueChanged<int> onSelectFolder;
  final VoidCallback onCreateFolder;
  final Future<void> Function(FolderEntity folder)? onEditFolder;
  final void Function(int index) onOrderPinning;
  final Future<void> Function(FolderEntity folder)? onDeleteFolder;

  @override
  Widget build(BuildContext context) {
    final textColors = Theme.of(context).extension<TextColors>()!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: folders.length,
                separatorBuilder: (_, __) => SizedBox(height: 28),
                itemBuilder: (BuildContext context, int index) {
                  final FolderEntity folder = folders[index];
                  final bool isSelected = selectedFolderIndex == index;
                  Widget icon;
                  final String title = index == 0 ? context.t.folders.all : folder.title!;
                  if (index == 0) {
                    icon = Assets.icons.allChats.svg(
                      colorFilter: ColorFilter.mode(
                        isSelected ? folder.backgroundColor : textColors.text30,
                        BlendMode.srcIn,
                      ),
                    );
                  } else if (isSelected) {
                    icon = Assets.icons.folderOpen.svg(
                      colorFilter: ColorFilter.mode(
                        isSelected ? folder.backgroundColor : textColors.text30,
                        BlendMode.srcIn,
                      ),
                    );
                  } else {
                    icon = Assets.icons.folder.svg(
                      colorFilter: ColorFilter.mode(
                        isSelected ? folder.backgroundColor : textColors.text30,
                        BlendMode.srcIn,
                      ),
                    );
                  }
                  return FolderItem(
                    title: title,
                    folder: folder,
                    isSelected: isSelected,
                    icon: icon,
                    onTap: () => onSelectFolder(index),
                    onEdit: folder.systemType != FolderSystemType.all
                        ? () {
                            if (onEditFolder != null) onEditFolder!(folder);
                          }
                        : null,
                    onOrderPinning: () => onOrderPinning(index),
                    onDelete: folder.systemType != FolderSystemType.all
                        ? () {
                            if (onDeleteFolder != null) onDeleteFolder!(folder);
                          }
                        : null,
                  );
                },
              ),
            ),
            SizedBox(height: 28),
            IconButton(
              onPressed: onCreateFolder,
              icon: Assets.icons.add.svg(),
            ),
          ],
        ),
      ),
    );
  }
}

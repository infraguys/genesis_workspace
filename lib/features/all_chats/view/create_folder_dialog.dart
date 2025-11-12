import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class CreateFolderDialog extends StatefulWidget {
  final Function(FolderItemEntity folder) onSubmit;
  final FolderItemEntity? initial;
  const CreateFolderDialog({super.key, required this.onSubmit, this.initial});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final TextEditingController titleController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();

  IconData? selectedIconData;
  Color? selectedColor;

  bool get isCreateEnabled => titleController.text.trim().isNotEmpty && selectedIconData != null;

  @override
  void initState() {
    super.initState();
    selectedIconData = widget.initial?.iconData ?? Icons.folder;
    selectedColor = widget.initial?.backgroundColor ?? AppConstants.folderColors.first;
    if (widget.initial?.title != null) {
      titleController.text = widget.initial!.title!;
    }
    titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    titleController.dispose();
    titleFocusNode.dispose();
    super.dispose();
  }

  FolderItemEntity onSubmitPressed() {
    final int? organizationId = widget.initial?.organizationId ?? AppConstants.selectedOrganizationId;
    if (organizationId == null) {
      throw StateError('Organization is not selected');
    }
    final FolderItemEntity folder = FolderItemEntity(
      id: widget.initial?.id,
      title: titleController.text.trim(),
      iconData: selectedIconData!,
      backgroundColor: selectedColor,
      pinnedChats: widget.initial?.pinnedChats ?? [],
      organizationId: organizationId,
    );
    return folder;
  }

  @override
  Widget build(BuildContext context) {
    final double maxDialogWidth = 520;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double dialogWidth = math.min(screenWidth - 32, maxDialogWidth);
    final double dialogHeight = math.min(screenHeight * 0.9, 640);
    final BorderRadius dialogRadius = BorderRadius.circular(16);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: dialogRadius),
      child: SafeArea(
        child: ClipRRect(
          borderRadius: dialogRadius,
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  title: Text(context.t.folders.newFolderTitle),
                  actions: [
                    TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text(context.t.folders.cancel),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: isCreateEnabled
                          ? () {
                              final FolderItemEntity folder = onSubmitPressed();
                              widget.onSubmit(folder);
                            }
                          : null,
                      child: Text(
                        widget.initial == null ? context.t.folders.create : context.t.folders.save,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      controller: titleController,
                      focusNode: titleFocusNode,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: context.t.folders.nameLabel,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.8,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => onSubmitPressed(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.t.folders.colorLabel),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: AppConstants.folderColors.map((Color color) {
                            final bool isSelected = selectedColor?.value == color.value;
                            return GestureDetector(
                              onTap: () => setState(() => selectedColor = color),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: isSelected ? 3 : 1,
                                    color: isSelected ? Colors.black87 : Colors.black12,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                      color: Color(0x14000000),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [Text(context.t.folders.iconLabel), const SizedBox(width: 12)],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  sliver: SliverGrid.builder(
                    itemCount: FolderIconsConstants.folderIcons.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final IconData iconData = FolderIconsConstants.folderIcons[index];
                      final bool isSelected = iconData == selectedIconData;
                      return InkWell(
                        onTap: () => setState(() => selectedIconData = iconData),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black12,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              iconData,
                              size: 26,
                              color: isSelected ? Theme.of(context).colorScheme.primary : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selectedColor?.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(selectedIconData, color: selectedColor),
                          const SizedBox(width: 8),
                          Text(
                            titleController.text.trim().isEmpty
                                ? context.t.folders.preview
                                : titleController.text.trim(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/folder_system_type.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class CreateFolderDialog extends StatefulWidget {
  final Function(CreateFolderEntity folder) onSubmit;
  final FolderEntity? initial;
  final bool isSaving;
  const CreateFolderDialog({super.key, required this.onSubmit, this.initial, this.isSaving = false});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final TextEditingController titleController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();

  Color? selectedColor;

  bool get isCreateEnabled => titleController.text.trim().isNotEmpty && !widget.isSaving;

  @override
  void initState() {
    super.initState();
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

  CreateFolderEntity onSubmitPressed() {
    // final int? organizationId = widget.initial?.organizationId ?? AppConstants.selectedOrganizationId;
    // if (organizationId == null) {
    //   throw StateError('Organization is not selected');
    // }
    final CreateFolderEntity folder = CreateFolderEntity(
      title: titleController.text.trim(),
      backgroundColor: selectedColor!,
      systemType: FolderSystemType.created,
    );
    return folder;
  }

  @override
  Widget build(BuildContext context) {
    final double maxDialogWidth = 520;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double dialogWidth = math.min(screenWidth - 32, maxDialogWidth);
    final double dialogHeight = math.min(screenHeight * 0.25, 640);
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
                              final CreateFolderEntity folder = onSubmitPressed();
                              widget.onSubmit(folder);
                            }
                          : null,
                      child: widget.isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
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
                      onSubmitted: (_) {
                        if (isCreateEnabled) {
                          final CreateFolderEntity folder = onSubmitPressed();
                          widget.onSubmit(folder);
                        }
                      },
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
                          Icon(Icons.folder, color: selectedColor),
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

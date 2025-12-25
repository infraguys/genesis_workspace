import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class UpdateFolderDialog extends StatefulWidget {
  final FolderEntity initial;
  final Future<void> Function(UpdateFolderEntity folder) onUpdate;
  final bool isSaving;

  const UpdateFolderDialog({
    super.key,
    required this.initial,
    required this.onUpdate,
    this.isSaving = false,
  });

  @override
  State<UpdateFolderDialog> createState() => _UpdateFolderDialogState();
}

class _UpdateFolderDialogState extends State<UpdateFolderDialog> {
  late final TextEditingController titleController;
  final FocusNode titleFocusNode = FocusNode();

  late Color selectedColor;

  bool get isSaveEnabled => titleController.text.trim().isNotEmpty && !widget.isSaving;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initial.backgroundColor;
    titleController = TextEditingController(text: widget.initial.title);
    titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    titleController.dispose();
    titleFocusNode.dispose();
    super.dispose();
  }

  UpdateFolderEntity _buildUpdateFolder() {
    return UpdateFolderEntity(
      uuid: widget.initial.uuid,
      title: titleController.text.trim(),
      backgroundColor: selectedColor,
    );
  }

  Future<void> _submitIfValid() async {
    if (!isSaveEnabled) return;
    final UpdateFolderEntity folder = _buildUpdateFolder();
    await widget.onUpdate(folder);
  }

  @override
  Widget build(BuildContext context) {
    final double maxDialogWidth = 520;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double dialogWidth = math.min(screenWidth - 32, maxDialogWidth);
    final BorderRadius dialogRadius = BorderRadius.circular(16);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: dialogRadius),
      child: SafeArea(
        child: ClipRRect(
          borderRadius: dialogRadius,
          child: SizedBox(
            width: dialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.t.folders.edit,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: Text(context.t.folders.cancel),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: isSaveEnabled ? _submitIfValid : null,
                        child: widget.isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(context.t.folders.save),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
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
                    onSubmitted: (_) => _submitIfValid(),
                  ),
                ),
                Padding(
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
                          final bool isSelected = selectedColor.value == color.value;
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedColor.withValues(alpha: 0.12),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

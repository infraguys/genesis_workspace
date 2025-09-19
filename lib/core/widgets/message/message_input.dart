import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/message/attachment_action.dart';
import 'package:genesis_workspace/core/widgets/message/attachment_tile.dart';
import 'package:genesis_workspace/core/widgets/message/editing_attachment_tile.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final VoidCallback? onEdit;
  final VoidCallback? onCancelEdit;
  final bool isEdit;
  final VoidCallback onUploadFile;
  final VoidCallback onUploadImage;
  final Function(String localId) onRemoveFile;
  final Function(String localId) onCancelUpload;
  final bool isMessagePending;
  final FocusNode focusNode;
  final List<UploadFileEntity>? files;
  final List<EditingAttachment>? editingFiles;
  final bool isDropOver;
  final MessageEntity? editingMessage;
  final Function(EditingAttachment)? onRemoveEditingAttachment;

  const MessageInput({
    super.key,
    required this.controller,
    this.onSend,
    required this.onUploadFile,
    required this.onUploadImage,
    required this.onRemoveFile,
    required this.onCancelUpload,
    required this.isMessagePending,
    required this.focusNode,
    required this.isDropOver,
    this.isEdit = false,
    this.onEdit,
    this.onCancelEdit,
    this.files,
    this.editingMessage,
    this.editingFiles,
    this.onRemoveEditingAttachment,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();
  final GlobalKey<CustomPopupState> attachmentsKey = GlobalKey<CustomPopupState>();

  Widget _buildAttachmentTile(
    UploadFileEntity entity, {
    Function(String localId)? onRemoveUploaded,
    Function(String localId)? onCancelUploading,
  }) {
    final String fileExtension = extensionOf(entity.filename);

    return switch (entity) {
      UploadingFileEntity(:final size, :final bytesSent, :final bytesTotal) => AttachmentTile(
        file: entity,
        extension: fileExtension,
        fileSize: size,
        isUploading: true,
        bytesSent: bytesSent,
        bytesTotal: bytesTotal,
        onCancelUploading: () {
          if (onCancelUploading != null) {
            onCancelUploading(entity.localId);
          }
        },
      ),
      UploadedFileEntity(:final size) => AttachmentTile(
        file: entity,
        extension: fileExtension,
        fileSize: size,
        isUploading: false,
        onRemove: () {
          if (onRemoveUploaded != null) {
            onRemoveUploaded(entity.localId);
          }
        },
      ),
    };
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (currentSize(context) >= ScreenSize.lTablet) {
      context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(false);
    } else {
      context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(false, closeKeyboard: true);
      _keyboardHeightPlugin.onKeyboardHeightChanged((double height) {
        if (height != 0) {
          context.read<EmojiKeyboardCubit>().setHeight(height);
        }
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _keyboardHeightPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<EmojiKeyboardCubit, EmojiKeyboardState>(
      builder: (context, emojiState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(sizeFactor: animation, child: child),
                );
              },
              child: widget.isEdit
                  ? Material(
                      color: Colors.transparent,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(6, 6, 6, 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: theme.colorScheme.primary, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.edit, size: 20, color: theme.colorScheme.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.editingMessage?.content ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: context.t.cancelEditing,
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.close_rounded, size: 20),
                                  onPressed: widget.onCancelEdit,
                                ),
                              ],
                            ),
                            if (widget.editingFiles != null && widget.editingFiles!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 96,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.editingFiles!.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                                  itemBuilder: (context, index) {
                                    final EditingAttachment attachment =
                                        widget.editingFiles![index];
                                    return EditingAttachmentTile(
                                      attachment: attachment,
                                      onRemove: widget.onRemoveEditingAttachment == null
                                          ? null
                                          : () {
                                              widget.onRemoveEditingAttachment!(attachment);
                                            },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (widget.files != null && widget.files!.isNotEmpty)
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  itemCount: widget.files!.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final UploadFileEntity entity = widget.files![index];
                    return _buildAttachmentTile(
                      entity,
                      onRemoveUploaded: widget.onRemoveFile,
                      onCancelUploading: widget.onCancelUpload,
                    );
                  },
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4).copyWith(bottom: 20),
              decoration: BoxDecoration(color: theme.colorScheme.surface),
              child: Row(
                spacing: 8,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: CustomPopup(
                      key: attachmentsKey,
                      showArrow: false,
                      content: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AttachmentAction(
                              iconData: Icons.insert_drive_file_rounded,
                              label: context.t.attachmentButton.file,
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.onUploadFile();
                              },
                            ),
                            const SizedBox(height: 4),
                            AttachmentAction(
                              iconData: Icons.image_outlined,
                              label: context.t.attachmentButton.image,
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.onUploadImage();
                              },
                            ),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.attach_file),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                            border: widget.isDropOver
                                ? Border.all(color: theme.colorScheme.primary, width: 2)
                                : Border.all(color: Colors.transparent, width: 2),
                          ),
                          child: TextField(
                            controller: widget.controller,
                            focusNode: widget.focusNode,
                            minLines: 1,
                            maxLines: 4,
                            autofocus: currentSize(context) >= ScreenSize.lTablet,
                            onTap: () {
                              if (currentSize(context) < ScreenSize.lTablet) {
                                context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(false);
                              }
                            },
                            textInputAction: TextInputAction.send,
                            onSubmitted: (value) {
                              if (widget.isEdit) {
                                if (widget.onEdit != null) {
                                  widget.onEdit!();
                                }
                              } else {
                                if (widget.onSend != null) {
                                  widget.onSend!();
                                }
                              }
                              widget.focusNode.requestFocus();
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: widget.isDropOver ? "" : "Message",
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  if (currentSize(context) >= ScreenSize.lTablet) {
                                    if (emojiState.showEmojiKeyboard) {
                                      context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(
                                        false,
                                        closeKeyboard: true,
                                      );
                                    } else {
                                      context.read<EmojiKeyboardCubit>().setHeight(300);
                                      context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(true);
                                    }
                                  } else {
                                    if (emojiState.showEmojiKeyboard) {
                                      FocusScope.of(context).requestFocus(widget.focusNode);
                                      context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(
                                        false,
                                      );
                                    } else {
                                      FocusScope.of(context).unfocus();
                                      if (emojiState.keyboardHeight == 0) {
                                        context.read<EmojiKeyboardCubit>().setHeight(300);
                                      }
                                      context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(true);
                                    }
                                  }
                                },
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, animation) => RotationTransition(
                                    turns: child.key == const ValueKey('emoji')
                                        ? Tween<double>(begin: 0.75, end: 1.0).animate(animation)
                                        : Tween<double>(begin: 1.25, end: 1.0).animate(animation),
                                    child: FadeTransition(opacity: animation, child: child),
                                  ),
                                  child: emojiState.showEmojiKeyboard
                                      ? const Icon(Icons.keyboard, key: ValueKey('keyboard'))
                                      : const Icon(Icons.emoji_emotions, key: ValueKey('emoji')),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Оверлей при перетаскивании
                        if (widget.isDropOver)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 120),
                                opacity: 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    context.t.dropFilesToUpload,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: widget.isEdit ? widget.onEdit : widget.onSend,
                    child: widget.isEdit
                        ? const Icon(Icons.check)
                        : const Icon(Icons.send_outlined),
                  ).pending(widget.isMessagePending),
                ],
              ),
            ),
            AnimatedContainer(
              height: emojiState.keyboardHeight,
              duration: Duration(milliseconds: 250),
              child: EmojiPicker(
                textEditingController: widget.controller,
                onEmojiSelected: (_, _) {
                  widget.focusNode.requestFocus();
                },
                config: Config(
                  height: emojiState.keyboardHeight,
                  bottomActionBarConfig: BottomActionBarConfig(enabled: true),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

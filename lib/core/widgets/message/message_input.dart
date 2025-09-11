import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/message/attachment_action.dart';
import 'package:genesis_workspace/core/widgets/message/attachment_tile.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final VoidCallback onUploadFile;
  final bool isMessagePending;
  final FocusNode focusNode;
  final List<UploadFileEntity>? files;

  const MessageInput({
    super.key,
    required this.controller,
    this.onSend,
    required this.onUploadFile,
    required this.isMessagePending,
    required this.focusNode,
    this.files,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  // bool _keyboardOpen = false;

  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();
  final GlobalKey<CustomPopupState> attachmentsKey = GlobalKey<CustomPopupState>();

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

    Widget buildAttachmentTile(
      UploadFileEntity entity, {
      VoidCallback? onRemoveUploaded,
      VoidCallback? onCancelUploading,
    }) {
      final String fileExtension = extensionOf(entity.filename);

      return switch (entity) {
        UploadingFileEntity(:final filename, :final size, :final bytesSent, :final bytesTotal) =>
          AttachmentTile(
            filename: filename,
            extension: fileExtension,
            fileSize: size,
            isUploading: true,
            bytesSent: bytesSent,
            bytesTotal: bytesTotal,
            onRemove: onCancelUploading,
          ),
        UploadedFileEntity(:final filename, :final size) => AttachmentTile(
          filename: filename,
          extension: fileExtension,
          fileSize: size,
          isUploading: false,
          onRemove: onRemoveUploaded,
        ),
      };
    }

    return BlocBuilder<EmojiKeyboardCubit, EmojiKeyboardState>(
      builder: (context, emojiState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.files != null && widget.files!.isNotEmpty)
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  itemCount: widget.files!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final UploadFileEntity entity = widget.files![index];
                    return buildAttachmentTile(
                      entity,
                      onRemoveUploaded: null,
                      onCancelUploading: null,
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
                                // context.read<MessagesCubit>().pickImage();
                              },
                            ),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.attach_file),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        minLines: 1,
                        maxLines: 4,
                        onTap: () {
                          if (currentSize(context) < ScreenSize.lTablet) {
                            context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(false);
                          }
                        },
                        textInputAction: TextInputAction.send,
                        onSubmitted: (value) {
                          if (widget.onSend != null) {
                            widget.onSend!();
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Message",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                  context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(false);
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
                  ),

                  ElevatedButton(
                    onPressed: widget.onSend,
                    child: const Icon(Icons.send),
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

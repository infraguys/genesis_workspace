import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/emoji_picker_config.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/core/widgets/message/attach_files_button.dart';
import 'package:genesis_workspace/core/widgets/message/attachment_tile.dart';
import 'package:genesis_workspace/core/widgets/message/editing_attachment_tile.dart';
import 'package:genesis_workspace/core/widgets/message/toggle_emoji_keyboard_button.dart';
import 'package:genesis_workspace/core/widgets/tap_effect_icon.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MessageInput extends StatefulWidget {
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
    this.onSubmitIntercept,
    this.inputTitle,
  });

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
  final bool Function()? onSubmitIntercept;
  final String? inputTitle;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _isShiftPressed() {
    final keyboard = HardwareKeyboard.instance;
    return keyboard.isLogicalKeyPressed(LogicalKeyboardKey.shiftLeft) ||
        keyboard.isLogicalKeyPressed(LogicalKeyboardKey.shiftRight) ||
        keyboard.isLogicalKeyPressed(LogicalKeyboardKey.shift);
  }

  void _insertNewLine() {
    final selection = widget.controller.selection;
    final text = widget.controller.text;
    final newText = selection.isValid ? text.replaceRange(selection.start, selection.end, '\n') : '$text\n';
    final offset = selection.isValid ? selection.start + 1 : newText.length;

    widget.controller.value = widget.controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }

  @override
  void didChangeDependencies() {
    if (currentSize(context) >= ScreenSize.lTablet) {
      context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(false);
    } else {
      context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(false, closeKeyboard: true);
      final height = MediaQuery.of(context).viewInsets.bottom;
      if (height > 0) {
        context.read<EmojiKeyboardCubit>().setHeight(height);
      }
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    final isTabletOrSmaller = currentSize(context) <= ScreenSize.tablet;
    return BlocBuilder<EmojiKeyboardCubit, EmojiKeyboardState>(
      builder: (context, emojiState) {
        double bottomPadding = 12;
        if (!isTabletOrSmaller) {
          bottomPadding = 12;
        } else if (!emojiState.showEmojiKeyboard && widget.focusNode.hasFocus) {
          bottomPadding = 4;
        } else {
          bottomPadding = 20;
        }
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(12).copyWith(bottom: bottomPadding),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12).copyWith(
                bottomLeft: isTabletOrSmaller ? .zero : null,
                bottomRight: isTabletOrSmaller ? .zero : null,
              ),
            ),
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
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
                            margin: const .fromLTRB(6, 6, 6, 8),
                            padding: const .symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: .circular(12),
                              border: .all(color: theme.colorScheme.primary, width: 2),
                            ),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                Row(
                                  crossAxisAlignment: .center,
                                  children: [
                                    Icon(Icons.edit, size: 20, color: theme.colorScheme.primary),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        widget.editingMessage?.content ?? '',
                                        maxLines: 1,
                                        overflow: .ellipsis,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      tooltip: context.t.cancelEditing,
                                      visualDensity: .compact,
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
                                      scrollDirection: .horizontal,
                                      itemCount: widget.editingFiles!.length,
                                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                                      itemBuilder: (_, index) {
                                        final attachment = widget.editingFiles![index];
                                        return EditingAttachmentTile(
                                          attachment: attachment,
                                          onRemove: widget.onRemoveEditingAttachment == null
                                              ? null
                                              : () => widget.onRemoveEditingAttachment!(attachment),
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
                if (widget.files != null && widget.files!.isNotEmpty) ...[
                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: .horizontal,
                      padding: const .symmetric(horizontal: 6),
                      itemCount: widget.files!.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final UploadFileEntity entity = widget.files![index];
                        final String fileExtension = extensionOf(entity.filename);
                        return switch (entity) {
                          UploadingFileEntity(:final size, :final bytesSent, :final bytesTotal) => AttachmentTile(
                            file: entity,
                            extension: fileExtension,
                            fileSize: size,
                            isUploading: true,
                            bytesSent: bytesSent,
                            bytesTotal: bytesTotal,
                            onCancelUploading: () => widget.onCancelUpload(entity.localId),
                          ),
                          UploadedFileEntity(:final size) => AttachmentTile(
                            file: entity,
                            extension: fileExtension,
                            fileSize: size,
                            isUploading: false,
                            onRemove: () => widget.onRemoveFile(entity.localId),
                          ),
                        };
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.background,
                          borderRadius: .circular(12),
                        ),
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              clipBehavior: .hardEdge,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.background,
                                borderRadius: .circular(12),
                              ),
                              child: Stack(
                                children: [
                                  TextField(
                                    enableInteractiveSelection: true,
                                    textAlignVertical: .center,
                                    controller: widget.controller,
                                    focusNode: widget.focusNode,
                                    minLines: 1,
                                    maxLines: 4,
                                    autofocus: platformInfo.isDesktop,
                                    clipBehavior: .none,
                                    onTap: () {
                                      if (currentSize(context) < ScreenSize.lTablet) {
                                        context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(
                                          false,
                                        );
                                      }
                                    },
                                    textInputAction: .send,
                                    onSubmitted: (_) {
                                      if (_isShiftPressed()) {
                                        _insertNewLine();
                                        widget.focusNode.requestFocus();
                                        return;
                                      }
                                      if (widget.onSubmitIntercept != null && widget.onSubmitIntercept!()) {
                                        if (platformInfo.isDesktop) {
                                          widget.focusNode.requestFocus();
                                        }
                                        return;
                                      }

                                      switch (widget.isEdit) {
                                        case true:
                                          widget.onEdit?.call();
                                        default:
                                          widget.onSend?.call();
                                      }

                                      if (platformInfo.isDesktop) {
                                        widget.focusNode.requestFocus();
                                      }
                                    },
                                    decoration: InputDecoration(
                                      isCollapsed: true,
                                      border: InputBorder.none,
                                      fillColor: theme.colorScheme.background,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      hintText: widget.isDropOver ? "" : context.t.input.placeholder,
                                      contentPadding: const EdgeInsets.fromLTRB(48, 14, 46, 14),
                                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                        color: textColors.text30,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 8.0,
                                    top: 0.0,
                                    bottom: 0.0,
                                    child: AttachFilesButton(
                                      onUploadFile: widget.onUploadFile,
                                      onUploadImage: widget.onUploadImage,
                                    ),
                                  ),
                                  Positioned(
                                    right: 8.0,
                                    top: 0.0,
                                    bottom: 0.0,
                                    child: Row(
                                      mainAxisSize: .min,
                                      spacing: 24,
                                      children: [
                                        ToggleEmojiKeyboardButton(
                                          emojiState: emojiState,
                                          focusNode: widget.focusNode,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.isDropOver)
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 120),
                                    opacity: 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(12),
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
                    ),
                    _SubmitButton(
                      isEdit: widget.isEdit,
                      onTap: widget.isEdit ? widget.onEdit : widget.onSend,
                    ),
                  ],
                ),
                AnimatedContainer(
                  height: emojiState.keyboardHeight,
                  duration: Duration(milliseconds: 250),
                  child: EmojiPicker(
                    textEditingController: widget.controller,
                    onEmojiSelected: (_, _) {
                      widget.focusNode.requestFocus();
                    },
                    config: emojiPickerConfig(context, theme: theme),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    super.key, // ignore: unused_element_parameter
    required this.isEdit,
    this.onTap,
  });

  final bool isEdit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TapEffectIcon(
      onTap: onTap,
      child: SizedBox.square(
        dimension: 44.0,
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(12.0)),
          child: Center(
            child: isEdit
                ? Icon(Icons.edit, color: theme.colorScheme.onPrimary)
                : Assets.icons.send.svg(
                    height: 20,
                    width: 24,
                    colorFilter: .mode(theme.colorScheme.onPrimary, .srcIn),
                  ),
          ),
        ),
      ),
    );
  }
}

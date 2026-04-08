import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/emoji_picker_config.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/utils/markdown_editor_helper.dart';
import 'package:genesis_workspace/core/utils/message_input_intents/edit_message_intents.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/core/widgets/message/attach_files_button.dart';
import 'package:genesis_workspace/core/widgets/message/attachment_tile.dart';
import 'package:genesis_workspace/core/widgets/message/editing_attachment_tile.dart';
import 'package:genesis_workspace/core/widgets/message/message_input_context_menu.dart';
import 'package:genesis_workspace/core/widgets/message/toggle_emoji_keyboard_button.dart';
import 'package:genesis_workspace/core/widgets/tap_effect_icon.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_select/messages_select_cubit.dart';
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
  bool _showMdActions = false;
  String _lastText = '';
  bool _isApplyingAutoList = false;

  @override
  void initState() {
    super.initState();
    _lastText = widget.controller.text;
  }

  @override
  void didUpdateWidget(covariant MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _lastText = widget.controller.text;
    }
  }

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
    final continuation = buildListContinuationEdit(
      text: newText,
      cursorOffset: offset,
    );
    final finalText = continuation?.text ?? newText;
    final finalOffset = continuation?.cursorOffset ?? offset;

    _setControllerText(
      text: finalText,
      cursorOffset: finalOffset,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleMdActions() {
    setState(() {
      _showMdActions = !_showMdActions;
    });
  }

  void _applyInlineFormat({
    required String prefix,
    required String suffix,
  }) {
    final result = applyInlineFormatEdit(
      text: widget.controller.text,
      selection: widget.controller.selection,
      prefix: prefix,
      suffix: suffix,
    );
    _setControllerTextFromResult(result);
    widget.focusNode.requestFocus();
  }

  void _insertSpoiler() {
    final result = insertSpoilerEdit(
      text: widget.controller.text,
      selection: widget.controller.selection,
    );
    _setControllerTextFromResult(result);
    widget.focusNode.requestFocus();
  }

  void _insertQuote() {
    final result = insertQuoteEdit(
      text: widget.controller.text,
      selection: widget.controller.selection,
    );
    _setControllerTextFromResult(result);
    widget.focusNode.requestFocus();
  }

  void _insertCodeBlock() {
    final result = insertCodeBlockEdit(
      text: widget.controller.text,
      selection: widget.controller.selection,
    );
    _setControllerTextFromResult(result);
    widget.focusNode.requestFocus();
  }

  void _insertLink() {
    final result = insertLinkEdit(
      text: widget.controller.text,
      selection: widget.controller.selection,
    );
    _setControllerTextFromResult(result);
    widget.focusNode.requestFocus();
  }

  void _insertList({
    required bool ordered,
  }) {
    final result = insertListEdit(
      text: widget.controller.text,
      selection: widget.controller.selection,
      ordered: ordered,
    );
    _setControllerTextFromResult(result);
    widget.focusNode.requestFocus();
  }

  void _setControllerTextFromResult(MarkdownEditResult result) {
    _setControllerText(
      text: result.text,
      cursorOffset: result.selection.extentOffset,
      selection: result.selection,
    );
  }

  void _setControllerText({
    required String text,
    required int cursorOffset,
    TextSelection? selection,
  }) {
    final safeOffset = cursorOffset.clamp(0, text.length);
    final safeSelection = selection == null
        ? TextSelection.collapsed(offset: safeOffset)
        : TextSelection(
            baseOffset: selection.baseOffset.clamp(0, text.length),
            extentOffset: selection.extentOffset.clamp(0, text.length),
          );
    _isApplyingAutoList = true;
    widget.controller.value = widget.controller.value.copyWith(
      text: text,
      selection: safeSelection,
      composing: TextRange.empty,
    );
    _lastText = text;
    _isApplyingAutoList = false;
  }

  void _onInputChanged(String text) {
    if (_isApplyingAutoList) {
      _lastText = text;
      return;
    }

    final selection = widget.controller.selection;
    final didInsertSingleNewLine =
        selection.isValid &&
        selection.isCollapsed &&
        text.length == _lastText.length + 1 &&
        selection.start > 0 &&
        selection.start <= text.length &&
        text[selection.start - 1] == '\n' &&
        text.replaceRange(selection.start - 1, selection.start, '') == _lastText;

    if (!didInsertSingleNewLine) {
      _lastText = text;
      return;
    }

    final continuation = buildListContinuationEdit(
      text: text,
      cursorOffset: selection.start,
    );
    if (continuation == null) {
      _lastText = text;
      return;
    }

    _setControllerText(
      text: continuation.text,
      cursorOffset: continuation.cursorOffset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    final iconColors = Theme.of(context).extension<IconColors>()!;
    final isTabletOrSmaller = currentSize(context) <= ScreenSize.tablet;
    return BlocBuilder<EmojiKeyboardCubit, EmojiKeyboardState>(
      builder: (context, emojiState) {
        double bottomPadding = 12;
        if (!isTabletOrSmaller) {
          bottomPadding = 12;
        } else if (!emojiState.showEmojiKeyboard && widget.focusNode.hasFocus) {
          bottomPadding = MediaQuery.of(context).viewInsets.bottom + 4;
        } else {
          bottomPadding = 20;
        }
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.decelerate,
          padding: EdgeInsets.all(12).copyWith(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12).copyWith(
              bottomLeft: isTabletOrSmaller ? .zero : null,
              bottomRight: isTabletOrSmaller ? .zero : null,
            ),
          ),
          child: BlocBuilder<MessagesSelectCubit, MessagesSelectState>(
            builder: (context, messagesSelectState) {
              return Column(
                crossAxisAlignment: .start,
                mainAxisSize: .min,
                children: [
                  if (messagesSelectState.selectedMessages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Column(
                            spacing: 4,
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                context.t.general.forwardMessages,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: .w500,
                                ),
                              ),
                              Text(
                                context.t.general.messagesCount(
                                  n: messagesSelectState.selectedMessages.length,
                                ),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              context.read<MessagesSelectCubit>().clearForwardMessages();
                            },
                            icon: Assets.icons.close.svg(
                              colorFilter: ColorFilter.mode(
                                iconColors.base,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                                        icon: Icon(
                                          Icons.close_rounded,
                                          size: 20,
                                          color: textColors.text30,
                                        ),
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
                  Shortcuts(
                    shortcuts: {
                      if (widget.isEdit) SingleActivator(LogicalKeyboardKey.escape): const CancelEditMessageIntent(),
                    },
                    child: Actions(
                      actions: {
                        CancelEditMessageIntent: CallbackAction<CancelEditMessageIntent>(
                          onInvoke: (_) {
                            if (widget.isEdit) {
                              widget.onCancelEdit?.call();
                            }
                            return null;
                          },
                        ),
                      },
                      child: Row(
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
                                          onChanged: _onInputChanged,
                                          contextMenuBuilder:
                                              (BuildContext context, EditableTextState editableTextState) {
                                                return MessageInputContextMenu(
                                                  editableTextState: editableTextState,
                                                );
                                              },
                                          textInputAction: platformInfo.isDesktop ? .send : null,
                                          textCapitalization: platformInfo.isMobile
                                              ? TextCapitalization.sentences
                                              : TextCapitalization.none,
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
                                            contentPadding: EdgeInsets.fromLTRB(
                                              isTabletOrSmaller ? 48 : 78,
                                              14,
                                              46,
                                              14,
                                            ),
                                            hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                              color: textColors.text30,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 8.0,
                                          top: 0.0,
                                          bottom: 0.0,
                                          child: Row(
                                            children: [
                                              if (!isTabletOrSmaller)
                                                TapEffectIcon(
                                                  padding: .zero,
                                                  onTap: _toggleMdActions,
                                                  child:
                                                      (_showMdActions
                                                              ? Assets.icons.bottomPanelClose
                                                              : Assets.icons.bottomPanelOpen)
                                                          .svg(
                                                            colorFilter: ColorFilter.mode(
                                                              textColors.text30,
                                                              BlendMode.srcIn,
                                                            ),
                                                          ),
                                                ),
                                              AttachFilesButton(
                                                onUploadFile: widget.onUploadFile,
                                                onUploadImage: widget.onUploadImage,
                                              ),
                                            ],
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
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axisAlignment: -1.0,
                            child: child,
                          ),
                        );
                      },
                      child: _showMdActions
                          ? Padding(
                              key: const ValueKey('md-actions'),
                              padding: .zero,
                              child: Row(
                                spacing: 16,
                                children: [
                                  TapEffectIcon(
                                    padding: .zero,
                                    onTap: _insertLink,
                                    child: Assets.icons.addLink.svg(
                                      colorFilter: ColorFilter.mode(
                                        iconColors.base,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  TapEffectIcon(
                                    padding: .zero,
                                    onTap: () => _applyInlineFormat(
                                      prefix: '**',
                                      suffix: '**',
                                    ),
                                    child: Assets.icons.formatBold.svg(
                                      colorFilter: ColorFilter.mode(
                                        theme.colorScheme.onSurface,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  TapEffectIcon(
                                    padding: .zero,
                                    onTap: () => _applyInlineFormat(
                                      prefix: '*',
                                      suffix: '*',
                                    ),
                                    child: Assets.icons.formatItalic.svg(
                                      colorFilter: ColorFilter.mode(
                                        theme.colorScheme.onSurface,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  TapEffectIcon(
                                    padding: .zero,
                                    onTap: () => _applyInlineFormat(
                                      prefix: '~~',
                                      suffix: '~~',
                                    ),
                                    child: Assets.icons.strikethroughS.svg(
                                      colorFilter: ColorFilter.mode(
                                        theme.colorScheme.onSurface,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  _EditorToolsVerticalDivider(),
                                  TapEffectIcon(
                                    padding: .zero,
                                    onTap: () => _insertList(ordered: true),
                                    child: Assets.icons.formatListNumbered.svg(
                                      colorFilter: ColorFilter.mode(
                                        iconColors.base,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  TapEffectIcon(
                                    padding: .zero,
                                    onTap: () => _insertList(ordered: false),
                                    child: Assets.icons.formatListBulleted.svg(
                                      colorFilter: ColorFilter.mode(
                                        iconColors.base,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  _EditorToolsVerticalDivider(),
                                  TapEffectIcon(
                                    padding: .zero,
                                    onTap: _insertQuote,
                                    child: Icon(
                                      fontWeight: .w100,
                                      weight: 100,
                                      Icons.format_quote_outlined,
                                      color: iconColors.base,
                                    ),
                                  ),
                                  TapEffectIcon(
                                    padding: .zero,
                                    onTap: _insertSpoiler,
                                    child: Assets.icons.spoiler.svg(
                                      colorFilter: ColorFilter.mode(
                                        theme.colorScheme.onSurface,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  TapEffectIcon(
                                    padding: .zero,
                                    onTap: _insertCodeBlock,
                                    child: Assets.icons.frameSource.svg(
                                      colorFilter: ColorFilter.mode(
                                        iconColors.base,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('md-actions-empty'),
                            ),
                    ),
                  ),
                  AnimatedContainer(
                    height: (emojiState.showEmojiKeyboard && !widget.focusNode.hasFocus)
                        ? emojiState.keyboardHeight
                        : 0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: EmojiPicker(
                      textEditingController: widget.controller,
                      onEmojiSelected: (_, _) {
                        // widget.focusNode.requestFocus();
                      },
                      config: emojiPickerConfig(context, theme: theme),
                    ),
                  ),
                ],
              );
            },
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

class _EditorToolsVerticalDivider extends StatelessWidget {
  const _EditorToolsVerticalDivider();

  @override
  Widget build(BuildContext context) {
    final iconColors = Theme.of(context).extension<IconColors>()!;
    return SizedBox(
      height: 24,
      child: VerticalDivider(
        width: 2,
        color: iconColors.base,
      ),
    );
  }
}

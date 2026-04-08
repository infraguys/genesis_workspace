import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/utils/markdown_editor_helper.dart';
import 'package:genesis_workspace/core/widgets/message/message_input_context_menu_button.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MessageInputContextMenu extends StatelessWidget {
  const MessageInputContextMenu({
    super.key,
    required this.editableTextState,
  });

  final EditableTextState editableTextState;

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      MessageInputContextMenuItem(
        type: ContextMenuButtonType.copy,
        onPressed: () {
          editableTextState.copySelection(SelectionChangedCause.toolbar);
        },
      ),
      MessageInputContextMenuItem(
        type: ContextMenuButtonType.cut,
        onPressed: () {
          editableTextState.cutSelection(SelectionChangedCause.toolbar);
        },
      ),
      MessageInputContextMenuItem(
        type: ContextMenuButtonType.paste,
        onPressed: () {
          editableTextState.pasteText(SelectionChangedCause.toolbar);
        },
      ),
      MessageInputContextMenuItem(
        icon: Assets.icons.addLink,
        label: context.t.editor.link,
        onPressed: () {
          final value = editableTextState.textEditingValue;
          _applyMarkdownResult(
            editableTextState,
            insertLinkEdit(
              text: value.text,
              selection: value.selection,
            ),
          );
        },
      ),
      MessageInputContextMenuItem(
        icon: Assets.icons.formatBold,
        label: context.t.contextMenu.bold,
        onPressed: () {
          final value = editableTextState.textEditingValue;
          _applyMarkdownResult(
            editableTextState,
            applyInlineFormatEdit(
              text: value.text,
              selection: value.selection,
              prefix: '**',
              suffix: '**',
            ),
          );
        },
      ),
      MessageInputContextMenuItem(
        icon: Assets.icons.formatItalic,
        label: context.t.contextMenu.italic,
        onPressed: () {
          final value = editableTextState.textEditingValue;
          _applyMarkdownResult(
            editableTextState,
            applyInlineFormatEdit(
              text: value.text,
              selection: value.selection,
              prefix: '*',
              suffix: '*',
            ),
          );
        },
      ),
      MessageInputContextMenuItem(
        icon: Assets.icons.strikethroughS,
        label: context.t.contextMenu.strikethrough,
        onPressed: () {
          final value = editableTextState.textEditingValue;
          _applyMarkdownResult(
            editableTextState,
            applyInlineFormatEdit(
              text: value.text,
              selection: value.selection,
              prefix: '~~',
              suffix: '~~',
            ),
          );
        },
      ),
      MessageInputContextMenuItem(
        icon: Assets.icons.formatListNumbered,
        label: context.t.editor.numberedList,
        onPressed: () {
          final value = editableTextState.textEditingValue;
          _applyMarkdownResult(
            editableTextState,
            insertListEdit(
              text: value.text,
              selection: value.selection,
              ordered: true,
            ),
          );
        },
      ),
      MessageInputContextMenuItem(
        icon: Assets.icons.formatListBulleted,
        label: context.t.editor.bulletedList,
        onPressed: () {
          final value = editableTextState.textEditingValue;
          _applyMarkdownResult(
            editableTextState,
            insertListEdit(
              text: value.text,
              selection: value.selection,
              ordered: false,
            ),
          );
        },
      ),
      MessageInputContextMenuItem(
        materialIcon: Icons.format_quote_outlined,
        label: context.t.editor.quote,
        onPressed: () {
          final value = editableTextState.textEditingValue;
          _applyMarkdownResult(
            editableTextState,
            insertQuoteEdit(
              text: value.text,
              selection: value.selection,
            ),
          );
        },
      ),
      MessageInputContextMenuItem(
        icon: Assets.icons.spoiler,
        label: context.t.contextMenu.spoiler,
        onPressed: () {
          final value = editableTextState.textEditingValue;
          _applyMarkdownResult(
            editableTextState,
            insertSpoilerEdit(
              text: value.text,
              selection: value.selection,
            ),
          );
        },
      ),
      MessageInputContextMenuItem(
        icon: Assets.icons.frameSource,
        label: context.t.editor.code,
        onPressed: () {
          final value = editableTextState.textEditingValue;
          _applyMarkdownResult(
            editableTextState,
            insertCodeBlockEdit(
              text: value.text,
              selection: value.selection,
            ),
          );
        },
      ),
    ];

    return AdaptiveTextSelectionToolbar(
      anchors: editableTextState.contextMenuAnchors,
      children: List.generate(
        menuItems.length,
        (index) => MessageInputContextMenuButton(
          item: menuItems[index],
          index: index,
          total: menuItems.length,
        ),
      ),
    );
  }
}

void _applyMarkdownResult(EditableTextState state, MarkdownEditResult result) {
  state.userUpdateTextEditingValue(
    state.textEditingValue.copyWith(
      text: result.text,
      selection: result.selection,
      composing: TextRange.empty,
    ),
    SelectionChangedCause.toolbar,
  );
  state.hideToolbar();
}

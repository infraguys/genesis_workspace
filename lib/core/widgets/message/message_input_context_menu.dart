import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
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
        icon: Assets.icons.formatBold,
        label: context.t.contextMenu.bold,
        onPressed: () {
          _applyInlineFormat(editableTextState, prefix: '**', suffix: '**');
        },
      ),
      MessageInputContextMenuItem(
        icon: Assets.icons.formatItalic,
        label: context.t.contextMenu.italic,
        onPressed: () {
          _applyInlineFormat(editableTextState, prefix: '*', suffix: '*');
        },
      ),
      MessageInputContextMenuItem(
        icon: Assets.icons.strikethroughS,
        label: context.t.contextMenu.strikethrough,
        onPressed: () {
          _applyInlineFormat(editableTextState, prefix: '~~', suffix: '~~');
        },
      ),
      MessageInputContextMenuItem(
        icon: Assets.icons.spoiler,
        label: context.t.contextMenu.spoiler,
        onPressed: () {
          _insertSpoiler(editableTextState);
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

void _insertSpoiler(EditableTextState state) {
  final value = state.textEditingValue;
  final result = buildSpoilerInsertion(
    text: value.text,
    selection: value.selection,
  );

  state.userUpdateTextEditingValue(
    value.copyWith(
      text: result.text,
      selection: TextSelection.collapsed(offset: result.cursorOffset),
      composing: TextRange.empty,
    ),
    SelectionChangedCause.toolbar,
  );
  state.hideToolbar();
}

void _applyInlineFormat(
  EditableTextState state, {
  required String prefix,
  required String suffix,
}) {
  final value = state.textEditingValue;
  final selection = value.selection;
  final text = value.text;
  final start = selection.isValid ? selection.start : text.length;
  final end = selection.isValid ? selection.end : text.length;
  final hasSelection = selection.isValid && !selection.isCollapsed;
  final selectedText = hasSelection ? text.substring(start, end) : '';
  final replacement = hasSelection ? '$prefix$selectedText$suffix' : '$prefix$suffix';
  final newText = text.replaceRange(start, end, replacement);
  final cursorOffset = hasSelection ? start + replacement.length : start + prefix.length;

  state.userUpdateTextEditingValue(
    value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorOffset),
      composing: TextRange.empty,
    ),
    SelectionChangedCause.toolbar,
  );
  state.hideToolbar();
}

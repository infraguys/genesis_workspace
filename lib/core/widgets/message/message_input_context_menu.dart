import 'package:flutter/material.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MessageInputContextMenu extends StatelessWidget {
  const MessageInputContextMenu({
    super.key,
    required this.editableTextState,
  });

  final EditableTextState editableTextState;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: [
        ContextMenuButtonItem(
          type: ContextMenuButtonType.copy,
          onPressed: () {
            editableTextState.copySelection(SelectionChangedCause.toolbar);
          },
        ),
        ContextMenuButtonItem(
          type: ContextMenuButtonType.cut,
          onPressed: () {
            editableTextState.cutSelection(SelectionChangedCause.toolbar);
          },
        ),
        ContextMenuButtonItem(
          type: ContextMenuButtonType.paste,
          onPressed: () {
            editableTextState.pasteText(SelectionChangedCause.toolbar);
          },
        ),
        ContextMenuButtonItem(
          label: context.t.contextMenu.spoiler,
          onPressed: () {
            _insertSpoiler(editableTextState);
          },
        ),
      ],
    );
  }
}

void _insertSpoiler(EditableTextState state) {
  final value = state.textEditingValue;
  final selection = value.selection;
  final text = value.text;
  final start = selection.isValid ? selection.start : text.length;
  final end = selection.isValid ? selection.end : text.length;
  final hasSelection = selection.isValid && !selection.isCollapsed;
  final selectedText = hasSelection ? text.substring(start, end) : '';

  final replacement = hasSelection ? '\n```spoiler Header\n$selectedText\n```' : '```spoiler Header\n\n```';
  final newText = text.replaceRange(start, end, replacement);
  final cursorOffset = hasSelection ? start + replacement.length : start + '```spoiler Header\n'.length;

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

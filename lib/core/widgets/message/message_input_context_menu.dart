import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      _ContextMenuEntry(
        type: ContextMenuButtonType.copy,
        onPressed: () {
          editableTextState.copySelection(SelectionChangedCause.toolbar);
        },
      ),
      _ContextMenuEntry(
        type: ContextMenuButtonType.cut,
        onPressed: () {
          editableTextState.cutSelection(SelectionChangedCause.toolbar);
        },
      ),
      _ContextMenuEntry(
        type: ContextMenuButtonType.paste,
        onPressed: () {
          editableTextState.pasteText(SelectionChangedCause.toolbar);
        },
      ),
      _ContextMenuEntry(
        icon: Assets.icons.formatBold,
        onPressed: () {
          _applyInlineFormat(editableTextState, prefix: '**', suffix: '**');
        },
      ),
      _ContextMenuEntry(
        icon: Assets.icons.formatItalic,
        onPressed: () {
          _applyInlineFormat(editableTextState, prefix: '*', suffix: '*');
        },
      ),
      _ContextMenuEntry(
        icon: Assets.icons.strikethroughS,
        onPressed: () {
          _applyInlineFormat(editableTextState, prefix: '~~', suffix: '~~');
        },
      ),
      _ContextMenuEntry(
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
        (index) => _buildMenuButton(
          context,
          item: menuItems[index],
          index: index,
          total: menuItems.length,
        ),
      ),
    );
  }
}

class _ContextMenuEntry {
  const _ContextMenuEntry({
    required this.onPressed,
    this.type,
    this.label,
    this.icon,
  });

  final VoidCallback? onPressed;
  final ContextMenuButtonType? type;
  final String? label;
  final SvgGenImage? icon;

  bool get hasIcon => icon != null;
}

Widget _buildMenuButton(
  BuildContext context, {
  required _ContextMenuEntry item,
  required int index,
  required int total,
}) {
  final String label = item.hasIcon ? '' : _resolveMenuLabel(context, item);
  final Widget iconChild = item.hasIcon ? _FormatIcon(icon: item.icon!) : const SizedBox.shrink();

  switch (Theme.of(context).platform) {
    case TargetPlatform.iOS:
      return item.hasIcon
          ? CupertinoTextSelectionToolbarButton(
              onPressed: item.onPressed,
              child: iconChild,
            )
          : CupertinoTextSelectionToolbarButton.text(
              onPressed: item.onPressed,
              text: label,
            );
    case TargetPlatform.macOS:
      return item.hasIcon
          ? CupertinoDesktopTextSelectionToolbarButton(
              onPressed: item.onPressed,
              child: iconChild,
            )
          : CupertinoDesktopTextSelectionToolbarButton.text(
              onPressed: item.onPressed,
              text: label,
            );
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
      return TextSelectionToolbarTextButton(
        padding: TextSelectionToolbarTextButton.getPadding(index, total),
        onPressed: item.onPressed,
        alignment: AlignmentDirectional.centerStart,
        child: item.hasIcon ? iconChild : Text(label),
      );
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return item.hasIcon
          ? DesktopTextSelectionToolbarButton(
              onPressed: item.onPressed,
              child: iconChild,
            )
          : DesktopTextSelectionToolbarButton.text(
              context: context,
              onPressed: item.onPressed,
              text: label,
            );
  }
}

String _resolveMenuLabel(BuildContext context, _ContextMenuEntry item) {
  if (item.label != null) {
    return item.label!;
  }
  final type = item.type ?? ContextMenuButtonType.custom;
  return AdaptiveTextSelectionToolbar.getButtonLabel(
    context,
    ContextMenuButtonItem(
      onPressed: item.onPressed,
      type: type,
    ),
  );
}

class _FormatIcon extends StatelessWidget {
  const _FormatIcon({
    required this.icon,
  });

  final SvgGenImage icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return icon.svg(
      width: 18,
      height: 18,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
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

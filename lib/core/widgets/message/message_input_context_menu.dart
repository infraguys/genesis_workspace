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
        label: context.t.contextMenu.bold,
        onPressed: () {
          _applyInlineFormat(editableTextState, prefix: '**', suffix: '**');
        },
      ),
      _ContextMenuEntry(
        icon: Assets.icons.formatItalic,
        label: context.t.contextMenu.italic,
        onPressed: () {
          _applyInlineFormat(editableTextState, prefix: '*', suffix: '*');
        },
      ),
      _ContextMenuEntry(
        icon: Assets.icons.strikethroughS,
        label: context.t.contextMenu.strikethrough,
        onPressed: () {
          _applyInlineFormat(editableTextState, prefix: '~~', suffix: '~~');
        },
      ),
      _ContextMenuEntry(
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
  final TargetPlatform platform = Theme.of(context).platform;
  final bool isDesktop = _isDesktopPlatform(platform);
  final String label = _resolveMenuLabel(context, item);
  final Widget iconChild = item.hasIcon ? _FormatIcon(icon: item.icon!) : const SizedBox.shrink();
  final Widget child = item.hasIcon
      ? (isDesktop ? _FormatIconLabel(icon: item.icon!, label: label) : iconChild)
      : Text(label);

  late final Widget button;
  switch (platform) {
    case TargetPlatform.iOS:
      button = item.hasIcon
          ? CupertinoTextSelectionToolbarButton(
              onPressed: item.onPressed,
              child: child,
            )
          : CupertinoTextSelectionToolbarButton.text(
              onPressed: item.onPressed,
              text: label,
            );
    case TargetPlatform.macOS:
      button = item.hasIcon
          ? CupertinoDesktopTextSelectionToolbarButton(
              onPressed: item.onPressed,
              child: child,
            )
          : CupertinoDesktopTextSelectionToolbarButton.text(
              onPressed: item.onPressed,
              text: label,
            );
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
      button = TextSelectionToolbarTextButton(
        padding: TextSelectionToolbarTextButton.getPadding(index, total),
        onPressed: item.onPressed,
        alignment: AlignmentDirectional.centerStart,
        child: child,
      );
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      button = _DesktopToolbarButton(
        onPressed: item.onPressed,
        child: child,
      );
  }

  return _wrapWithClickCursor(context, button);
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

bool _isDesktopPlatform(TargetPlatform platform) {
  return platform == TargetPlatform.macOS ||
      platform == TargetPlatform.windows ||
      platform == TargetPlatform.linux;
}

Widget _wrapWithClickCursor(BuildContext context, Widget child) {
  if (!_isDesktopPlatform(Theme.of(context).platform)) {
    return child;
  }
  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: child,
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

class _FormatIconLabel extends StatelessWidget {
  const _FormatIconLabel({
    required this.icon,
    required this.label,
  });

  final SvgGenImage icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.15,
      color: theme.colorScheme.onSurface,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FormatIcon(icon: icon),
        const SizedBox(width: 8),
        Text(label, style: textStyle),
      ],
    );
  }
}

class _DesktopToolbarButton extends StatelessWidget {
  const _DesktopToolbarButton({
    required this.child,
    this.onPressed,
  });

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.colorScheme.brightness == Brightness.dark;
    final Color foregroundColor = isDark ? Colors.white : Colors.black87;

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          enabledMouseCursor: SystemMouseCursors.click,
          disabledMouseCursor: SystemMouseCursors.basic,
          foregroundColor: foregroundColor,
          shape: const RoundedRectangleBorder(),
          minimumSize: const Size(kMinInteractiveDimension, 36.0),
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 3.0),
        ),
        onPressed: onPressed,
        child: child,
      ),
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

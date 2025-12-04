import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:go_router/go_router.dart';

class MessageContextMenu extends StatefulWidget {
  const MessageContextMenu({
    super.key,
    required this.isStarred,
    required this.onReply,
    required this.onCopy,
    required this.onToggleStar,
    required this.onEmojiSelected,
    this.onEdit,
    this.onDelete,
    // this.onOpenEmojiPicker,
  });

  final bool isStarred;
  final VoidCallback onReply;
  final VoidCallback? onEdit;
  final VoidCallback onCopy;
  final VoidCallback onToggleStar;
  final VoidCallback? onDelete;
  final ValueChanged<String> onEmojiSelected;

  @override
  State<MessageContextMenu> createState() => _MessageContextMenuState();
}

class _MessageContextMenuState extends State<MessageContextMenu> {
  final isEmoji = ValueNotifier(false);

  final parser = EmojiParser();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textColor = colors.onSurface.withOpacity(0.9);

    return ValueListenableBuilder(
      valueListenable: isEmoji,
      builder: (context, value, _) {
        final width = value ? 300 : 240;
        return Container(
          width: width.toDouble(),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(8.0),
          ),

          child: ValueListenableBuilder(
            valueListenable: isEmoji,
            builder: (context, value, _) {
              if (value) {
                return EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    final selected = parser.getEmoji(emoji.emoji);
                    widget.onEmojiSelected(selected.name);
                    context.pop();
                  },
                  config: Config(
                    height: 360,
                    emojiViewConfig: const EmojiViewConfig(emojiSizeMax: 22, backgroundColor: Colors.transparent),
                    categoryViewConfig: CategoryViewConfig(
                      backgroundColor: theme.colorScheme.surface,
                      iconColorSelected: theme.colorScheme.primary,
                      iconColor: theme.colorScheme.outline,
                    ),
                    bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
                  ),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ReactionsRow(
                    onEmojiSelected: widget.onEmojiSelected,
                    onOpenEmojiPicker: () {
                      isEmoji.value = !isEmoji.value;
                    },
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    textColor: textColor,
                    icon: Assets.icons.replay,
                    label: 'Ответить',
                    onTap: widget.onReply,
                  ),
                  if (widget.onEdit != null)
                    _ActionTile(
                      textColor: textColor,
                      icon: Assets.icons.edit,
                      label: 'Изменить',
                      onTap: widget.onEdit,
                    ),
                  _ActionTile(
                    textColor: textColor,
                    icon: Assets.icons.fileCopy,
                    label: 'Копировать',
                    onTap: widget.onCopy,
                  ),
                  _ActionTile(
                    textColor: textColor,
                    icon: Assets.icons.reSend,
                    label: 'Переслать',
                    onTap: () {},
                  ),
                  _ActionTile(
                    textColor: textColor,
                    icon: Assets.icons.bookmark,
                    label: widget.isStarred ? 'Убрать из важного' : 'Пометить как важное',
                    onTap: widget.onToggleStar,
                  ),
                  if (widget.onDelete != null)
                    _ActionTile(
                      textColor: textColor,
                      icon: Assets.icons.delete,
                      label: 'Удалить',
                      onTap: widget.onDelete,
                    ),
                  _ActionTile(
                    textColor: textColor,
                    icon: Assets.icons.checkCircle,
                    label: 'Выбрать',
                    onTap: () {},
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.textColor,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final Color textColor;
  final SvgGenImage icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 36.0,
      child: Material(
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const .symmetric(horizontal: 12.0),
            child: Row(
              children: [
                icon.svg(width: 20, height: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
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

class _ReactionsRow extends StatelessWidget {
  final ValueChanged<String> onEmojiSelected;
  final VoidCallback? onOpenEmojiPicker;

  const _ReactionsRow({
    required this.onEmojiSelected,
    required this.onOpenEmojiPicker,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 36.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            for (final emoji in AppConstants.popularEmojis)
              Material(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onEmojiSelected(emoji.emojiName.replaceAll(':', '')),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: UnicodeEmojiWidget(emojiDisplay: emoji, size: 20),
                  ),
                ),
              ),
            Material(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onOpenEmojiPicker,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.add, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: .3)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

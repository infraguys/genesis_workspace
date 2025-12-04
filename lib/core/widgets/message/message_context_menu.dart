import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';

class MessageContextMenu extends StatelessWidget {
  final bool isStarred;
  final VoidCallback onReply;
  final VoidCallback? onEdit;
  final VoidCallback onCopy;
  final VoidCallback onToggleStar;
  final VoidCallback? onDelete;
  final ValueChanged<String> onEmojiSelected;
  final VoidCallback? onOpenEmojiPicker;

  const MessageContextMenu({
    super.key,
    required this.isStarred,
    required this.onReply,
    required this.onCopy,
    required this.onToggleStar,
    required this.onEmojiSelected,
    this.onEdit,
    this.onDelete,
    this.onOpenEmojiPicker,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textColor = colors.onSurface.withOpacity(0.9);


    return Material(
      color: Colors.transparent,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ReactionsRow(
              onEmojiSelected: onEmojiSelected,
              onOpenEmojiPicker: onOpenEmojiPicker,
            ),
            const SizedBox(height: 10),
            _ActionTile(
              textColor: textColor,
              icon: Assets.icons.replay,
              label: 'Ответить',
              onTap: onReply,
            ),
            if (onEdit != null) _ActionTile(
              textColor: textColor,
              icon: Assets.icons.edit,
              label: 'Изменить',
              onTap: onEdit,
            ),
            _ActionTile(
              textColor: textColor,
              icon: Assets.icons.fileCopy,
              label: 'Копировать',
              onTap: onCopy,
            ),
            _ActionTile(
              textColor: textColor,
              icon: Assets.icons.bookmark,
              label: isStarred ? 'Убрать из важного' : 'Пометить как важное',
              onTap: onToggleStar,
            ),
            if (onDelete != null) _ActionTile(
              textColor: textColor,
              icon: Assets.icons.delete,
              label: 'Удалить',
              onTap: onDelete,
            ),
            _ActionTile(
              textColor: textColor,
              icon: Assets.icons.checkCircle,
              label: 'Выбрать',
              onTap: () {},
            ),
          ],
        ),
      ),
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
    final textColors = Theme.of(context).extension<TextColors>()!;
    final iconColor = textColor.withOpacity(onTap == null ? 0.4 : 0.9);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        for (final emoji in AppConstants.popularEmojis)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkResponse(
              radius: 18,
              onTap: () => onEmojiSelected(emoji.emojiName.replaceAll(':', '')),
              child: UnicodeEmojiWidget(emojiDisplay: emoji, size: 20),
            ),
          ),
        IconButton(
          tooltip: 'Еще реакции',
          onPressed: onOpenEmojiPicker,
          icon: const Icon(Icons.add),
          color: theme.colorScheme.primary,
          splashRadius: 18,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        ),
      ],
    );
  }
}

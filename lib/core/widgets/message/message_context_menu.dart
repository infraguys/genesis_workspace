import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';

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

    final actions = <_ActionTileData>[
      _ActionTileData(
        icon: Icons.reply_outlined,
        label: 'Ответить',
        onTap: onReply,
      ),
      if (onEdit != null)
        _ActionTileData(
          icon: Icons.edit_outlined,
          label: 'Изменить',
          onTap: onEdit!,
        ),
      _ActionTileData(
        icon: Icons.copy_outlined,
        label: 'Копировать текст',
        onTap: onCopy,
      ),
      _ActionTileData(
        icon: isStarred ? Icons.bookmark : Icons.bookmark_border,
        label: isStarred ? 'Убрать из важного' : 'Пометить как важное',
        onTap: onToggleStar,
      ),
      if (onDelete != null)
        _ActionTileData(
          icon: Icons.delete_outline,
          label: 'Удалить',
          onTap: onDelete!,
          destructive: true,
        ),
      _ActionTileData(
        icon: Icons.check_circle_outline,
        label: 'Выбрать',
        onTap: () {},
        disabled: true,
      ),
    ];

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 260,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ReactionsRow(
              onEmojiSelected: onEmojiSelected,
              onOpenEmojiPicker: onOpenEmojiPicker,
            ),
            const SizedBox(height: 8),
            Divider(
              color: colors.outlineVariant.withOpacity(0.4),
              height: 1,
            ),
            const SizedBox(height: 4),
            ...actions.map(
              (action) => _ActionTile(
                data: action,
                textColor: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTileData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  final bool disabled;

  _ActionTileData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
    this.disabled = false,
  });
}

class _ActionTile extends StatelessWidget {
  final _ActionTileData data;
  final Color textColor;

  const _ActionTile({
    required this.data,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = data.destructive
        ? theme.colorScheme.error
        : textColor.withOpacity(data.disabled ? 0.4 : 0.9);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: data.disabled ? null : data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(data.icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: iconColor,
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
      children: [
        for (final emoji in AppConstants.popularEmojis)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkResponse(
              radius: 18,
              onTap: () => onEmojiSelected(emoji.emojiName.replaceAll(':', '')),
              child: UnicodeEmojiWidget(emojiDisplay: emoji, size: 24),
            ),
          ),
        const Spacer(),
        IconButton(
          tooltip: 'Еще реакции',
          onPressed: onOpenEmojiPicker,
          icon: const Icon(Icons.add_reaction_outlined),
          color: theme.colorScheme.primary,
          splashRadius: 18,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';

class MessageContextMenu extends StatelessWidget {
  const MessageContextMenu({
    super.key,
    required this.onEmojiSelected,
    this.onCopy,
    this.onEdit,
    this.onDelete,
    this.onReply,
    this.onForward,
    this.onClose,
    this.title,
  });

  /// Fired with emoji name **without colons**, e.g. "thumbs_up".
  final ValueChanged<String> onEmojiSelected;

  // Actions (any null ones are hidden from the layout).
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;
  final VoidCallback? onForward;

  /// Optional close handler (e.g., to dismiss overlay/sheet).
  final VoidCallback? onClose;

  /// Optional header (e.g., “Message actions”).
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final actions = <_ActionItem>[
      if (onCopy != null) _ActionItem(label: 'Copy', icon: Icons.copy_rounded, onTap: onCopy!),
      if (onEdit != null) _ActionItem(label: 'Edit', icon: Icons.edit_rounded, onTap: onEdit!),
      if (onDelete != null)
        _ActionItem(label: 'Delete', icon: Icons.delete_rounded, onTap: onDelete!),
      if (onReply != null) _ActionItem(label: 'Reply', icon: Icons.reply_rounded, onTap: onReply!),
      if (onForward != null)
        _ActionItem(label: 'Forward', icon: Icons.forward_rounded, onTap: onForward!),
    ];

    final emojis = AppConstants.popularEmojis;

    return Container(
      width: 200,
      height: 300,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: kElevationToShadow[3],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const Spacer(),
              if (onClose != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClose,
                  tooltip: 'Close',
                ),
            ],
          ),

          // Popular emojis row/wrap
          ...[
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemBuilder: (_, i) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final name = emojis[i].emojiName.replaceAll(":", "");
                    onEmojiSelected(name);
                    onClose?.call();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Center(child: UnicodeEmojiWidget(emojiDisplay: emojis[i], size: 24)),
                  ),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 4),
                itemCount: emojis.length,
              ),
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.6)),
            const SizedBox(height: 8),
          ],

          // Actions as TextButtons
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions
                  .map(
                    (a) => TextButton.icon(
                      onPressed: a.onTap,
                      icon: Icon(a.icon, size: 18),
                      label: Text(a.label),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  _ActionItem({required this.label, required this.icon, required this.onTap});
}

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';

class ReactionsContextMenu extends StatefulWidget {
  final GlobalKey popupKey;
  const ReactionsContextMenu({
    super.key,
    required this.popupKey,
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
  State<ReactionsContextMenu> createState() => _ReactionsContextMenuState();
}

class _ReactionsContextMenuState extends State<ReactionsContextMenu> {
  bool showEmojiPicker = true;
  bool animationsEnabled = false;
  final parser = EmojiParser();

  @override
  void initState() {
    super.initState();
    // 1) После первого кадра мгновенно схлопываем (без анимации).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        showEmojiPicker = false;
        // animationsEnabled остаётся false => duration = Duration.zero
      });

      // 2) На СЛЕДУЮЩЕМ кадре включаем анимации для будущих изменений.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          animationsEnabled = true; // теперь первое открытие будет анимировано
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final actions = <_ActionItem>[
      if (widget.onCopy != null)
        _ActionItem(label: 'Copy', icon: Icons.copy_rounded, onTap: widget.onCopy!),
      if (widget.onEdit != null)
        _ActionItem(label: 'Edit', icon: Icons.edit_rounded, onTap: widget.onEdit!),
      if (widget.onDelete != null)
        _ActionItem(label: 'Delete', icon: Icons.delete_rounded, onTap: widget.onDelete!),
      if (widget.onReply != null)
        _ActionItem(label: 'Reply', icon: Icons.reply_rounded, onTap: widget.onReply!),
      if (widget.onForward != null)
        _ActionItem(label: 'Forward', icon: Icons.forward_rounded, onTap: widget.onForward!),
    ];

    final emojis = AppConstants.popularEmojis;

    return AnimatedContainer(
      duration: animationsEnabled ? const Duration(milliseconds: 300) : Duration.zero,
      curve: Curves.bounceInOut,
      width: 290,
      height: showEmojiPicker ? 365 : 65,
      constraints: BoxConstraints(maxHeight: 365, minHeight: 65),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: kElevationToShadow[3],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final emoji in emojis)
                InkWell(
                  onTap: () {
                    widget.onEmojiSelected(emoji.emojiName.replaceAll(":", ""));
                    if (widget.onClose != null) {
                      widget.onClose!();
                    }
                  },
                  child: UnicodeEmojiWidget(emojiDisplay: emoji, size: 24),
                ),
              AnimatedSwitcher(
                duration: animationsEnabled ? const Duration(milliseconds: 200) : Duration.zero,
                transitionBuilder: (child, animation) =>
                    RotationTransition(turns: animation, child: child),
                child: IconButton(
                  key: ValueKey(showEmojiPicker),
                  icon: Icon((showEmojiPicker) ? Icons.close : Icons.add_reaction_outlined),
                  onPressed: () {
                    setState(() {
                      showEmojiPicker = !showEmojiPicker;
                    });
                  },
                ),
              ),
            ],
          ),
          AnimatedContainer(
            duration: animationsEnabled ? const Duration(milliseconds: 300) : Duration.zero,
            height: showEmojiPicker ? 300 : 0,
            child: showEmojiPicker || animationsEnabled
                ? EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      final fullEmoji = parser.getEmoji(emoji.emoji);
                      widget.onEmojiSelected(fullEmoji.name);
                      if (widget.onClose != null) {
                        widget.onClose!();
                      }
                    },
                    config: Config(
                      height: 300,
                      emojiViewConfig: const EmojiViewConfig(
                        emojiSizeMax: 22,
                        backgroundColor: Colors.transparent,
                      ),
                      categoryViewConfig: CategoryViewConfig(
                        backgroundColor: theme.colorScheme.surface,
                        iconColorSelected: theme.colorScheme.primary,
                        iconColor: theme.colorScheme.outline,
                      ),
                      bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
                    ),
                  )
                : const SizedBox.shrink(),
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

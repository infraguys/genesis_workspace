import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';

class ReactionsContextMenu extends StatefulWidget {
  final GlobalKey popupKey;
  final int messageId;
  const ReactionsContextMenu({
    super.key,
    required this.popupKey,
    required this.onEmojiSelected,
    this.onCopy,
    this.onEdit,
    this.onDelete,
    this.onReply,
    this.onForward,
    this.title,
    required this.messageId,
  });

  /// Fired with emoji name **without colons**, e.g. "thumbs_up".
  final Function(String) onEmojiSelected;

  // Actions (any null ones are hidden from the layout).
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;
  final VoidCallback? onForward;

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
                  onTap: () async {
                    // await widget.onEmojiSelected(emoji.emojiName.replaceAll(":", ""));
                    await context.read<MessagesCubit>().addEmojiReaction(
                      widget.messageId,
                      emojiName: emoji.emojiName.replaceAll(":", ""),
                    );
                    Navigator.of(context).pop();
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
            child: showEmojiPicker
                ? EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      final fullEmoji = parser.getEmoji(emoji.emoji);
                      widget.onEmojiSelected(fullEmoji.name);
                      Navigator.of(context).pop();
                    },
                    config: Config(
                      height: showEmojiPicker ? 300 : 0,
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

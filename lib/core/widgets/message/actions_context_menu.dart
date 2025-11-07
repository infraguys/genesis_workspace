import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';
import 'package:genesis_workspace/core/widgets/message/message_actions.dart';

class ActionsContextMenu extends StatefulWidget {
  final GlobalKey popupKey;
  final int messageId;
  final bool isStarred;
  final bool isMyMessage;

  const ActionsContextMenu({
    super.key,
    required this.popupKey,
    required this.onEmojiSelected,
    required this.onTapStarred,
    required this.onTapDelete,
    required this.isStarred,
    required this.isMyMessage,
    required this.messageId,
    required this.onTapQuote,
    required this.onTapEdit,
  });

  /// Fired with emoji name **without colons**, e.g. "thumbs_up".
  final Function(String emojiValue) onEmojiSelected;
  final Function() onTapStarred;
  final Function() onTapDelete;
  final Function() onTapQuote;
  final Function() onTapEdit;

  @override
  State<ActionsContextMenu> createState() => _ActionsContextMenuState();
}

class _ActionsContextMenuState extends State<ActionsContextMenu> {
  bool showEmojiPicker = true;
  bool animationsEnabled = false;
  final parser = EmojiParser();
  late bool isStarred;
  late NavigatorState navigator;

  @override
  void initState() {
    super.initState();
    // 1) После первого кадра мгновенно схлопываем (без анимации).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        showEmojiPicker = false;
      });

      // 2) На СЛЕДУЮЩЕМ кадре включаем анимации для будущих изменений.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          animationsEnabled = true; // теперь первое открытие будет анимировано
        });
      });
    });

    isStarred = widget.isStarred;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigator = Navigator.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final emojis = AppConstants.popularEmojis;

    return AnimatedContainer(
      duration: animationsEnabled ? const Duration(milliseconds: 300) : Duration.zero,
      curve: Curves.bounceInOut,
      width: 290,
      height: showEmojiPicker ? 405 : 105,
      constraints: BoxConstraints(maxHeight: 405, minHeight: 105),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
                    widget.onEmojiSelected(emoji.emojiName.replaceAll(":", ""));
                    if (mounted) {
                      navigator.pop();
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
            child: showEmojiPicker
                ? EmojiPicker(
                    onEmojiSelected: (category, emoji) async {
                      final fullEmoji = parser.getEmoji(emoji.emoji);
                      widget.onEmojiSelected(fullEmoji.name);
                      if (mounted) {
                        navigator.pop();
                      }
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
          MessageActions(
            isMyMessage: widget.isMyMessage,
            onTapQuote: () {
              widget.onTapQuote();
              if (mounted) {
                navigator.pop();
              }
            },
            onTapEdit: () {
              widget.onTapEdit();
              if (mounted) {
                navigator.pop();
              }
            },
            onTapStarred: () async {
              setState(() {
                isStarred = !isStarred;
              });
              await widget.onTapStarred();
            },
            onTapDelete: () async {
              await widget.onTapDelete();
              if (mounted) {
                navigator.pop();
              }
            },
            isStarred: isStarred,
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

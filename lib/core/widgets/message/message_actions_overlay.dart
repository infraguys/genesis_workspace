import 'dart:ui';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';

class MessageActionsOverlay extends StatefulWidget {
  final Offset position;
  final MessageEntity message;
  final Widget messageContent;
  final bool isOwnMessage;
  final VoidCallback onClose;
  final Function(String emojiName) onEmojiSelected;

  const MessageActionsOverlay({
    super.key,
    required this.position,
    required this.message,
    required this.messageContent,
    required this.isOwnMessage,
    required this.onClose,
    required this.onEmojiSelected,
  });

  @override
  State<MessageActionsOverlay> createState() => _MessageActionsOverlayState();
}

class _MessageActionsOverlayState extends State<MessageActionsOverlay> {
  bool showEmojiPicker = false;
  bool isStarred = false;

  final parser = EmojiParser();

  @override
  void initState() {
    isStarred = widget.message.flags?.contains(MessageFlag.starred.name) ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Блюр фона
          GestureDetector(
            onTap: widget.onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black26),
            ),
          ),

          // Контент
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: 1),
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: showEmojiPicker ? 360 : 56,
                    width: showEmojiPicker ? MediaQuery.sizeOf(context).width * 0.9 : 280,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 6, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 56,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 8),
                              for (final emoji in AppConstants.popularEmojis)
                                GestureDetector(
                                  onTap: () {
                                    widget.onEmojiSelected(emoji.emojiName.replaceAll(":", ""));
                                    widget.onClose();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: UnicodeEmojiWidget(emojiDisplay: emoji, size: 24),
                                  ),
                                ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) =>
                                    RotationTransition(turns: animation, child: child),
                                child: IconButton(
                                  key: ValueKey(showEmojiPicker),
                                  icon: Icon(
                                    showEmojiPicker ? Icons.close : Icons.add_reaction_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showEmojiPicker = !showEmojiPicker;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // EmojiPicker
                        if (showEmojiPicker)
                          SizedBox(
                            height: 300,
                            child: EmojiPicker(
                              onEmojiSelected: (category, emoji) {
                                final fullEmoji = parser.getEmoji(emoji.emoji);
                                widget.onEmojiSelected(fullEmoji.name);
                                widget.onClose();
                              },
                              config: Config(
                                height: 250,
                                emojiViewConfig: const EmojiViewConfig(
                                  emojiSizeMax: 28,
                                  backgroundColor: Colors.transparent,
                                ),
                                categoryViewConfig: CategoryViewConfig(
                                  backgroundColor: theme.colorScheme.surface,
                                  iconColorSelected: theme.colorScheme.primary,
                                  iconColor: theme.colorScheme.outline,
                                ),
                                bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.isOwnMessage
                            ? theme.colorScheme.secondaryContainer.withAlpha(128)
                            : theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: widget.messageContent,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔹 Контекстные действия
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 6, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (isStarred) {
                              setState(() {
                                isStarred = false;
                              });
                              await context.read<MessagesCubit>().removeStarredFlag(
                                widget.message.id,
                              );
                            } else {
                              setState(() {
                                isStarred = true;
                              });
                              await context.read<MessagesCubit>().addStarredFlag(widget.message.id);
                            }
                          },
                          icon: Icon(
                            isStarred ? Icons.star : Icons.star_border,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.delete, color: theme.colorScheme.error),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.copy, color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

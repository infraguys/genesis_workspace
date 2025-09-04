import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final bool isMessagePending;
  final FocusNode focusNode;

  const MessageInput({
    super.key,
    required this.controller,
    this.onSend,
    required this.isMessagePending,
    required this.focusNode,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  // bool _keyboardOpen = false;

  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (currentSize(context) >= ScreenSize.lTablet) {
      context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(false);
    } else {
      context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(false, closeKeyboard: true);
      _keyboardHeightPlugin.onKeyboardHeightChanged((double height) {
        if (height != 0) {
          context.read<EmojiKeyboardCubit>().setHeight(height);
        }
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _keyboardHeightPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<EmojiKeyboardCubit, EmojiKeyboardState>(
      builder: (context, emojiState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4).copyWith(bottom: 20),
              decoration: BoxDecoration(color: theme.colorScheme.surface),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        minLines: 1,
                        maxLines: 4,
                        onTap: () {
                          if (currentSize(context) < ScreenSize.lTablet) {
                            context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(false);
                          }
                        },
                        textInputAction: TextInputAction.send,
                        onSubmitted: (value) {
                          if (widget.onSend != null) {
                            widget.onSend!();
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Message",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixIcon: IconButton(
                            onPressed: () {
                              if (currentSize(context) >= ScreenSize.lTablet) {
                                if (emojiState.showEmojiKeyboard) {
                                  context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(
                                    false,
                                    closeKeyboard: true,
                                  );
                                } else {
                                  context.read<EmojiKeyboardCubit>().setHeight(300);
                                  context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(true);
                                }
                              } else {
                                if (emojiState.showEmojiKeyboard) {
                                  FocusScope.of(context).requestFocus(widget.focusNode);
                                  context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(false);
                                } else {
                                  FocusScope.of(context).unfocus();
                                  if (emojiState.keyboardHeight == 0) {
                                    context.read<EmojiKeyboardCubit>().setHeight(300);
                                  }
                                  context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(true);
                                }
                              }
                            },
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) => RotationTransition(
                                turns: child.key == const ValueKey('emoji')
                                    ? Tween<double>(begin: 0.75, end: 1.0).animate(animation)
                                    : Tween<double>(begin: 1.25, end: 1.0).animate(animation),
                                child: FadeTransition(opacity: animation, child: child),
                              ),
                              child: emojiState.showEmojiKeyboard
                                  ? const Icon(Icons.keyboard, key: ValueKey('keyboard'))
                                  : const Icon(Icons.emoji_emotions, key: ValueKey('emoji')),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: widget.onSend,
                    child: const Icon(Icons.send),
                  ).pending(widget.isMessagePending),
                ],
              ),
            ),
            AnimatedContainer(
              height: emojiState.keyboardHeight,
              duration: Duration(milliseconds: 250),
              child: EmojiPicker(
                textEditingController: widget.controller,
                onEmojiSelected: (_, _) {
                  widget.focusNode.requestFocus();
                },
                config: Config(
                  height: emojiState.keyboardHeight,
                  bottomActionBarConfig: BottomActionBarConfig(enabled: true),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

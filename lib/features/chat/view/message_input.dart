import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final bool isMessagePending;

  const MessageInput({
    super.key,
    required this.controller,
    this.onSend,
    required this.isMessagePending,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _keyboardOpen = false;

  final FocusNode _textFieldFocusNode = FocusNode();

  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();

  @override
  void initState() {
    super.initState();
    _keyboardHeightPlugin.onKeyboardHeightChanged((double height) {
      if (height != 0) {
        context.read<EmojiKeyboardCubit>().setHeight(height);
      }
    });
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4).copyWith(
                bottom: (_textFieldFocusNode.hasFocus || emojiState.showEmojiKeyboard) ? 20 : 30,
              ),
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
                        focusNode: _textFieldFocusNode,
                        minLines: 1,
                        maxLines: 4,
                        onTap: () {
                          context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(true);
                          setState(() {
                            _keyboardOpen = true;
                          });
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Message",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                if (_keyboardOpen) {
                                  _keyboardOpen = false;
                                  FocusScope.of(context).unfocus();
                                } else {
                                  _keyboardOpen = true;
                                  FocusScope.of(context).requestFocus(_textFieldFocusNode);
                                }
                              });
                            },
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) => RotationTransition(
                                turns: child.key == const ValueKey('emoji')
                                    ? Tween<double>(begin: 0.75, end: 1.0).animate(animation)
                                    : Tween<double>(begin: 1.25, end: 1.0).animate(animation),
                                child: FadeTransition(opacity: animation, child: child),
                              ),
                              child: _keyboardOpen
                                  ? const Icon(Icons.emoji_emotions, key: ValueKey('emoji'))
                                  : const Icon(Icons.keyboard, key: ValueKey('keyboard')),
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
                config: Config(
                  height: emojiState.keyboardHeight,
                  bottomActionBarConfig: BottomActionBarConfig(enabled: false),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

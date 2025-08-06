import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
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
  bool _showEmojiPicker = true;
  double _keyboardHeight = 0;
  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();

  final FocusNode _textFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _keyboardHeightPlugin.onKeyboardHeightChanged((double height) {
      inspect(height);
      setState(() {
        _keyboardHeight = height;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 4,
            // ).copyWith(bottom: (_textFieldFocusNode.hasFocus || _showEmojiPicker) ? 10 : 30),
          ).copyWith(bottom: 30),
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
                      setState(() {
                        _showEmojiPicker = false; // при фокусе скрываем эмодзи
                      });
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Message",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      // suffixIcon: IconButton(
                      //   onPressed: () {
                      //     setState(() {
                      //       if (_showEmojiPicker) {
                      //         // Если открыт эмодзи-пикер → переключаем на клавиатуру
                      //         _showEmojiPicker = false;
                      //         FocusScope.of(context).requestFocus(_textFieldFocusNode);
                      //       } else {
                      //         // Если клавиатура открыта → переключаем на эмодзи-пикер
                      //         _showEmojiPicker = true;
                      //         FocusScope.of(context).unfocus();
                      //       }
                      //     });
                      //   },
                      //   icon: AnimatedSwitcher(
                      //     duration: const Duration(milliseconds: 200),
                      //     transitionBuilder: (child, animation) => RotationTransition(
                      //       turns: child.key == const ValueKey('emoji')
                      //           ? Tween<double>(begin: 0.75, end: 1.0).animate(animation)
                      //           : Tween<double>(begin: 1.25, end: 1.0).animate(animation),
                      //       child: FadeTransition(opacity: animation, child: child),
                      //     ),
                      //     child: _showEmojiPicker
                      //         ? const Icon(Icons.keyboard, key: ValueKey('keyboard'))
                      //         : const Icon(Icons.emoji_emotions, key: ValueKey('emoji')),
                      //   ),
                      // ),
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
        // AnimatedContainer(
        //   height: _keyboardHeight,
        //   duration: Duration(milliseconds: 300),
        //   child: EmojiPicker(
        //     textEditingController: widget.controller,
        //     config: Config(
        //       height: _keyboardHeight,
        //       bottomActionBarConfig: BottomActionBarConfig(enabled: false),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

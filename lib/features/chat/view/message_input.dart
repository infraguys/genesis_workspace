import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;

  const MessageInput({super.key, required this.controller, this.onSend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4).copyWith(bottom: 30),
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(border: InputBorder.none, hintText: "Message"),
              ),
            ),
          ),
          Material(
            color: theme.colorScheme.primary,
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}

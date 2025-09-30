import 'package:flutter/material.dart';

class ChatTextEditingController extends TextEditingController {
  ChatTextEditingController({super.text});

  final mentionRegExp = RegExp(r'@\*\*(.*?)\*\*');

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> children = [];
    final text = this.text;

    int start = 0;
    for (final match in mentionRegExp.allMatches(text)) {
      if (match.start > start) {
        children.add(TextSpan(text: text.substring(start, match.start), style: style));
      }

      final nickname = match.group(1)!;

      children.add(
        TextSpan(
          text: '@$nickname',
          style: style?.copyWith(fontWeight: FontWeight.w600),
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      children.add(TextSpan(text: text.substring(start), style: style));
    }

    return TextSpan(style: style, children: children);
  }
}

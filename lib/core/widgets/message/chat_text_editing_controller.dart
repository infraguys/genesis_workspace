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
    return TextSpan(style: style, text: text);
  }
}

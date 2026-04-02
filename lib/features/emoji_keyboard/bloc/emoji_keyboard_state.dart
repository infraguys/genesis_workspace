part of 'emoji_keyboard_cubit.dart';

class EmojiKeyboardState {
  final bool showEmojiKeyboard;
  final double keyboardHeight;
  final Set<String> organizationEmojiCodes;
  final Map<String, List<String>> emojiMap;
  EmojiKeyboardState({
    required this.showEmojiKeyboard,
    required this.keyboardHeight,
    required this.organizationEmojiCodes,
    required this.emojiMap,
  });

  EmojiKeyboardState copyWith({
    bool? showEmojiKeyboard,
    double? keyboardHeight,
    Set<String>? organizationEmojiCodes,
    Map<String, List<String>>? emojiMap,
  }) {
    return EmojiKeyboardState(
      showEmojiKeyboard: showEmojiKeyboard ?? this.showEmojiKeyboard,
      keyboardHeight: keyboardHeight ?? this.keyboardHeight,
      organizationEmojiCodes: organizationEmojiCodes ?? this.organizationEmojiCodes,
      emojiMap: emojiMap ?? this.emojiMap,
    );
  }
}

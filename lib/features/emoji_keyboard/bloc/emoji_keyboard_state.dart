part of 'emoji_keyboard_cubit.dart';

class EmojiKeyboardState {
  bool showEmojiKeyboard;
  double keyboardHeight;
  EmojiKeyboardState({required this.showEmojiKeyboard, required this.keyboardHeight});

  EmojiKeyboardState copyWith({bool? showEmojiKeyboard, double? keyboardHeight}) {
    return EmojiKeyboardState(
      showEmojiKeyboard: showEmojiKeyboard ?? this.showEmojiKeyboard,
      keyboardHeight: keyboardHeight ?? this.keyboardHeight,
    );
  }
}

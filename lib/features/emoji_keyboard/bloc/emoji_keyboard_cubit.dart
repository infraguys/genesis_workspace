import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'emoji_keyboard_state.dart';

@LazySingleton()
class EmojiKeyboardCubit extends Cubit<EmojiKeyboardState> {
  EmojiKeyboardCubit() : super(EmojiKeyboardState(showEmojiKeyboard: false, keyboardHeight: 0));

  setHeight(double height) {
    emit(state.copyWith(keyboardHeight: height));
  }

  setShowEmojiKeyboard(bool show, {bool? closeKeyboard = false}) {
    double updatedHeight = state.keyboardHeight;
    if (closeKeyboard == true) {
      updatedHeight = 0;
    }
    emit(
      state.copyWith(
        showEmojiKeyboard: show,
        keyboardHeight: updatedHeight,
      ),
    );
  }
}

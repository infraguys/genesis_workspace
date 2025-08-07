import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'emoji_keyboard_state.dart';

@LazySingleton()
class EmojiKeyboardCubit extends Cubit<EmojiKeyboardState> {
  EmojiKeyboardCubit() : super(EmojiKeyboardState(showEmojiKeyboard: false, keyboardHeight: 0));

  setHeight(double height) {
    emit(state.copyWith(keyboardHeight: height));
  }

  setShowEmojiKeyboard(bool show, {bool? closeKeyboard}) {
    state.showEmojiKeyboard = show;
    if (closeKeyboard == true) {
      state.keyboardHeight = 0;
    }
    emit(
      state.copyWith(
        showEmojiKeyboard: state.showEmojiKeyboard,
        keyboardHeight: state.keyboardHeight,
      ),
    );
  }
}

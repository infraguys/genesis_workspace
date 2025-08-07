import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

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

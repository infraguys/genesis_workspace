import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/widgets/tap_effect_icon.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';

class ToggleEmojiKeyboardButton extends StatelessWidget {
  final EmojiKeyboardState emojiState;
  final FocusNode focusNode;
  const ToggleEmojiKeyboardButton({super.key, required this.emojiState, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    return TapEffectIcon(
      onTapDown: (_) {
        if (currentSize(context) >= ScreenSize.lTablet) {
          if (emojiState.showEmojiKeyboard) {
            context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(
              false,
              closeKeyboard: true,
            );
          } else {
            context.read<EmojiKeyboardCubit>().setHeight(300);
            context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(true);
          }
        } else {
          if (emojiState.showEmojiKeyboard) {
            FocusScope.of(context).requestFocus(focusNode);
            context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(
              false,
            );
          } else {
            FocusScope.of(context).unfocus();
            if (emojiState.keyboardHeight == 0) {
              // context.read<EmojiKeyboardCubit>().setHeight(335);
              context.read<EmojiKeyboardCubit>().setHeight(300);
            }
            context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(
              true,
            );
          }
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: child.key == const ValueKey('emoji')
              ? Tween<double>(begin: 0.75, end: 1.0).animate(animation)
              : Tween<double>(begin: 1.25, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: emojiState.showEmojiKeyboard
            ? Icon(
                Icons.keyboard,
                color: textColors.text30,
                key: ValueKey('keyboard'),
              )
            : Assets.icons.smile.svg(
                colorFilter: ColorFilter.mode(
                  textColors.text30,
                  .srcIn,
                ),
              ),
      ),
    );
  }
}

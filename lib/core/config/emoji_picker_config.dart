import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

Config emojiPickerConfig(
  BuildContext context, {
  required ThemeData theme,
}) {
  final height = context.read<EmojiKeyboardCubit>().state.keyboardHeight;
  return Config(
    height: height,
    skinToneConfig: SkinToneConfig(
      dialogBackgroundColor: theme.colorScheme.surface,
    ),
    bottomActionBarConfig: BottomActionBarConfig(
      enabled: false,
      backgroundColor: theme.colorScheme.surface,
      buttonColor: theme.colorScheme.primary,
      buttonIconColor: theme.colorScheme.onSurface,
    ),
    searchViewConfig: SearchViewConfig(
      backgroundColor: theme.colorScheme.surface,
      buttonIconColor: theme.colorScheme.onSurface,
    ),
    emojiViewConfig: EmojiViewConfig(
      backgroundColor: theme.colorScheme.surface,
      noRecents: Text(
        context.t.emoji.noRecent,
        style: theme.textTheme.labelLarge,
      ),
    ),
    categoryViewConfig: CategoryViewConfig(
      indicatorColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      iconColor: theme.colorScheme.onSurface,
      iconColorSelected: theme.colorScheme.primary,
      dividerColor: theme.colorScheme.onSurface.withOpacity(0.12),
    ),
  );
}

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:emoji_picker_flutter/locales/default_emoji_set_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

String toEmojiCode(String emoji) => emoji.runes.map((r) => r.toRadixString(16)).join('-');

List<CategoryEmoji> buildLimitedEmojiSet(
  Locale locale,
  Set<String> allowedCodes,
) {
  final base = getDefaultEmojiLocale(locale);

  return base
      .map(
        (c) => CategoryEmoji(
          c.category,
          c.emoji.where((e) => allowedCodes.contains(toEmojiCode(e.emoji))).toList(),
        ),
      )
      .where((c) => c.emoji.isNotEmpty)
      .toList();
}

Config emojiPickerConfig(
  BuildContext context, {
  required ThemeData theme,
  Set<String>? allowedCodes,
}) {
  final height = context.read<EmojiKeyboardCubit>().state.keyboardHeight;
  return Config(
    height: height,
    emojiSet: allowedCodes == null ? null : (locale) => buildLimitedEmojiSet(locale, allowedCodes),
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

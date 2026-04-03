import 'package:flutter/material.dart';

part 'blue_cold_palette.dart';
part 'orange_warm_palette.dart';

abstract interface class ThemePalette {
  final String id;
  final String title;
  final ColorScheme lightColorScheme;
  final ColorScheme darkColorScheme;
  final TextColors lightTextColors;
  final TextColors darkTextColors;
  final MessageColors lightMessageColors;
  final MessageColors darkMessageColors;
  final CardColors lightCardColors;
  final CardColors darkCardColors;
  final IconColors lightIconColors;
  final IconColors darkIconColors;
  final NoticeColors lightNoticeColors;
  final NoticeColors darkNoticeColors;
  final Color darkTextFieldBackground;
  final Color lightTextFieldBackground;

  const ThemePalette({
    required this.id,
    required this.title,
    required this.lightColorScheme,
    required this.darkColorScheme,
    required this.lightTextColors,
    required this.darkTextColors,
    required this.lightMessageColors,
    required this.darkMessageColors,
    required this.lightCardColors,
    required this.darkCardColors,
    required this.lightIconColors,
    required this.darkIconColors,
    required this.lightNoticeColors,
    required this.darkNoticeColors,
    required this.darkTextFieldBackground,
    required this.lightTextFieldBackground,
  });

  ColorScheme colorSchemeFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkColorScheme : lightColorScheme;
  }

  TextColors textColorsFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextColors : lightTextColors;
  }

  MessageColors messageColorsFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkMessageColors : lightMessageColors;
  }

  IconColors iconColorsFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkIconColors : lightIconColors;
  }

  CardColors cardColorsFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkCardColors : lightCardColors;
  }

  NoticeColors noticeColorsFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkNoticeColors : lightNoticeColors;
  }

  List<ThemeExtension<dynamic>> extensionsFor(Brightness brightness) {
    return [
      textColorsFor(brightness),
      cardColorsFor(brightness),
      messageColorsFor(brightness),
      iconColorsFor(brightness),
      noticeColorsFor(brightness),
    ];
  }
}

@immutable
class IconColors extends ThemeExtension<IconColors> {
  final Color base;
  final Color disable;
  final Color hover;
  final Color active;
  final Color hoverBackground;

  const IconColors({
    required this.base,
    required this.disable,
    required this.hover,
    required this.active,
    required this.hoverBackground,
  });

  @override
  IconColors copyWith({
    Color? base,
    Color? disable,
    Color? hover,
    Color? active,
    Color? hoverBackground,
  }) {
    return IconColors(
      base: base ?? this.base,
      disable: disable ?? this.disable,
      hover: hover ?? this.hover,
      active: active ?? this.active,
      hoverBackground: hoverBackground ?? this.hoverBackground,
    );
  }

  @override
  IconColors lerp(ThemeExtension<IconColors>? other, double t) {
    if (other is! IconColors) return this;
    return IconColors(
      base: Color.lerp(base, other.base, t)!,
      disable: Color.lerp(disable, other.disable, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      active: Color.lerp(active, other.active, t)!,
      hoverBackground: Color.lerp(hoverBackground, other.hoverBackground, t)!,
    );
  }
}

@immutable
class TextColors extends ThemeExtension<TextColors> {
  final Color text100;
  final Color text50;
  final Color text30;

  const TextColors({
    required this.text100,
    required this.text50,
    required this.text30,
  });

  @override
  TextColors copyWith({
    Color? text100,
    Color? text50,
    Color? text30,
  }) {
    return TextColors(
      text100: text100 ?? this.text100,
      text50: text50 ?? this.text50,
      text30: text30 ?? this.text30,
    );
  }

  @override
  TextColors lerp(ThemeExtension<TextColors>? other, double t) {
    if (other is! TextColors) return this;
    return TextColors(
      text100: Color.lerp(text100, other.text100, t)!,
      text50: Color.lerp(text50, other.text50, t)!,
      text30: Color.lerp(text30, other.text30, t)!,
    );
  }
}

@immutable
class CardColors extends ThemeExtension<CardColors> {
  final Color base;
  final Color active;

  const CardColors({
    required this.base,
    required this.active,
  });

  @override
  CardColors copyWith({
    Color? base,
    Color? active,
    Color? onBackgroundCard,
  }) {
    return CardColors(
      base: base ?? this.base,
      active: active ?? this.active,
    );
  }

  @override
  CardColors lerp(ThemeExtension<CardColors>? other, double t) {
    if (other is! CardColors) return this;
    return CardColors(
      base: Color.lerp(base, other.base, t)!,
      active: Color.lerp(active, other.active, t)!,
    );
  }
}

@immutable
class MessageColors extends ThemeExtension<MessageColors> {
  final Color background;
  final Color ownBackground;
  final Color timeColor;
  final Color activeCallBackground;
  final Color selectedMessageForeground;

  const MessageColors({
    required this.background,
    required this.ownBackground,
    required this.timeColor,
    required this.activeCallBackground,
    required this.selectedMessageForeground,
  });

  @override
  MessageColors copyWith({
    Color? background,
    Color? ownBackground,
    Color? timeColor,
    Color? senderNameColor,
    Color? activeCallBackground,
    Color? selectedMessageForeground,
  }) {
    return MessageColors(
      background: background ?? this.background,
      ownBackground: ownBackground ?? this.ownBackground,
      timeColor: timeColor ?? this.timeColor,
      activeCallBackground: activeCallBackground ?? this.activeCallBackground,
      selectedMessageForeground: selectedMessageForeground ?? this.selectedMessageForeground,
    );
  }

  @override
  MessageColors lerp(ThemeExtension<MessageColors>? other, double t) {
    if (other is! MessageColors) return this;
    return MessageColors(
      background: Color.lerp(background, other.background, t)!,
      ownBackground: Color.lerp(ownBackground, other.ownBackground, t)!,
      timeColor: Color.lerp(timeColor, other.timeColor, t)!,
      activeCallBackground: Color.lerp(activeCallBackground, other.activeCallBackground, t)!,
      selectedMessageForeground: Color.lerp(selectedMessageForeground, other.selectedMessageForeground, t)!,
    );
  }
}

@immutable
class NoticeColors extends ThemeExtension<NoticeColors> {
  final Color noticeBase;
  final Color noticeDisable;
  final Color onBadge;
  final Color counterBadge;

  const NoticeColors({
    required this.noticeBase,
    required this.noticeDisable,
    required this.onBadge,
    required this.counterBadge,
  });

  @override
  NoticeColors copyWith({
    Color? noticeBase,
    Color? noticeDisable,
    Color? onBadge,
    Color? counterBadge,
  }) {
    return NoticeColors(
      noticeBase: noticeBase ?? this.noticeBase,
      noticeDisable: noticeDisable ?? this.noticeDisable,
      onBadge: onBadge ?? this.onBadge,
      counterBadge: counterBadge ?? this.counterBadge,
    );
  }

  @override
  NoticeColors lerp(ThemeExtension<NoticeColors>? other, double t) {
    if (other is! NoticeColors) return this;
    return NoticeColors(
      noticeBase: Color.lerp(noticeBase, other.noticeBase, t)!,
      noticeDisable: Color.lerp(noticeDisable, other.noticeDisable, t)!,
      onBadge: Color.lerp(onBadge, other.onBadge, t)!,
      counterBadge: Color.lerp(counterBadge, other.counterBadge, t)!,
    );
  }
}

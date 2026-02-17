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

  CardColors cardColorsFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkCardColors : lightCardColors;
  }

  List<ThemeExtension<dynamic>> extensionsFor(Brightness brightness) {
    return [
      textColorsFor(brightness),
      cardColorsFor(brightness),
      messageColorsFor(brightness),
    ];
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
  final Color onBackgroundCard;

  const CardColors({
    required this.base,
    required this.active,
    required this.onBackgroundCard,
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
      onBackgroundCard: onBackgroundCard ?? this.onBackgroundCard,
    );
  }

  @override
  CardColors lerp(ThemeExtension<CardColors>? other, double t) {
    if (other is! CardColors) return this;
    return CardColors(
      base: Color.lerp(base, other.base, t)!,
      active: Color.lerp(active, other.active, t)!,
      onBackgroundCard: Color.lerp(onBackgroundCard, other.onBackgroundCard, t)!,
    );
  }
}

@immutable
class MessageColors extends ThemeExtension<MessageColors> {
  final Color background;
  final Color ownBackground;
  final Color timeColor;
  final Color senderNameColor;
  final Color activeCallBackground;
  final Color selectedMessageForeground;

  const MessageColors({
    required this.background,
    required this.ownBackground,
    required this.timeColor,
    required this.senderNameColor,
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
      senderNameColor: senderNameColor ?? this.senderNameColor,
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
      senderNameColor: Color.lerp(senderNameColor, other.senderNameColor, t)!,
      activeCallBackground: Color.lerp(activeCallBackground, other.activeCallBackground, t)!,
      selectedMessageForeground: Color.lerp(selectedMessageForeground, other.selectedMessageForeground, t)!,
    );
  }
}

import 'package:flutter/material.dart';

class AppColors {
  static const Color counterBadge = Color(0xffFF0000);
  static const Color onBadge = Color(0xffFFFFFF);
  static const Color primary = Color(0xffFF8438);
  static const Color callGreen = Color(0xff26C038);
  static const Color noticeDisabled = Color(0xff5C5855);

  static const Color darkOnPrimary = Color(0xff1B1B1D);
  static const Color darkBackground = Color(0xff1B1B1D);
  static const Color darkSurface = Color(0xff333333);

  static final darkTextColors = TextColors(
    text100: Color(0xFFFFFFFF),
    text50: Color(0xFFFFFFFF).withValues(alpha: 0.5),
    text30: Color(0xFFFFFFFF).withValues(alpha: 0.3),
  );
  static final darkMessageColors = MessageColors(
    background: Color(0xff333333),
    ownBackground: Color(0xff47382B),
    timeColor: Color(0xffFFFFFF).withValues(alpha: 0.5),
    senderNameColor: primary,
    activeCallBackground: Color(0xff1C2B20),
  );
  static final darkCardColors = CardColors(
    base: Color(0xFFFFFFFF).withValues(alpha: 0.02),
    active: Color(0xFFFFFFFF).withValues(alpha: 0.1),
  );
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
  final Color senderNameColor;
  final Color activeCallBackground;

  const MessageColors({
    required this.background,
    required this.ownBackground,
    required this.timeColor,
    required this.senderNameColor,
    required this.activeCallBackground,
  });

  @override
  MessageColors copyWith({
    Color? background,
    Color? ownBackground,
    Color? timeColor,
    Color? senderNameColor,
    Color? activeCallBackground,
  }) {
    return MessageColors(
      background: background ?? this.background,
      ownBackground: ownBackground ?? this.ownBackground,
      timeColor: timeColor ?? this.timeColor,
      senderNameColor: senderNameColor ?? this.senderNameColor,
      activeCallBackground: activeCallBackground ?? this.activeCallBackground,
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
    );
  }
}

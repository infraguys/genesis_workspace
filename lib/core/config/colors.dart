import 'package:flutter/material.dart';

class AppColors {
  static const Color counterBadge = Color(0xffFF0000);
  static const Color onBadge = Color(0xffFFFFFF);
  static const Color primary = Color(0xffFF8438);
  static const Color surface = Color(0xff333333);
  static const Color background = Color(0xff1B1B1D);

  static final darkTextColors = TextColors(
    text100: Color(0xFFFFFFFF),
    text30: Color(0xFFFFFFFF).withValues(alpha: 0.3),
  );
}

@immutable
class TextColors extends ThemeExtension<TextColors> {
  final Color text100;
  final Color text30;

  const TextColors({required this.text100, required this.text30});

  @override
  TextColors copyWith({Color? text100, Color? text30}) {
    return TextColors(text100: text100 ?? this.text100, text30: text30 ?? this.text30);
  }

  @override
  TextColors lerp(ThemeExtension<TextColors>? other, double t) {
    if (other is! TextColors) return this;
    return TextColors(
      text100: Color.lerp(text100, other.text100, t)!,
      text30: Color.lerp(text30, other.text30, t)!,
    );
  }
}

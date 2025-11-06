import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/gen/fonts.gen.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: darkColorScheme,
  badgeTheme: _badgeTheme,
  fontFamily: FontFamily.montserrat,
  scaffoldBackgroundColor: const Color(0xff1B1B1D),
  inputDecorationTheme: _darkInputDecorationTheme,
  extensions: [AppColors.darkTextColors, AppColors.darkCardColors, AppColors.darkMessageColors],
  cardTheme: CardThemeData(),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    linearTrackColor: const Color(0xff333333),
    stopIndicatorRadius: 12,
  ),
);

final darkColorScheme = ColorScheme.dark(
  primary: AppColors.primary,
  surface: const Color(0xff333333),
);

final _badgeTheme = BadgeThemeData(
  backgroundColor: AppColors.counterBadge,
  textColor: AppColors.onBadge,
  textStyle: TextStyle(fontSize: 12),
);

final _darkInputDecorationTheme = InputDecorationTheme(
  filled: true,
  fillColor: const Color(0x1AFFFFFF),
  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.2),
  ),
  hintStyle: const TextStyle(color: Color(0x99FFFFFF)),
  labelStyle: const TextStyle(color: Color(0xCCFFFFFF)),
);

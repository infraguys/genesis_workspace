import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/gen/fonts.gen.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: darkColorScheme,
  badgeTheme: _badgeTheme,
  scaffoldBackgroundColor: const Color(0xff1B1B1D),
  inputDecorationTheme: _darkInputDecorationTheme,
  textTheme: ThemeData.dark().textTheme
      .withLetterSpacing(0)
      .apply(
        fontFamily: FontFamily.montserrat,
        bodyColor: Color(0xFFFFFFFF),
      ),
  extensions: [
    AppColors.darkTextColors,
    AppColors.darkCardColors,
    AppColors.darkMessageColors,
  ],
  cardTheme: CardThemeData(),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    linearTrackColor: const Color(0xff333333),
    stopIndicatorRadius: 12,
  ),
  elevatedButtonTheme: _darkElevatedButtonTheme,
  dividerColor: Color(0xFFFFFFFF).withValues(alpha: 0.1),
  appBarTheme: AppBarThemeData(
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12.0))),
);

final darkColorScheme = ColorScheme.dark(
  primary: AppColors.primary,
  surface: AppColors.darkSurface,
  surfaceContainer: Color(0xFF1C1B1F),
  background: AppColors.darkBackground,
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

final _darkElevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.darkOnPrimary,
  ),
);

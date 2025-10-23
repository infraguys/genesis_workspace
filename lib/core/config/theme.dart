import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/gen/fonts.gen.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: darkColorScheme,
  badgeTheme: _badgeTheme,
  fontFamily: FontFamily.montserrat,
  scaffoldBackgroundColor: AppColors.background,
);

final darkColorScheme = ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface);

final _badgeTheme = BadgeThemeData(
  backgroundColor: AppColors.counterBadge,
  textColor: AppColors.onBadge,
  textStyle: TextStyle(fontSize: 12),
);

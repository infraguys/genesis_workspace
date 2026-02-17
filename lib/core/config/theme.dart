import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/gen/fonts.gen.dart';

const orangeWarmPalette = OrangeWarmPalette();
const blueColdPalette = BlueColdPalette();
const supportedThemePalettes = [
  AppThemePalette.orangeWarm,
  AppThemePalette.blueCold,
];

final darkOrangeWarmTheme = orangeWarmPalette.dark();

final lightOrangeWarmTheme = orangeWarmPalette.light();

ThemePalette resolveThemePalette(AppThemePalette palette) {
  return switch (palette) {
    AppThemePalette.orangeWarm => orangeWarmPalette,
    AppThemePalette.blueCold => blueColdPalette,
  };
}

ThemeData buildThemeForPalette({
  required AppThemePalette palette,
  required Brightness brightness,
}) {
  return buildThemeFromPalette(
    palette: resolveThemePalette(palette),
    brightness: brightness,
  );
}

extension ThemePaletteThemeX on ThemePalette {
  ThemeData dark() {
    return buildThemeFromPalette(
      palette: this,
      brightness: Brightness.dark,
    );
  }

  ThemeData light() {
    return buildThemeFromPalette(
      palette: this,
      brightness: Brightness.light,
    );
  }
}

ThemeData buildThemeFromPalette({
  required ThemePalette palette,
  required Brightness brightness,
}) {
  final colorScheme = palette.colorSchemeFor(brightness);
  final isDark = brightness == Brightness.dark;

  return ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    badgeTheme: _badgeTheme,
    scaffoldBackgroundColor: colorScheme.background,
    inputDecorationTheme: _inputDecorationTheme(colorScheme, isDark: isDark),
    textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme
        .withLetterSpacing(0)
        .apply(
          fontFamily: FontFamily.montserrat,
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
    extensions: palette.extensionsFor(brightness),
    cardTheme: const CardThemeData(),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: isDark ? const Color(0xFF333333) : colorScheme.surfaceContainerHighest,
      stopIndicatorRadius: 12,
    ),
    elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
    outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
    dividerColor: colorScheme.onSurface.withValues(alpha: 0.1),
    appBarTheme: AppBarThemeData(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12.0),
      ),
    ),
  );
}

const _badgeTheme = BadgeThemeData(
  backgroundColor: AppColors.counterBadge,
  textColor: AppColors.onBadge,
  textStyle: TextStyle(fontSize: 12),
);

InputDecorationTheme _inputDecorationTheme(
  ColorScheme colorScheme, {
  required bool isDark,
}) {
  return InputDecorationTheme(
    filled: true,
    fillColor: colorScheme.onSurface.withValues(alpha: isDark ? 0.1 : 0.04),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.primary.withValues(alpha: 0.45),
        width: 1.2,
      ),
    ),
    hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
    labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.8)),
  );
}

ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme colorScheme) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
      foregroundColor: colorScheme.primary,
      side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

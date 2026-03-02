import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/domain/entities/theme_palette_entity.dart';
import 'package:genesis_workspace/gen/fonts.gen.dart';

final orangeWarmPalette = OrangeWarmPalette();
final blueColdPalette = BlueColdPalette();
final orangeWarmPaletteEntity = ThemePaletteEntity(
  paletteId: 'orange_warm',
  title: 'Orange Warm',
  palette: orangeWarmPalette,
);
final blueColdPaletteEntity = ThemePaletteEntity(
  paletteId: 'blue_cold',
  title: 'Blue Cold',
  palette: blueColdPalette,
);
final supportedThemePalettes = <ThemePaletteEntity>[
  orangeWarmPaletteEntity,
  blueColdPaletteEntity,
];
final defaultThemePaletteEntity = orangeWarmPaletteEntity;

final darkOrangeWarmTheme = orangeWarmPalette.dark();

final lightOrangeWarmTheme = orangeWarmPalette.light();

ThemeData buildThemeForPalette({
  required String paletteId,
  required Brightness brightness,
  List<ThemePaletteEntity>? palettes,
}) {
  final paletteEntity = resolveThemePaletteById(
    paletteId: paletteId,
    palettes: palettes,
  );
  return buildThemeFromPalette(
    palette: paletteEntity.palette,
    brightness: brightness,
  );
}

ThemePaletteEntity resolveThemePaletteById({
  required String paletteId,
  List<ThemePaletteEntity>? palettes,
}) {
  final normalizedPaletteId = normalizePaletteId(paletteId);
  final source = palettes ?? supportedThemePalettes;
  for (final palette in source) {
    if (palette.paletteId == normalizedPaletteId) {
      return palette;
    }
  }
  return source.isNotEmpty ? source.first : defaultThemePaletteEntity;
}

String normalizePaletteId(String? paletteId) {
  if (paletteId == null || paletteId.isEmpty) {
    return defaultThemePaletteEntity.paletteId;
  }
  if (paletteId == 'dark_orange_warm') {
    return 'orange_warm';
  }
  return paletteId;
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
    inputDecorationTheme: _inputDecorationTheme(colorScheme, palette: palette, isDark: isDark),
    scaffoldBackgroundColor: colorScheme.background,
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
    segmentedButtonTheme: _segmentedButtonTheme(colorScheme),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        enabledMouseCursor: SystemMouseCursors.click,
        disabledMouseCursor: SystemMouseCursors.basic,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        enabledMouseCursor: SystemMouseCursors.click,
        disabledMouseCursor: SystemMouseCursors.basic,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    dividerColor: colorScheme.onSurface.withValues(alpha: 0.1),
    appBarTheme: AppBarThemeData(
      centerTitle: platformInfo.isMobile,
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
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme:
          _inputDecorationTheme(
            colorScheme,
            palette: palette,
            isDark: isDark,
          ).copyWith(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      menuStyle: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
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
  required ThemePalette palette,
  required bool isDark,
}) {
  return InputDecorationTheme(
    filled: true,
    fillColor: isDark ? palette.darkTextFieldBackground : palette.lightTextFieldBackground,
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
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.basic,
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
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.basic,
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

SegmentedButtonThemeData _segmentedButtonTheme(ColorScheme colorScheme) {
  return SegmentedButtonThemeData(
    style: SegmentedButton.styleFrom(
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.basic,
      selectedBackgroundColor: colorScheme.primary,
      selectedForegroundColor: colorScheme.onPrimary,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

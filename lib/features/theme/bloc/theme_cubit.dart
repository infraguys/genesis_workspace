import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/config/theme.dart';
import 'package:genesis_workspace/domain/entities/theme_palette_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

@injectable
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(SharedPreferences sharedPreferences)
    : _sharedPreferences = sharedPreferences,
      super(
        ThemeState(
          themeMode: _parseThemeMode(sharedPreferences.getString(SharedPrefsKeys.themeMode)),
          selectedPaletteId: _restorePaletteId(
            sharedPreferences.getString(SharedPrefsKeys.themePalette),
            palettes: supportedThemePalettes,
          ),
          availablePalettes: supportedThemePalettes,
        ),
      );

  final SharedPreferences _sharedPreferences;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (state.themeMode == themeMode) return;
    await _sharedPreferences.setString(SharedPrefsKeys.themeMode, _themeModeToStorage(themeMode));
    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> setBrightness(Brightness brightness) async {
    await setThemeMode(brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setPalette(String paletteId) async {
    final normalizedPaletteId = normalizePaletteId(paletteId);
    final exists = state.availablePalettes.any((palette) => palette.paletteId == normalizedPaletteId);
    if (!exists || state.selectedPaletteId == normalizedPaletteId) return;
    await _sharedPreferences.setString(SharedPrefsKeys.themePalette, normalizedPaletteId);
    emit(state.copyWith(selectedPaletteId: normalizedPaletteId));
  }

  static ThemeMode _parseThemeMode(String? storedValue) {
    return switch (storedValue) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.dark,
    };
  }

  static String _themeModeToStorage(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'dark',
    };
  }

  static String _restorePaletteId(
    String? storedValue, {
    required List<ThemePaletteEntity> palettes,
  }) {
    final normalizedPaletteId = normalizePaletteId(storedValue);
    final exists = palettes.any((palette) => palette.paletteId == normalizedPaletteId);
    if (exists) {
      return normalizedPaletteId;
    }
    return palettes.isNotEmpty ? palettes.first.paletteId : defaultThemePaletteEntity.paletteId;
  }
}

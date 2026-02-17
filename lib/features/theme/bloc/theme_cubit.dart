import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/config/palettes/palette.dart';
import 'package:genesis_workspace/core/config/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(SharedPreferences sharedPreferences)
    : _sharedPreferences = sharedPreferences,
      super(
        ThemeState(
          themeMode: _parseThemeMode(sharedPreferences.getString(SharedPrefsKeys.themeMode)),
          selectedPalette: _restorePalette(sharedPreferences.getString(SharedPrefsKeys.themePalette)),
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

  Future<void> setPalette(AppThemePalette palette) async {
    if (!state.availablePalettes.contains(palette) || state.selectedPalette == palette) return;
    await _sharedPreferences.setString(SharedPrefsKeys.themePalette, palette.id);
    emit(state.copyWith(selectedPalette: palette));
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

  static AppThemePalette _restorePalette(String? storedValue) {
    final restoredPalette = appThemePaletteFromId(storedValue);
    if (!supportedThemePalettes.contains(restoredPalette)) {
      return supportedThemePalettes.first;
    }
    return restoredPalette;
  }
}

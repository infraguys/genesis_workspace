part of 'theme_cubit.dart';

class ThemeState {
  const ThemeState({
    required this.themeMode,
    required this.selectedPalette,
    required this.availablePalettes,
  });

  final ThemeMode themeMode;
  final AppThemePalette selectedPalette;
  final List<AppThemePalette> availablePalettes;

  ThemeState copyWith({
    ThemeMode? themeMode,
    AppThemePalette? selectedPalette,
    List<AppThemePalette>? availablePalettes,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      selectedPalette: selectedPalette ?? this.selectedPalette,
      availablePalettes: availablePalettes ?? this.availablePalettes,
    );
  }
}

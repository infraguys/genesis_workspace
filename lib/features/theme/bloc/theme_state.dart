part of 'theme_cubit.dart';

class ThemeState {
  const ThemeState({
    required this.themeMode,
    required this.selectedPaletteId,
    required this.availablePalettes,
  });

  final ThemeMode themeMode;
  final String selectedPaletteId;
  final List<ThemePaletteEntity> availablePalettes;

  ThemePaletteEntity get selectedPalette {
    for (final palette in availablePalettes) {
      if (palette.paletteId == selectedPaletteId) {
        return palette;
      }
    }
    return availablePalettes.isNotEmpty ? availablePalettes.first : defaultThemePaletteEntity;
  }

  ThemeState copyWith({
    ThemeMode? themeMode,
    String? selectedPaletteId,
    List<ThemePaletteEntity>? availablePalettes,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      selectedPaletteId: selectedPaletteId ?? this.selectedPaletteId,
      availablePalettes: availablePalettes ?? this.availablePalettes,
    );
  }
}

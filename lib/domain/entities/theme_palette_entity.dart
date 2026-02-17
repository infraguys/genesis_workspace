import 'package:genesis_workspace/core/config/palettes/palette.dart';

class ThemePaletteEntity {
  final String paletteId;
  final String title;
  final ThemePalette palette;

  const ThemePaletteEntity({
    required this.paletteId,
    required this.title,
    required this.palette,
  });
}

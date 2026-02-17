part of 'palette.dart';

const _blueColdLightColorScheme = ColorScheme.light(
  primary: Color(0xFF5051F5),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFDEE0FF),
  onPrimaryContainer: Color(0xFF121458),
  surface: Color(0xFFE3EFFA),
  onSurface: Color(0xFF151825),
  surfaceContainer: Color(0xFFF0F2FF),
  surfaceContainerHighest: Color(0xFFE2E6F6),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFFFFFFFF),
);

const _blueColdDarkColorScheme = ColorScheme.dark(
  primary: Color(0xFF5051F5),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF2B2D9A),
  onPrimaryContainer: Color(0xFFDDE1FF),
  surface: Color(0xFF25272C),
  onSurface: Color(0xFFF1F3FF),
  surfaceContainer: Color(0xFF1A1E31),
  surfaceContainerHighest: Color(0xFF33384D),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  background: Color(0xFF13151A),
);

const _blueColdLightTextColors = TextColors(
  text100: Color(0xFF151825),
  text50: Color(0x80151825),
  text30: Color(0x4D151825),
);

const _blueColdDarkTextColors = TextColors(
  text100: Color(0xFFF1F3FF),
  text50: Color(0x80F1F3FF),
  text30: Color(0x4DF1F3FF),
);

const _blueColdLightMessageColors = MessageColors(
  background: Color(0xFFDFEFFF),
  ownBackground: Color(0xFFE1E6FF),
  timeColor: Color(0xFF748CFF),
  senderNameColor: Color(0xFF51ABFF),
  activeCallBackground: Color(0xFFE4ECFF),
  selectedMessageForeground: Color(0x335051F5),
);

const _blueColdDarkMessageColors = MessageColors(
  background: Color(0xFF222328),
  ownBackground: Color(0xFF252942),
  timeColor: Color(0xFFFFFFFF),
  senderNameColor: Color(0xFF4C6EC2),
  activeCallBackground: Color(0xFF1D2642),
  selectedMessageForeground: Color(0x335051F5),
);

const _blueColdLightCardColors = CardColors(
  base: Color(0xFFEAF5FF),
  active: Color(0xFFDBEEFF),
  onBackgroundCard: Color(0xFFFFFFFF),
);

const _blueColdDarkCardColors = CardColors(
  base: Color(0x08FFFFFF),
  active: Color(0x14FFFFFF),
  onBackgroundCard: Color(0xFF1F2235),
);

class BlueColdPalette extends ThemePalette {
  const BlueColdPalette()
    : super(
        palette: AppThemePalette.blueCold,
        lightColorScheme: _blueColdLightColorScheme,
        darkColorScheme: _blueColdDarkColorScheme,
        lightTextColors: _blueColdLightTextColors,
        darkTextColors: _blueColdDarkTextColors,
        lightMessageColors: _blueColdLightMessageColors,
        darkMessageColors: _blueColdDarkMessageColors,
        lightCardColors: _blueColdLightCardColors,
        darkCardColors: _blueColdDarkCardColors,
      );
}

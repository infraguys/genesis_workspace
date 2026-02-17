part of 'palette.dart';

const _orangeWarmLightColorScheme = ColorScheme.light(
  primary: Color(0xFFFF8438),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFDCC7),
  onPrimaryContainer: Color(0xFF2E1505),
  surface: Color(0xFFFFFBF8),
  onSurface: Color(0xFF1E1B18),
  surfaceContainer: Color(0xFFF6EEE8),
  surfaceContainerHighest: Color(0xFFE9DED5),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
);

const _orangeWarmDarkColorScheme = ColorScheme.dark(
  primary: Color(0xFFFF8438),
  onPrimary: Color(0xFF1B1B1D),
  primaryContainer: Color(0xFF5A2F0F),
  onPrimaryContainer: Color(0xFFFFDCC7),
  surface: Color(0xFF333333),
  onSurface: Color(0xFFFFFFFF),
  surfaceContainer: Color(0xFF1C1B1F),
  surfaceContainerHighest: Color(0xFF323232),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
);

const _orangeWarmLightTextColors = TextColors(
  text100: Color(0xFF1E1B18),
  text50: Color(0x801E1B18),
  text30: Color(0x4D1E1B18),
);

const _orangeWarmDarkTextColors = TextColors(
  text100: Color(0xFFFFFFFF),
  text50: Color(0x80FFFFFF),
  text30: Color(0x4DFFFFFF),
);

const _orangeWarmLightMessageColors = MessageColors(
  background: Color(0xFFF6EEE8),
  ownBackground: Color(0xFFFFE8D9),
  timeColor: Color(0x8026211D),
  senderNameColor: Color(0xFFFF8438),
  activeCallBackground: Color(0xFFE4F3E8),
  selectedMessageForeground: Color(0x1F26C038),
);

const _orangeWarmDarkMessageColors = MessageColors(
  background: Color(0xFF333333),
  ownBackground: Color(0xFF47382B),
  timeColor: Color(0x80FFFFFF),
  senderNameColor: Color(0xFFFF8438),
  activeCallBackground: Color(0xFF1C2B20),
  selectedMessageForeground: Color(0x3326C038),
);

const _orangeWarmLightCardColors = CardColors(
  base: Color(0xFFFFFFFF),
  active: Color(0xFFF6EEE8),
  onBackgroundCard: Color(0xFFFFFFFF),
);

const _orangeWarmDarkCardColors = CardColors(
  base: Color(0x05FFFFFF),
  active: Color(0x1AFFFFFF),
  onBackgroundCard: Color(0xFF202022),
);

class OrangeWarmPalette extends ThemePalette {
  const OrangeWarmPalette()
    : super(
        palette: AppThemePalette.orangeWarm,
        lightColorScheme: _orangeWarmLightColorScheme,
        darkColorScheme: _orangeWarmDarkColorScheme,
        lightTextColors: _orangeWarmLightTextColors,
        darkTextColors: _orangeWarmDarkTextColors,
        lightMessageColors: _orangeWarmLightMessageColors,
        darkMessageColors: _orangeWarmDarkMessageColors,
        lightCardColors: _orangeWarmLightCardColors,
        darkCardColors: _orangeWarmDarkCardColors,
      );
}

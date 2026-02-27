part of 'palette.dart';

const _orangeWarmLightColorScheme = ColorScheme.light(
  primary: Color(0xFFFF8438),
  onPrimary: Color(0xFF1B1B1D),
  primaryContainer: Color(0xFFFFDCC7),
  onPrimaryContainer: Color(0xFF2E1505),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF1E1B18),
  surfaceContainer: Color(0xFFF6EEE8),
  surfaceContainerHighest: Color(0xFFE9DED5),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFFE6E6E6),
);

const _orangeWarmDarkColorScheme = ColorScheme.dark(
  primary: Color(0xFFFF8438),
  onPrimary: Color(0xFF1B1B1D),
  primaryContainer: Color(0xFF5A2F0F),
  onPrimaryContainer: Color(0xFFFFDCC7),
  surface: Color(0xFF333333),
  onSurface: Color(0xFFFFFFFF),
  background: Color(0xFF1B1B1D),
  surfaceContainer: Color(0xFF1C1B1F),
  surfaceContainerHighest: Color(0xFF323232),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
);

const _orangeWarmLightTextColors = TextColors(
  text100: Color(0xFF1B1B1D),
  text50: Color(0xFF989898),
  text30: Color(0xFF989898),
);

const _orangeWarmDarkTextColors = TextColors(
  text100: Color(0xFFFFFFFF),
  text50: Color(0xFF999999),
  text30: Color(0xFF707070),
);

const _orangeWarmLightIconColors = IconColors(
  base: Color(0xFF989898),
  disable: Color(0xFF474747),
  hover: Color(0xFFFFE7CC),
  active: Color(0xFF1B1B1D),
  hoverBackground: Color(0xFFFFE7CC),
);

const _orangeWarmDarkIconColors = IconColors(
  base: Color(0xFF707070),
  disable: Color(0xFF474747),
  hover: Color(0xFF999999),
  active: Color(0xFFFFFFFF),
  hoverBackground: Color(0xFF484848),
);

const _orangeWarmLightMessageColors = MessageColors(
  background: Color(0xFFFFFFFF),
  ownBackground: Color(0xFFFFF1E2),
  timeColor: Color(0xFF989898),
  activeCallBackground: Color(0xFFE2FFE9),
  selectedMessageForeground: Color(0x80F3721E),
);

const _orangeWarmDarkMessageColors = MessageColors(
  background: Color(0xFF333333),
  ownBackground: Color(0xFF47382B),
  timeColor: Color(0xFF999999),
  activeCallBackground: Color(0xFF1C2B20),
  selectedMessageForeground: Color(0x80FF8438),
);

const _orangeWarmLightCardColors = CardColors(
  base: Color(0xFFF5F5F5),
  active: Color(0xFFFFE7CC),
);

const _orangeWarmDarkCardColors = CardColors(
  base: Color(0xFF373737),
  active: Color(0xFF4B4B4B),
);

const _orangeWarmLightNoticeColors = NoticeColors(
  noticeBase: Color(0xFFFF8438),
  noticeDisable: Color(0xFF989898),
  onBadge: Color(0xFFFFFFFF),
  counterBadge: Color(0xFFFF8438),
);

const _orangeWarmDarkNoticeColors = NoticeColors(
  noticeBase: Color(0xFFFF0000),
  noticeDisable: Color(0xFF5c5855),
  onBadge: Color(0xFFFFFFFF),
  counterBadge: Color(0xFFFF0000),
);

class OrangeWarmPalette extends ThemePalette {
  const OrangeWarmPalette()
    : super(
        id: 'orange_warm',
        title: 'Orange Warm',
        lightColorScheme: _orangeWarmLightColorScheme,
        darkColorScheme: _orangeWarmDarkColorScheme,
        lightTextColors: _orangeWarmLightTextColors,
        darkTextColors: _orangeWarmDarkTextColors,
        lightMessageColors: _orangeWarmLightMessageColors,
        darkMessageColors: _orangeWarmDarkMessageColors,
        lightCardColors: _orangeWarmLightCardColors,
        darkCardColors: _orangeWarmDarkCardColors,
        darkIconColors: _orangeWarmDarkIconColors,
        lightIconColors: _orangeWarmLightIconColors,
        lightNoticeColors: _orangeWarmLightNoticeColors,
        darkNoticeColors: _orangeWarmDarkNoticeColors,
        darkTextFieldBackground: const Color(0xFF3D3D3D),
        lightTextFieldBackground: const Color(0xFFE6E6E6),
      );
}

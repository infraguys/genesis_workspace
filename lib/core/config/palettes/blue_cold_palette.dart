part of 'palette.dart';

const _blueColdLightColorScheme = ColorScheme.light(
  primary: Color(0xFF7087FF),
  onPrimary: Color(0xFF1B1B1D),
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
  primary: Color(0xFF7087FF),
  onPrimary: Color(0xFF141517),
  primaryContainer: Color(0xFF2B2D9A),
  onPrimaryContainer: Color(0xFFDDE1FF),
  surface: Color(0xFF222328),
  onSurface: Color(0xFFF1F3FF),
  surfaceContainer: Color(0xFF1A1E31),
  surfaceContainerHighest: Color(0xFF33384D),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  background: Color(0xFF141517),
);

const _blueColdLightTextColors = TextColors(
  text100: Color(0xFF1B1B1D),
  text50: Color(0xFF7B88C7),
  text30: Color(0xFF9AA9F8),
);

const _blueColdDarkTextColors = TextColors(
  text100: Color(0xFFFFFFFF),
  text50: Color(0xFF999999),
  text30: Color(0xFF707070),
);

const _blueColdLightIconColors = IconColors(
  base: Color(0xFF85B6FF),
  disable: Color(0xFF474747),
  hover: Color(0xFFCDE6FF),
  active: Color(0xFF1B1B1D),
  hoverBackground: Color(0xFFCDE6FF),
);

const _blueColdDarkIconColors = IconColors(
  base: Color(0xFF707070),
  disable: Color(0xFF474747),
  hover: Color(0xFF999999),
  active: Color(0xFFFFFFFF),
  hoverBackground: Color(0xFF141517),
);

const _blueColdLightMessageColors = MessageColors(
  background: Color(0xFFE3EFFA),
  ownBackground: Color(0xFFC4CEFF),
  timeColor: Color(0xFF7087FF),
  activeCallBackground: Color(0xFFC8FFD5),
  selectedMessageForeground: Color(0x335051F5),
);

const _blueColdDarkMessageColors = MessageColors(
  background: Color(0xFF333333),
  ownBackground: Color(0xFF252942),
  timeColor: Color(0xFF999999),
  activeCallBackground: Color(0xFF1B3027),
  selectedMessageForeground: Color(0x335051F5),
);

const _blueColdLightCardColors = CardColors(
  base: Color(0xFFEAF5FF),
  active: Color(0xFFCDE6FF),
);

const _blueColdDarkCardColors = CardColors(
  base: Color(0xFF282A32),
  active: Color(0xFF2C3747),
);

const _blueColdLightNoticeColors = NoticeColors(
  noticeBase: Color(0xFF7087FF),
  noticeDisable: Color(0xFF989898),
  onBadge: Color(0xFFFFFFFF),
  counterBadge: Color(0xFF7087FF),
);

const _blueColdDarkNoticeColors = NoticeColors(
  noticeBase: Color(0xFF3D5EFF),
  noticeDisable: Color(0xFF5C5855),
  onBadge: Color(0xFFFFFFFF),
  counterBadge: Color(0xFF3D5EFF),
);

class BlueColdPalette extends ThemePalette {
  BlueColdPalette()
    : super(
        id: 'blue_cold',
        title: 'Blue Cold',
        lightColorScheme: _blueColdLightColorScheme,
        darkColorScheme: _blueColdDarkColorScheme,
        lightTextColors: _blueColdLightTextColors,
        darkTextColors: _blueColdDarkTextColors,
        lightMessageColors: _blueColdLightMessageColors,
        darkMessageColors: _blueColdDarkMessageColors,
        lightCardColors: _blueColdLightCardColors,
        darkCardColors: _blueColdDarkCardColors,
        lightIconColors: _blueColdLightIconColors,
        darkIconColors: _blueColdDarkIconColors,
        lightNoticeColors: _blueColdLightNoticeColors,
        darkNoticeColors: _blueColdDarkNoticeColors,
        darkTextFieldBackground: const Color(0xFF222328),
        lightTextFieldBackground: const Color(0xFFFFFFFF),
      );
}

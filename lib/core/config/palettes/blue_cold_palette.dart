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
  activeCallBackground: Color(0xFFE4ECFF),
  selectedMessageForeground: Color(0x335051F5),
);

const _blueColdDarkMessageColors = MessageColors(
  background: Color(0xFF222328),
  ownBackground: Color(0xFF252942),
  timeColor: Color(0xFFFFFFFF),
  activeCallBackground: Color(0xFF1D2642),
  selectedMessageForeground: Color(0x335051F5),
);

final _blueColdLightCardColors = CardColors(
  base: Color(0xFFEAF5FF),
  active: Color(0xFF51ABFF).withValues(alpha: 0.1),
  onBackgroundCard: Color(0xFFFFFFFF),
);

const _blueColdDarkCardColors = CardColors(
  base: Color(0x08FFFFFF),
  active: Color(0x14FFFFFF),
  onBackgroundCard: Color(0xFF1F2235),
);

const _blueColdLightIconColors = IconColors(
  base: Color(0xFF58A7F7),
  disable: Color(0xFF474747),
  hover: Color(0xFF999999),
  active: Color(0xFFFFFFFF),
);

const _blueColdDarkIconColors = IconColors(
  base: Color(0xFF707070),
  disable: Color(0xFF474747),
  hover: Color(0xFF999999),
  active: Color(0xFFFFFFFF),
);

const _blueColdLightNoticeColors = NoticeColors(
  noticeBase: Color(0xFFFF0000),
  noticeDisable: Color(0xFF5c5855),
  onBadge: Color(0xFFFFFFFF),
  counterBadge: Color(0xFF3D5EFF),
);

const _blueColdDarkNoticeColors = NoticeColors(
  noticeBase: Color(0xFFFF0000),
  noticeDisable: Color(0xFF5c5855),
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
      );
}

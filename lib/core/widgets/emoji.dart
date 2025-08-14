import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:genesis_workspace/core/models/emoji.dart';
import 'package:genesis_workspace/gen/fonts.gen.dart';

class UnicodeEmojiWidget extends StatelessWidget {
  const UnicodeEmojiWidget({
    super.key,
    required this.emojiDisplay,
    required this.size,
    this.textScaler = TextScaler.noScaling,
  });

  final UnicodeEmojiDisplay emojiDisplay;

  /// The base width and height to use for the emoji.
  ///
  /// This will be scaled by [textScaler].
  final double size;

  /// The text scaler to apply to [size].
  ///
  /// Defaults to [TextScaler.noScaling].
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    int? codePoint;

    try {
      // Убираем лишние пробелы и проверяем hex-паттерн
      final cleaned = emojiDisplay.emojiUnicode.trim();
      final hexPattern = RegExp(r'^[0-9a-fA-F]+$');

      if (hexPattern.hasMatch(cleaned)) {
        codePoint = int.parse(cleaned, radix: 16);
      }
    } catch (_) {
      // Игнорируем — codePoint останется null
    }

    // Если не удалось распарсить, показываем символ замены
    codePoint ??= 0xFFFD; // '�'

    final emojiChar = String.fromCharCode(codePoint);
    final emojiStr = String.fromCharCodes([codePoint]);
    final unicode = emojiStr;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
        final double notoColorEmojiTextSize = size * (14.5 / 17);
        return Text(
          textScaler: textScaler,
          style: TextStyle(
            fontFamily: FontFamily.notoColorEmoji,
            fontSize: notoColorEmojiTextSize,
          ),
          strutStyle: StrutStyle(
            fontSize: notoColorEmojiTextSize,
            forceStrutHeight: true,
          ),
          unicode,
        );
      case TargetPlatform.windows:
        final double notoColorEmojiTextSize = size * (14.5 / 17);
        return Text(
          textScaler: textScaler,
          style: TextStyle(
            // fontFamily: FontFamily.notoColorEmoji,
            fontSize: notoColorEmojiTextSize,
          ),
          strutStyle: StrutStyle(
            fontSize: notoColorEmojiTextSize,
            forceStrutHeight: true,
          ),
          unicode,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        final boxSize = textScaler.scale(size);
        return Stack(
          alignment: Alignment.centerLeft,
          clipBehavior: Clip.none,
          children: [
            SizedBox(height: boxSize, width: boxSize),
            PositionedDirectional(
              start: 0,
              child: Text(
                textScaler: textScaler,
                style: TextStyle(
                  fontFamily: FontFamily.appleEmoji,
                  fontSize: size,
                ),
                strutStyle: StrutStyle(fontSize: size, forceStrutHeight: true),
                unicode,
              ),
            ),
          ],
        );
    }
  }
}

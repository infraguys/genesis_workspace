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
    List<int>? codePoints;

    try {
      // Trim extra whitespace and support both a single-codepoint hex value
      // and a hyphen-separated sequence (e.g. "1f469-200d-1f4bb").
      final cleaned = emojiDisplay.emojiUnicode.trim();
      final hexPattern = RegExp(r'^[0-9a-fA-F]+$');
      final sequencePattern = RegExp(r'^[0-9a-fA-F]+(?:-[0-9a-fA-F]+)+$');

      if (hexPattern.hasMatch(cleaned)) {
        codePoints = [int.parse(cleaned, radix: 16)];
      } else if (sequencePattern.hasMatch(cleaned)) {
        codePoints = cleaned.split('-').map((hex) => int.parse(hex, radix: 16)).toList();
      }
    } catch (_) {
      // Ignore parse errors and keep codePoints as null.
    }

    // Fall back to the replacement character if parsing fails.
    codePoints ??= [0xFFFD]; // '�'

    final unicode = String.fromCharCodes(codePoints);

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
        final double notoColorEmojiTextSize = size * (14.5 / 17);
        return Text(
          textScaler: textScaler,
          style: TextStyle(fontFamily: FontFamily.notoColorEmoji, fontSize: notoColorEmojiTextSize),
          strutStyle: StrutStyle(fontSize: notoColorEmojiTextSize, forceStrutHeight: true),
          unicode,
        );
      case TargetPlatform.windows:
        final double emojiTextSize = size * (14 / 17);
        return Text(
          textScaler: textScaler,
          style: TextStyle(fontSize: emojiTextSize),
          strutStyle: StrutStyle(fontSize: emojiTextSize, forceStrutHeight: true),
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
                style: TextStyle(fontFamily: FontFamily.appleEmoji, fontSize: size),
                strutStyle: StrutStyle(fontSize: size, forceStrutHeight: true),
                unicode,
              ),
            ),
          ],
        );
    }
  }
}

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
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        // A font size that, with Noto Color Emoji and our line-height
        // config (the use of `forceStrutHeight: true`), causes a Unicode emoji
        // to occupy a square of size [size] in the layout.
        //
        // Determined experimentally:
        //   <https://github.com/zulip/zulip-flutter/pull/410#discussion_r1402808701>
        //   <https://github.com/zulip/zulip-flutter/pull/1629#discussion_r2188037245>
        final double notoColorEmojiTextSize = size * (14.5 / 17);

        return Text(
          textScaler: textScaler,
          style: TextStyle(fontFamily: FontFamily.notoColorEmoji, fontSize: notoColorEmojiTextSize),
          strutStyle: StrutStyle(
            fontSize: notoColorEmojiTextSize,
            // Responsible for keeping the line height constant, even
            // with ambient DefaultTextStyle.
            forceStrutHeight: true,
          ),
          emojiDisplay.emojiUnicode,
        );

      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        // We use the font "Apple Color Emoji". There are some surprises in how
        // Flutter ends up rendering emojis in this font:
        // - With a font size of 17px, the emoji visually seems to be about 17px
        //   square. (Unlike on Android, with Noto Color Emoji, where a 14.5px font
        //   size gives an emoji that looks 17px square.) See:
        //     <https://github.com/flutter/flutter/issues/28894>
        // - The emoji doesn't fill the space taken by the [Text] in the layout.
        //   There's whitespace above, below, and on the right. See:
        //     <https://github.com/flutter/flutter/issues/119623>
        //
        // That extra space would be problematic, except we've used a [Stack] to
        // make the [Text] "positioned" so the space doesn't add margins around the
        // visible part. Key points that enable the [Stack] workaround:
        // - The emoji seems approximately vertically centered (this is
        //   accomplished with help from a [StrutStyle]; see below).
        // - There seems to be approximately no space on its left.
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
                strutStyle: StrutStyle(
                  fontSize: size,
                  // Responsible for keeping the line height constant, even
                  // with ambient DefaultTextStyle.
                  forceStrutHeight: true,
                ),
                emojiDisplay.emojiUnicode,
              ),
            ),
          ],
        );
    }
  }
}

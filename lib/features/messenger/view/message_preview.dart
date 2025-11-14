import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/models/emoji.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';

class MessagePreview extends StatelessWidget {
  final String messagePreview;
  const MessagePreview({super.key, required this.messagePreview});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    final double messageContentWidth = currentSize(context) <= ScreenSize.tablet ? 240 : 200;
    return Container(
      margin: EdgeInsetsGeometry.symmetric(vertical: 1),
      width: messageContentWidth,
      height: 18,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 0,
          maxWidth: double.infinity,
          minHeight: 0,
          maxHeight: double.infinity,
          child: HtmlWidget(
            messagePreview,
            customStylesBuilder: (element) {
              return {
                "max-width": "${messageContentWidth}px",
                "text-overflow": "ellipsis",
              };
            },
            textStyle: theme.textTheme.bodySmall?.copyWith(color: textColors.text50),
            customWidgetBuilder: (element) {
              final messagePreviewStyle = theme.textTheme.bodySmall?.copyWith(
                color: textColors.text50,
              );

              if (element.attributes.containsValue('image/png') || element.attributes.containsValue('image/jpeg')) {
                return Text(
                  'Image',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: messagePreviewStyle,
                );
              }

              if (element.classes.contains('emoji')) {
                final emojiUnicode = element.classes
                    .firstWhere((className) => className.contains('emoji-'))
                    .replaceAll('emoji-', '');
                final emoji = ':${element.attributes['title']!.replaceAll(' ', '_')}:';

                return InlineCustomWidget(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: UnicodeEmojiWidget(
                      emojiDisplay: UnicodeEmojiDisplay(
                        emojiName: emoji,
                        emojiUnicode: emojiUnicode,
                      ),
                      size: 14,
                    ),
                  ),
                );
              }

              if (element.classes.contains('user-mention')) {
                final mention = element.nodes[0].text ?? '';
                return InlineCustomWidget(
                  child: Text(
                    mention,
                    style: messagePreviewStyle!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              }

              return null;
            },
          ),
        ),
      ),
    );
  }
}

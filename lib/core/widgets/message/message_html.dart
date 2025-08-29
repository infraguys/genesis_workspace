import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/models/emoji.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/authorized_image.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageHtml extends StatelessWidget {
  final String content;
  const MessageHtml({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      content,
      // factoryBuilder: () => MyWidgetFactory(),
      customStylesBuilder: (element) {
        if (element.classes.contains('user-mention')) {
          return {'font-weight': '600'};
        }
        return null;
      },
      customWidgetBuilder: (element) {
        if (element.attributes.containsValue('image/png') ||
            element.attributes.containsValue('image/jpeg')) {
          final src = element.parentNode?.attributes['href'];
          final size = extractDimensionsFromUrl(src ?? '');
          return AuthorizedImage(
            url: '${AppConstants.baseUrl}$src',
            width: size?.width,
            height: size?.height,
            fit: BoxFit.contain,
          );
        }
        if (element.classes.contains('emoji')) {
          final emojiUnicode = element.classes
              .firstWhere((className) => className.contains('emoji-'))
              .replaceAll('emoji-', '');

          final emoji = ":${element.attributes['title']!.replaceAll(' ', '_')}:";

          return InlineCustomWidget(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: UnicodeEmojiWidget(
                emojiDisplay: UnicodeEmojiDisplay(emojiName: emoji, emojiUnicode: emojiUnicode),
                size: 14,
              ),
            ),
          );
        }
        return null;
      },
      onTapUrl: (String? url) async {
        final Uri _url = Uri.parse(url ?? '');
        await launchUrl(_url);
        return true;
      },
    );
  }
}

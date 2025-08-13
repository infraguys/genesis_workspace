import 'package:flutter/material.dart';
// импортируйте ваш EmojiWidget и модель
import 'package:genesis_workspace/core/models/emoji.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';

class MessageContent extends StatelessWidget {
  final String content;

  const MessageContent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;

    // 1) Достаём содержимое из <p>...</p> (минимальный парсинг под ваш формат)
    final inner = _extractParagraphInner(content);

    // 2) Парсим на куски текста и эмодзи-спаны
    final spans = _parseRuns(inner, context, defaultStyle);

    // 3) Рендерим RichText c корректной базовой линией
    return Text.rich(
      TextSpan(children: spans, style: defaultStyle),
      textScaler: MediaQuery.textScalerOf(context),
    );
  }

  /// Возвращает содержимое внутри первого <p>...</p>.
  /// Если тега нет — вернёт исходную строку без изменений.
  String _extractParagraphInner(String html) {
    final p = RegExp(r'<\s*p\b[^>]*>(.*?)<\/\s*p\s*>', caseSensitive: false, dotAll: true);
    final m = p.firstMatch(html);
    if (m != null) return m.group(1) ?? '';
    return html;
  }

  /// Основной мини-парсер: раскладываем строку на текст и emoji-спаны.
  List<InlineSpan> _parseRuns(String innerHtml, BuildContext context, TextStyle baseStyle) {
    final List<InlineSpan> result = [];

    // Ищем <span ...>...</span>
    final spanRe = RegExp(
      r'<\s*span\b([^>]*)>(.*?)<\/\s*span\s*>',
      caseSensitive: false,
      dotAll: true,
    );

    int index = 0;
    for (final match in spanRe.allMatches(innerHtml)) {
      // добавляем текст до спана
      if (match.start > index) {
        final textChunk = innerHtml.substring(index, match.start);
        if (textChunk.isNotEmpty) {
          result.add(TextSpan(text: _stripTags(textChunk)));
        }
      }

      final attrs = match.group(1) ?? '';
      final inner = match.group(2) ?? '';

      final classes = _readAttr(attrs, 'class') ?? '';
      if (classes
          .split(RegExp(r'\s+'))
          .any((c) => c.toLowerCase() == 'emoji' || c.toLowerCase().startsWith('emoji-'))) {
        final emojiHex = _extractEmojiHex(classes);
        final emojiName = _buildEmojiName(
          _readAttr(attrs, 'title') ?? _readAttr(attrs, 'aria-label') ?? inner,
        );

        if (emojiHex != null) {
          // Встраиваем ваш виджет как inline-элемент по базовой линии
          final fontSize = baseStyle.fontSize ?? 14.0;
          result.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: UnicodeEmojiWidget(
                emojiDisplay: UnicodeEmojiDisplay(
                  emojiName: emojiName,
                  emojiUnicode: emojiHex, // hex без префикса, как ожидает ваш виджет
                ),
                size: fontSize, // подгоняем размер под текст
                textScaler: MediaQuery.textScalerOf(context),
              ),
            ),
          );
        } else {
          // Если hex не нашли — fallback: показываем внутренний текст как есть
          result.add(TextSpan(text: _stripTags(inner)));
        }
      } else {
        // Не emoji-спан — рендерим как текст
        result.add(TextSpan(text: _stripTags(inner)));
      }

      index = match.end;
    }

    // Хвост после последнего <span>
    if (index < innerHtml.length) {
      final tail = innerHtml.substring(index);
      if (tail.isNotEmpty) {
        result.add(TextSpan(text: _stripTags(tail)));
      }
    }

    return result;
  }

  /// Достаёт значение атрибута из строки атрибутов (поддержка двойных/одинарных кавычек).
  String? _readAttr(String attrs, String name) {
    final re = RegExp('$name\\s*=\\s*("([^"]*)"|\'([^\']*)\')', caseSensitive: false);
    final m = re.firstMatch(attrs);
    if (m == null) return null;
    return m.group(2) ?? m.group(3);
  }

  /// Из class="emoji emoji-1f604 ..." достаём "1f604"
  String? _extractEmojiHex(String classes) {
    final re = RegExp(r'emoji-([0-9a-fA-F]+)');
    final m = re.firstMatch(classes);
    return m?.group(1);
  }

  /// Преобразуем человекочитаемое название в :snake_case: формат.
  String _buildEmojiName(String raw) {
    final cleaned = raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    // если уже приходит :big_smile: — вернём как есть
    if (cleaned.startsWith(':') && cleaned.endsWith(':')) return cleaned;
    return ':$cleaned:';
  }

  /// Удаляем любые теги на случай, если попали простые инлайны.
  String _stripTags(String s) {
    return s.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}

import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/models/emoji.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  static const String legacyPath = String.fromEnvironment('legacy_ui');

  static const String appName = 'genesis_workspace';

  static const String tusVersion = '1.0.0';

  static late String baseUrl;

  static final popularEmojis = [
    UnicodeEmojiDisplay(emojiName: ":thumbs_up:", emojiUnicode: "1F44D"),
    UnicodeEmojiDisplay(emojiName: ":heart:", emojiUnicode: "2764"),
    UnicodeEmojiDisplay(emojiName: ":joy:", emojiUnicode: "1F602"),
    UnicodeEmojiDisplay(emojiName: ":open_mouth:", emojiUnicode: "1F62E"),
    UnicodeEmojiDisplay(emojiName: ":cry:", emojiUnicode: "1F622"),
    UnicodeEmojiDisplay(emojiName: ":clap:", emojiUnicode: "1F44F"),
  ];

  static Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? savedBaseUrl = prefs.getString(SharedPrefsKeys.baseUrl);

    if (savedBaseUrl != null && savedBaseUrl.trim().isNotEmpty) {
      baseUrl = savedBaseUrl.trim();
    } else {
      baseUrl = '';
    }
  }

  static setBaseUrl(String url) {
    baseUrl = url;
  }

  static const List<String> kImageExtensions = [
    'png',
    'jpg',
    'jpeg',
    'gif',
    'webp',
    'bmp',
    'heic',
    'heif',
    'svg',
  ];

  static const List<String> kNonImageAllowedExtensions = [
    'pdf',
    'txt',
    'md',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'csv',
    'zip',
    'rar',
    '7z',
    'json',
    'xml',
  ];

  static const List<IconData> folderIcons = <IconData>[
    Icons.folder,
    Icons.star,
    Icons.work,
    Icons.chat_bubble,
    Icons.mail,
    Icons.favorite,
    Icons.school,
    Icons.code,
    Icons.task_alt,
    Icons.pin_drop,
    Icons.bookmark,
    Icons.bolt,
    Icons.shopping_bag,
    Icons.sports_esports,
    Icons.movie,
    Icons.music_note,
  ];

  static const List<Color> folderColors = <Color>[
    Color(0xFFEF4444), // red
    Color(0xFFF59E0B), // amber
    Color(0xFF10B981), // emerald
    Color(0xFF3B82F6), // blue
    Color(0xFF8B5CF6), // violet
    Color(0xFFF43F5E), // rose
    Color(0xFF14B8A6), // teal
    Color(0xFF6B7280), // gray
  ];
}

class SharedPrefsKeys {
  static const String locale = 'locale';
  static const String isWebAuth = 'isWebAuth';
  static const String baseUrl = 'baseUrl';
}

class AssetsConstants {
  static const String audioPop = 'audio/pop.wav';
}

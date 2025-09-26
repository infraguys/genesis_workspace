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
    Icons.groups,
    Icons.code,
    Icons.task_alt,
    Icons.push_pin,
    Icons.bookmark,
    Icons.bolt,
    Icons.calendar_today,
    Icons.description,
    Icons.campaign,
    Icons.bug_report,
    Icons.security,
  ];

  static const List<Color> folderColors = <Color>[
    Color(0xFF2563EB),
    Color(0xFF4F46E5),
    Color(0xFF0D9488),
    Color(0xFF059669),
    Color(0xFFF59E0B),
    Color(0xFFDC2626),
    Color(0xFF6B7280),
    Color(0xFF334155),
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

import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/models/emoji.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  static const String legacyPath = String.fromEnvironment('legacy_ui');
  static const String firebaseApiKey = String.fromEnvironment('firebase_api_key');

  static const String appName = 'genesis_workspace';

  static const String tusVersion = '1.0.0';

  static late String baseUrl;
  static int? selectedOrganizationId;

  static const String versionConfigUrl =
      'https://repository.genesis-core.tech/genesis_workspace/workspace-index.json';

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
    final int? savedOrganizationId = prefs.getInt(SharedPrefsKeys.selectedOrganizationId);

    if (savedBaseUrl != null && savedBaseUrl.trim().isNotEmpty) {
      baseUrl = savedBaseUrl.trim();
    } else {
      baseUrl = '';
    }
    selectedOrganizationId = savedOrganizationId;
  }

  static setBaseUrl(String url) {
    baseUrl = url;
  }

  static void setSelectedOrganizationId(int? id) {
    selectedOrganizationId = id;
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
  static const String selectedOrganizationId = 'selectedOrganizationId';
  static const String baseUrl = 'baseUrl';
  static const String notificationSound = 'notificationSound';
}

class AssetsConstants {
  static const String audioPop = 'audio/pop.wav';
  static const String audioWhoop = 'audio/whoop.wav';
}

class FolderIconsConstants {
  static const Map<int, IconData> byCodePoint = <int, IconData>{
    0xe2c7: Icons.folder, // Icons.folder.codePoint
    0xe838: Icons.star, // Icons.star.codePoint
    0xe6f3: Icons.work, // Icons.work.codePoint
    0xe0ca: Icons.chat_bubble, // Icons.chat_bubble.codePoint
    0xe158: Icons.mail, // Icons.mail.codePoint
    0xe7ef: Icons.groups, // Icons.groups.codePoint
    0xe86f: Icons.code, // Icons.code.codePoint
    0xf1af: Icons.task_alt, // Icons.task_alt.codePoint
    0xf10d: Icons.push_pin, // Icons.push_pin.codePoint
    0xe866: Icons.bookmark, // Icons.bookmark.codePoint
    0xea0b: Icons.bolt, // Icons.bolt.codePoint
    0xe935: Icons.calendar_today, // Icons.calendar_today.codePoint
    0xe873: Icons.description, // Icons.description.codePoint
    0xe96a: Icons.campaign, // Icons.campaign.codePoint
    0xe868: Icons.bug_report, // Icons.bug_report.codePoint
    0xe32a: Icons.security, // Icons.security.codePoint
  };

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

  static IconData resolve(int? codePoint, {IconData fallback = Icons.folder}) {
    if (codePoint == null) return fallback;
    return byCodePoint[codePoint] ?? fallback;
  }
}

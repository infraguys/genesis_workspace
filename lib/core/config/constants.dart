import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/models/emoji.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  static const String legacyPath = String.fromEnvironment('legacy_ui');
  static const String firebaseApiKey = String.fromEnvironment('firebase_api_key');
  static const String lkUrl = String.fromEnvironment('lk_url');

  static const String appName = 'genesis_workspace';

  static const String tusVersion = '1.0.0';

  static const int jobTitleProfileDataIndex = 1;
  static const int bossNameProfileDataIndex = 2;

  static const String mailCalendarUuid = "00000000-0000-0000-0000-000000000001";

  static late String baseUrl;
  static int? selectedOrganizationId;

  static const String versionConfigUrl = 'https://repository.genesis-core.tech/genesis_workspace/workspace-index.json';
  static const String versionConfigShaUrl =
      'https://repository.genesis-core.tech/genesis_workspace/workspace-index.json.sha256';

  static const String genesisPublicServerUrl = "https://workspace.genesis-core.tech";

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

  static const Set<String> prioritizedVideoFileExtensions = {
    'mp4',
    'mov',
    'm4v',
    'mkv',
    'webm',
    'avi',
    '3gp',
    '3g2',
    'ts',
    'm2ts',
  };
}

class SharedPrefsKeys {
  static const String locale = 'locale';
  static const String isWebAuth = 'isWebAuth';
  static const String selectedOrganizationId = 'selectedOrganizationId';
  static const String baseUrl = 'baseUrl';
  static const String themeMode = 'themeMode';
  static const String themePalette = 'themePalette';
  static const String notificationSound = 'notificationSound';
  static const String prioritizePersonalUnread = 'prioritizePersonalUnread';
  static const String prioritizeUnmutedUnreadChannels = 'prioritizeUnmutedUnreadChannels';
  static const String videoAudioHintDismissed = 'videoAudioHintDismissed';
}

class AssetsConstants {
  static const String audioPop = 'audio/pop.wav';
  static const String audioWhoop = 'audio/whoop.wav';
}

import 'package:genesis_workspace/core/models/emoji.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  // static const String _baseProdUrl = String.fromEnvironment('prod_url');
  // static const String _baseStageUrl = String.fromEnvironment('dev_url');
  static const String legacyPath = String.fromEnvironment('legacy_ui');

  static const String appName = 'genesis_workspace';

  static late String baseUrl;

  static final popularEmojis = [
    UnicodeEmojiDisplay(emojiName: ":thumbs_up:", emojiUnicode: "1F44D"),
    UnicodeEmojiDisplay(emojiName: ":heart:", emojiUnicode: "2764"),
    UnicodeEmojiDisplay(emojiName: ":joy:", emojiUnicode: "1F602"),
    UnicodeEmojiDisplay(emojiName: ":open_mouth:", emojiUnicode: "1F62E"),
    UnicodeEmojiDisplay(emojiName: ":cry:", emojiUnicode: "1F622"),
    UnicodeEmojiDisplay(emojiName: ":clap:", emojiUnicode: "1F44F"),
  ];

  /// Инициализация. Нужно вызвать при старте приложения (например в main)
  static Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? savedBaseUrl = prefs.getString(SharedPrefsKeys.baseUrl);

    if (savedBaseUrl != null && savedBaseUrl.trim().isNotEmpty) {
      baseUrl = savedBaseUrl.trim();
    } else {
      // fallback: если нет сохранённого baseUrl, берём из env по Flavor
      baseUrl = '';
    }
  }

  setBaseUrl(String url) {
    baseUrl = url;
  }
}

class SharedPrefsKeys {
  static const String locale = 'locale';
  static const String isWebAuth = 'isWebAuth';
  static const String baseUrl = 'baseUrl';
}

class AssetsConstants {
  static const String audioPop = 'audio/pop.wav';
}

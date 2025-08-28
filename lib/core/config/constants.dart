import 'package:genesis_workspace/core/models/emoji.dart';
import 'package:genesis_workspace/flavor.dart';

class AppConstants {
  static const String _baseProdUrl = String.fromEnvironment('prod_url');
  static const String _baseStageUrl = String.fromEnvironment('dev_url');
  static const String legacyPath = String.fromEnvironment('legacy_ui');
  static String baseUrl = Flavor.current == Flavor.prod ? _baseProdUrl : _baseStageUrl;
  static final popularEmojis = [
    UnicodeEmojiDisplay(emojiName: ":thumbs_up:", emojiUnicode: "1F44D"),
    UnicodeEmojiDisplay(emojiName: ":heart:", emojiUnicode: "2764"),
    UnicodeEmojiDisplay(emojiName: ":joy:", emojiUnicode: "1F602"),
    UnicodeEmojiDisplay(emojiName: ":open_mouth:", emojiUnicode: "1F62E"),
    UnicodeEmojiDisplay(emojiName: ":cry:", emojiUnicode: "1F622"),
    UnicodeEmojiDisplay(emojiName: ":clap:", emojiUnicode: "1F44F"),
  ];
  static const appName = 'genesis_workspace';
}

class SharedPrefsKeys {
  static const String locale = 'locale';
  static const String isWebAuth = 'isWebAuth';
}

class AssetsConstants {
  static const String audioPop = 'audio/pop.wav';
}

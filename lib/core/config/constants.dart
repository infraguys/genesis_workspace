import 'package:genesis_workspace/flavor.dart';

class AppConstants {
  static const String _baseProdUrl = "https://zulip.tokens.team";
  static const String _baseStageUrl = "https://zulip-dev.tokens.team";
  static String baseUrl = Flavor.current == Flavor.prod ? _baseProdUrl : _baseStageUrl;
}

class SharedPrefsKeys {
  static const String locale = 'locale';
}

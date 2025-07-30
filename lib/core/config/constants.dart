import 'package:genesis_workspace/flavor.dart';

class AppConstants {
  static const String _baseProdUrl = "https://zulip.genesis-core.tech";
  static const String _baseStageUrl = "https://zulip.genesis-core.tech";
  static String baseUrl = Flavor.current == Flavor.prod ? _baseProdUrl : _baseStageUrl;
}

class SharedPrefsKeys {
  static const String locale = 'locale';
}

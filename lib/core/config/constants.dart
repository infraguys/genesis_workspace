import 'package:genesis_workspace/flavor.dart';

class AppConstants {
  static const String _baseProdUrl = String.fromEnvironment('prod_url');
  static const String _baseStageUrl = String.fromEnvironment('dev_url');
  static String baseUrl = Flavor.current == Flavor.prod ? _baseProdUrl : _baseStageUrl;
}

class SharedPrefsKeys {
  static const String locale = 'locale';
}

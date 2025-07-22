import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class LocalizationService {
  late SharedPreferences _prefs;

  init() async {
    _prefs = await SharedPreferences.getInstance();
    LocaleSettings.useDeviceLocale();
  }

  setLocale(AppLocale locale) async {
    await _prefs.setString('locale', locale.languageCode);
    LocaleSettings.setLocale(locale);
  }
}

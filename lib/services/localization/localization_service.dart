import 'dart:developer';

import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class LocalizationService {
  late SharedPreferences _prefs;

  init() async {
    _prefs = await SharedPreferences.getInstance();
    final languageCode = _prefs.getString(SharedPrefsKeys.locale);
    inspect(languageCode);

    if (languageCode != null) {
      LocaleSettings.setLocale(
        AppLocale.values.firstWhere((locale) => locale.languageCode == languageCode),
      );
    } else {
      LocaleSettings.useDeviceLocale();
    }
  }

  /// Устанавливает новую локаль и сохраняет её в SharedPreferences
  Future<void> setLocale(AppLocale locale) async {
    await _prefs.setString(SharedPrefsKeys.locale, locale.languageCode);
    LocaleSettings.setLocale(locale);
  }

  /// Возвращает текущую выбранную локаль
  AppLocale get locale => LocaleSettings.currentLocale;
}

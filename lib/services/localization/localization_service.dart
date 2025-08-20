import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class LocalizationService {
  late final SharedPreferences _prefs;

  LocalizationService();

  init() async {
    _prefs = await SharedPreferences.getInstance();
    final languageCode = _prefs.getString(SharedPrefsKeys.locale);
    if (languageCode != null) {
      final locale = AppLocale.values.firstWhere((locale) => locale.languageCode == languageCode);
      LocaleSettings.setLocale(locale);
      await initializeDateFormatting(locale.languageCode);
    } else {
      LocaleSettings.useDeviceLocale();
      await initializeDateFormatting('en');
    }
  }

  /// Устанавливает новую локаль и сохраняет её в SharedPreferences
  Future<void> setLocale(AppLocale locale) async {
    await _prefs.setString(SharedPrefsKeys.locale, locale.languageCode);
    LocaleSettings.setLocale(locale);
    await initializeDateFormatting(locale.languageCode);
  }

  /// Возвращает текущую выбранную локаль
  AppLocale get locale => LocaleSettings.currentLocale;
}

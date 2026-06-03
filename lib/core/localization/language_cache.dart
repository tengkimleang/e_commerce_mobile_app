import 'package:e_commerce_mobile_app/core/localization/app_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCache {
  const LanguageCache(this._prefs);

  static const languageCodeKey = 'app_language_code';
  static const legacyUserInfoLanguageCodeKey = 'user_info_cache_language';

  final SharedPreferences _prefs;

  String read() {
    final appLanguage = _prefs.getString(languageCodeKey);
    if ((appLanguage ?? '').trim().isNotEmpty) {
      return AppLanguage.normalize(appLanguage);
    }

    final legacyLanguage = _prefs.getString(legacyUserInfoLanguageCodeKey);
    return AppLanguage.normalize(legacyLanguage);
  }

  Future<void> write(String languageCode) async {
    final normalized = AppLanguage.normalize(languageCode);
    AppLanguage.setCurrentLanguageCode(normalized);
    await _prefs.setString(languageCodeKey, normalized);
  }
}

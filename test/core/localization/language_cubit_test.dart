import 'package:e_commerce_mobile_app/core/localization/app_language.dart';
import 'package:e_commerce_mobile_app/core/localization/language_cache.dart';
import 'package:e_commerce_mobile_app/core/localization/language_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() {
    AppLanguage.setCurrentLanguageCode(AppLanguage.khmer);
  });

  test('normalizes supported language aliases to canonical FE values', () {
    expect(AppLanguage.normalize('en-US'), AppLanguage.english);
    expect(AppLanguage.normalize('km-KH'), AppLanguage.khmer);
    expect(AppLanguage.normalize('km_KH'), AppLanguage.khmer);
    expect(AppLanguage.normalize('kh'), AppLanguage.khmer);
    expect(AppLanguage.normalize(''), AppLanguage.english);
  });

  test(
    'cache reads the app language before the legacy profile language',
    () async {
      SharedPreferences.setMockInitialValues({
        LanguageCache.languageCodeKey: 'km-KH',
        LanguageCache.legacyUserInfoLanguageCodeKey: 'en',
      });
      final prefs = await SharedPreferences.getInstance();

      expect(LanguageCache(prefs).read(), AppLanguage.khmer);
    },
  );

  test('cache falls back to legacy profile language during rollout', () async {
    SharedPreferences.setMockInitialValues({
      LanguageCache.legacyUserInfoLanguageCodeKey: 'kh',
    });
    final prefs = await SharedPreferences.getInstance();

    expect(LanguageCache(prefs).read(), AppLanguage.khmer);
  });

  test(
    'cubit persists language changes and updates current app language',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cache = LanguageCache(prefs);
      final cubit = LanguageCubit(cache: cache, initialLanguage: 'en');

      await cubit.changeLanguage('km-KH');

      expect(cubit.state.languageCode, AppLanguage.khmer);
      expect(AppLanguage.currentLanguageCode, AppLanguage.khmer);
      expect(prefs.getString(LanguageCache.languageCodeKey), AppLanguage.khmer);

      await cubit.close();
    },
  );
}

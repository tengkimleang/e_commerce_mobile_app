import 'package:flutter/widgets.dart';

abstract final class AppLanguage {
  static const english = 'en';
  static const khmer = 'km';
  static const supportedLanguageCodes = [english, khmer];

  static String _currentLanguageCode = khmer;

  static String get currentLanguageCode => _currentLanguageCode;
  static Locale get currentLocale => Locale(_currentLanguageCode);
  static bool get isKhmer => _currentLanguageCode == khmer;

  static void setCurrentLanguageCode(String languageCode) {
    _currentLanguageCode = normalize(languageCode);
  }

  static String normalize(String? rawLanguageCode) {
    final value = (rawLanguageCode ?? '').trim().toLowerCase();
    if (value.isEmpty) return english;

    final normalized = value.replaceAll('_', '-');
    if (normalized == khmer ||
        normalized == 'kh' ||
        normalized.startsWith('$khmer-')) {
      return khmer;
    }
    if (normalized == english || normalized.startsWith('$english-')) {
      return english;
    }
    return english;
  }

  static String labelFor(String languageCode) {
    return normalize(languageCode) == khmer ? 'Khmer' : 'English';
  }

  static String flagFor(String languageCode) {
    return normalize(languageCode) == khmer ? '🇰🇭' : '🇬🇧';
  }

  static String localizedText({
    required String languageCode,
    String english = '',
    String khmer = '',
    String legacy = '',
  }) {
    final normalized = normalize(languageCode);
    final englishText = english.trim();
    final khmerText = khmer.trim();
    final legacyText = legacy.trim();

    if (normalized == AppLanguage.khmer && khmerText.isNotEmpty) {
      return khmerText;
    }
    if (englishText.isNotEmpty) return englishText;
    if (legacyText.isNotEmpty) return legacyText;
    return khmerText;
  }
}

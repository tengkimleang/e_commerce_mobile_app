import 'package:e_commerce_mobile_app/core/localization/app_language.dart';
import 'package:e_commerce_mobile_app/core/localization/language_cache.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageState extends Equatable {
  const LanguageState(this.languageCode);

  final String languageCode;

  Locale get locale => Locale(languageCode);
  bool get isKhmer => languageCode == AppLanguage.khmer;

  @override
  List<Object?> get props => [languageCode];
}

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit({required LanguageCache cache, required String initialLanguage})
    : _cache = cache,
      super(LanguageState(AppLanguage.normalize(initialLanguage))) {
    AppLanguage.setCurrentLanguageCode(state.languageCode);
  }

  final LanguageCache _cache;

  Future<void> changeLanguage(String languageCode) async {
    final normalized = AppLanguage.normalize(languageCode);
    if (normalized == state.languageCode) return;

    AppLanguage.setCurrentLanguageCode(normalized);
    emit(LanguageState(normalized));
    await _cache.write(normalized);
  }
}

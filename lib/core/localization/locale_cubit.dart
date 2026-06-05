import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(super.initialLocale);

  static const String _cacheLanguageKey = 'user_info_cache_language';

  static Future<Locale> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_cacheLanguageKey) ?? 'en';
    return Locale(saved);
  }

  Future<void> setLocale(String code) async {
    emit(Locale(code));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheLanguageKey, code);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  static const String _localeKey = 'selected_locale';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> clearLocale() async {
    state = const Locale('en');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

// Available locales
const List<Locale> supportedLocales = [
  Locale('en', ''), // English
  Locale('fr', ''), // French
];

// Helper function to get locale display name
String getLocaleDisplayName(String languageCode) {
  switch (languageCode) {
    case 'en':
      return 'English';
    case 'fr':
      return 'Français';
    default:
      return 'English';
  }
}

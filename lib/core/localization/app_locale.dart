import 'package:flutter/material.dart';

enum AppLocale {
  ru(Locale('ru')),
  en(Locale('en'));

  const AppLocale(this.locale);

  final Locale locale;

  static List<Locale> get supportedLocales => AppLocale.values
      .map((localeEntry) => localeEntry.locale)
      .toList(growable: false);

  static AppLocale fromLanguageCode(String languageCode) {
    return AppLocale.values.firstWhere(
      (localeEntry) => localeEntry.locale.languageCode == languageCode,
      orElse: () => AppLocale.ru,
    );
  }
}

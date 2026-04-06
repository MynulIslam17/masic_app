// lib/core/constants/language_constants.dart

/// All supported languages for the app.
/// To add a new language, just add a new [AppLanguage] entry to [AppLanguages.all].
class AppLanguage {
  final String code;
  final String name;
  final String flag;
  final String locale; // BCP-47 locale string, e.g. 'en-US'

  const AppLanguage({
    required this.code,
    required this.name,
    required this.flag,
    required this.locale,
  });
}

abstract class AppLanguages {
  static const AppLanguage english = AppLanguage(
    code: 'en',
    name: 'English',
    flag: '🇺🇸',
    locale: 'en-US',
  );

  static const AppLanguage arabic = AppLanguage(
    code: 'ar',
    name: 'Arabic',
    flag: '🇸🇦',
    locale: 'ar-SA',
  );

  static const AppLanguage bangla = AppLanguage(
    code: 'bn',
    name: 'বাংলা',
    flag: '🇧🇩',
    locale: 'bn-BD',
  );

  static const AppLanguage french = AppLanguage(
    code: 'fr',
    name: 'Français',
    flag: '🇫🇷',
    locale: 'fr-FR',
  );

  static const AppLanguage spanish = AppLanguage(
    code: 'es',
    name: 'Español',
    flag: '🇪🇸',
    locale: 'es-ES',
  );

  // ─── Add more languages here ─────────────────────────────────────────────
  // static const AppLanguage hindi = AppLanguage(
  //   code: 'hi',
  //   name: 'हिन्दी',
  //   flag: '🇮🇳',
  //   locale: 'hi-IN',
  // );

  /// The full list of languages shown in the language picker.
  /// Reorder or remove entries as needed.
  static const List<AppLanguage> all = [
    english,
    arabic,
    bangla,
    french,
    spanish,
  ];

  /// Default / fallback language.
  static const AppLanguage defaultLanguage = english;

  /// SharedPreferences key used by [TranslationService].
  static const String storageKey = 'selected_language_code';

  /// SharedPreferences cache prefix used by [TranslationService].
  static const String cachePrefix = 'translation_cache_';

  /// Lookup a language by code. Falls back to [defaultLanguage].
  static AppLanguage fromCode(String code) {
    return all.firstWhere(
          (l) => l.code == code,
      orElse: () => defaultLanguage,
    );
  }
}
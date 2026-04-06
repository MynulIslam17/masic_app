// lib/core/services/translation_service.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

import '../constants/language_constants.dart';

/// Singleton service that handles translation + caching.
///
/// Usage:
/// ```dart
/// await TranslationService().init();
/// final text = await TranslationService().translate('Hello', targetCode: 'ar');
/// ```
class TranslationService {
  // ─── Singleton ────────────────────────────────────────────────────────────
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  // ─── Internals ────────────────────────────────────────────────────────────
  final GoogleTranslator _translator = GoogleTranslator();
  SharedPreferences? _prefs;
  AppLanguage _currentLanguage = AppLanguages.defaultLanguage;

  // ─── Init ─────────────────────────────────────────────────────────────────

  /// Must be called once at app startup (e.g. in main.dart before runApp).
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final savedCode = _prefs!.getString(AppLanguages.storageKey);
    _currentLanguage = AppLanguages.fromCode(savedCode ?? AppLanguages.defaultLanguage.code);
  }

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Currently selected language.
  AppLanguage get currentLanguage => _currentLanguage;

  /// All supported languages (from [AppLanguages.all]).
  List<AppLanguage> get supportedLanguages => AppLanguages.all;

  /// Persist and update the active language.
  Future<void> setLanguage(AppLanguage language) async {
    _prefs ??= await SharedPreferences.getInstance();
    _currentLanguage = language;
    await _prefs!.setString(AppLanguages.storageKey, language.code);
  }

  /// Translate [text] into [targetCode] (ISO 639-1, e.g. 'ar').
  ///
  /// - Returns [text] unchanged if [targetCode] is the default language or empty.
  /// - Checks local cache first; only calls the network API when needed.
  /// - On network error, returns the original [text] silently.
  Future<String> translate(String text, {required String targetCode}) async {
    if (_prefs == null) await init();

    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;
    if (targetCode.isEmpty || targetCode == AppLanguages.defaultLanguage.code) return text;

    // Cache hit
    final cached = _getCached(trimmed, targetCode);
    if (cached != null) return cached;

    // Network call
    try {
      final result = await _translator.translate(trimmed, from: 'auto', to: targetCode);
      await _saveCache(trimmed, targetCode, result.text);
      return result.text;
    } catch (_) {
      return text;
    }
  }

  /// Synchronous cache lookup — returns null on miss.
  /// Use this in widgets for instant zero-flicker display.
  String? getCached(String text, {required String targetCode}) {
    if (_prefs == null) return null;
    if (targetCode.isEmpty || targetCode == AppLanguages.defaultLanguage.code) return null;
    return _getCached(text.trim(), targetCode);
  }

  // ─── Cache Management ─────────────────────────────────────────────────────

  /// Clear all cached translations.
  Future<void> clearAllCache() async {
    _prefs ??= await SharedPreferences.getInstance();
    final keys = _prefs!.getKeys().where((k) => k.startsWith(AppLanguages.cachePrefix));
    for (final key in keys) {
      await _prefs!.remove(key);
    }
  }

  /// Clear cached translations for a specific language.
  Future<void> clearCacheForLanguage(String targetCode) async {
    _prefs ??= await SharedPreferences.getInstance();
    final prefix = '${AppLanguages.cachePrefix}${targetCode}_';
    final keys = _prefs!.getKeys().where((k) => k.startsWith(prefix));
    for (final key in keys) {
      await _prefs!.remove(key);
    }
  }

  // ─── Private Helpers ──────────────────────────────────────────────────────

  String _cacheKey(String text, String targetCode) =>
      '${AppLanguages.cachePrefix}${targetCode}_${text.hashCode}';

  String? _getCached(String text, String targetCode) {
    try {
      final raw = _prefs?.getString(_cacheKey(text, targetCode));
      if (raw == null) return null;
      final data = json.decode(raw) as Map<String, dynamic>;
      return data['t'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCache(String text, String targetCode, String translation) async {
    final key = _cacheKey(text, targetCode);
    final payload = json.encode({'t': translation, 'ts': DateTime.now().millisecondsSinceEpoch});
    await _prefs?.setString(key, payload);
  }
}
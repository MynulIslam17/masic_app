// lib/features/translation/controller/translation_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_task/core/constants/language_constants.dart';
import 'package:flutter_task/core/services/translation_service.dart';
import 'package:get/get.dart';

/// GetX controller for language selection.
///
/// Register in DI:
/// ```dart
/// Get.put(LanguageController(), permanent: true);
/// ```
///
/// Use in widgets:
/// ```dart
/// final lang = LanguageController.to;
/// lang.changeLanguage(AppLanguages.arabic);
/// ```
class TranslationController extends GetxController {
  static TranslationController get to => Get.find();

  // ─── State ────────────────────────────────────────────────────────────────

  /// Currently selected language (reactive).
  final Rx<AppLanguage> currentLanguage =
      AppLanguages.defaultLanguage.obs;

  /// Incremented every time language changes — AutoTranslate widgets watch this.
  final RxInt retranslateTrigger = 0.obs;

  // ─── Computed ─────────────────────────────────────────────────────────────

  String get currentCode => currentLanguage.value.code;
  String get currentFlag => currentLanguage.value.flag;
  String get currentName => currentLanguage.value.name;
  bool get isRtl => _rtlCodes.contains(currentCode);

  /// Full list of available languages (from constants).
  List<AppLanguage> get languages => AppLanguages.all;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _syncFromService();
  }

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Change the active language.
  ///
  /// - Persists the selection via [TranslationService].
  /// - Updates Flutter locale (for date pickers, text direction, etc.).
  /// - Notifies all [AutoTranslate] widgets to re-translate.
  /// - Calls the optional [onChange] callback after switching.
  Future<void> changeLanguage(
      AppLanguage language, {
        VoidCallback? onChange,
      }) async {
    if (currentLanguage.value.code == language.code) return;

    currentLanguage.value = language;
    await TranslationService().setLanguage(language);

    _updateFlutterLocale(language);

    // Signal all AutoTranslate widgets
    retranslateTrigger.value++;

    onChange?.call();
  }

  /// Reset to the default language.
  Future<void> resetToDefault({VoidCallback? onChange}) async {
    await changeLanguage(AppLanguages.defaultLanguage, onChange: onChange);
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  void _syncFromService() {
    currentLanguage.value = TranslationService().currentLanguage;
    if (isRtl) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateFlutterLocale(currentLanguage.value);
      });
    }
  }

  void _updateFlutterLocale(AppLanguage language) {
    final parts = language.locale.split('-');
    Get.updateLocale(Locale(parts[0], parts.length > 1 ? parts[1] : null));
  }

  static const Set<String> _rtlCodes = {'ar', 'he', 'fa', 'ur'};
}
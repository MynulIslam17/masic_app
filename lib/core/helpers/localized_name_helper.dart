import 'package:get/get.dart';
import 'package:masic_generation/core/constants/language_constants.dart';
import 'package:masic_generation/features/poll/data/models/poll_details_model.dart'
    as poll_details;
import 'package:masic_generation/features/poll/data/models/poll_result_model.dart'
    as poll_result;
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/request/data/models/request_model.dart'
    as request_model;
import 'package:masic_generation/core/services/translation_service.dart';
import 'package:masic_generation/features/notification/data/models/notification_model.dart';
import 'package:masic_generation/features/translation/presentation/controller/translation_controller.dart';
import 'package:masic_generation/features/tree/data/models/tree_model.dart'
    as tree_model;

/// Display and search helpers for bilingual member names (English / Arabic).
class LocalizedNameHelper {
  LocalizedNameHelper._();

  static bool get isArabicLocale {
    try {
      return TranslationController.to.currentCode == AppLanguages.arabic.code;
    } catch (_) {
      return Get.locale?.languageCode == AppLanguages.arabic.code;
    }
  }

  static final RegExp _arabicScript = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  );

  /// True when the user is typing in Arabic script (tree / member search).
  static bool isArabicQuery(String query) => _arabicScript.hasMatch(query);

  /// Sync label for lists/PDF. English → [name]. Arabic → [arabicName] or [name] (translate in UI).
  static String display({
    String? name,
    String? arabicName,
    String? fallback,
  }) {
    if (isArabicLocale) {
      final ar = arabicName?.trim();
      if (ar != null && ar.isNotEmpty) return ar;
      final en = name?.trim();
      if (en != null && en.isNotEmpty) return en;
      final fb = fallback?.trim();
      if (fb != null && fb.isNotEmpty) return fb;
      return '';
    }

    final en = name?.trim();
    if (en != null && en.isNotEmpty) return en;
    final fb = fallback?.trim();
    if (fb != null && fb.isNotEmpty) return fb;
    return '';
  }

  /// Arabic locale, no [arabicName]: translate English [name] via [TranslationService].
  static bool shouldTranslateName({String? name, String? arabicName}) {
    if (!isArabicLocale) return false;
    if (arabicName != null && arabicName.trim().isNotEmpty) return false;
    return name != null && name.trim().isNotEmpty;
  }

  static Future<String> resolveForExport({
    String? name,
    String? arabicName,
    String? fallback,
  }) async {
    if (!isArabicLocale) {
      return display(name: name, arabicName: arabicName, fallback: fallback);
    }
    final ar = arabicName?.trim();
    if (ar != null && ar.isNotEmpty) return ar;
    final en = name?.trim();
    if (en != null && en.isNotEmpty) {
      return TranslationService().translate(
        en,
        targetCode: AppLanguages.arabic.code,
      );
    }
    return fallback?.trim() ?? '';
  }

  /// Arabic query → match [arabicName] (+ email). Otherwise → [name] (+ email, relation).
  static bool matchesMemberSearch({
    required String query,
    String? name,
    String? arabicName,
    String? email,
    String? relationType,
  }) {
    final q = query.trim();
    if (q.isEmpty) return false;
    final qLower = q.toLowerCase();

    if (isArabicLocale || isArabicQuery(q)) {
      final hay = '${arabicName ?? ''} ${name ?? ''} ${email ?? ''}'
          .trim()
          .toLowerCase();
      return hay.contains(qLower);
    }

    final hay =
        '${name ?? ''} ${email ?? ''} ${relationType ?? ''}'.trim().toLowerCase();
    return hay.contains(qLower);
  }
}

extension UserModelLocalizedName on UserModel {
  String get localizedDisplayName => LocalizedNameHelper.display(
        name: name,
        arabicName: arabicName,
      );

  bool matchesLocalizedNameSearch(String query) =>
      LocalizedNameHelper.matchesMemberSearch(
        query: query,
        name: name,
        arabicName: arabicName,
        email: email,
      );
}

extension RequestUserLocalizedName on request_model.User {
  String get localizedDisplayName => LocalizedNameHelper.display(
        name: name,
        arabicName: arabicName,
      );
}

extension PollDetailsUserLocalizedName on poll_details.PollUser {
  String get localizedDisplayName => LocalizedNameHelper.display(
        name: name,
        arabicName: arabicName,
      );
}

extension PollResultUserLocalizedName on poll_result.User {
  String get localizedDisplayName => LocalizedNameHelper.display(
        name: name,
        arabicName: arabicName,
      );
}

extension TreeLinkedUserLocalizedName on tree_model.LinkedUser {
  String get localizedDisplayName => LocalizedNameHelper.display(
        name: name,
        arabicName: arabicName,
      );
}

extension NotificationDataLocalizedName on NotificationData {
  String get localizedDisplayName => LocalizedNameHelper.display(
        name: name,
        arabicName: arabicName,
      );
}

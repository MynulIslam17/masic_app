import 'package:flutter/foundation.dart';

/// One place for every debug log in the app, so the console reads the same
/// way everywhere:
///
/// ```
/// ❌ [Profile] Load mother trees failed: No internet
///      ↳ ProfileController.loadMotherTrees (profile_controller.dart:1049)
/// ```
///
/// * the icon is the level (ℹ️ info, ✅ success, ⚠️ warning, ❌ error)
/// * `[Tag]` is the feature or service the log belongs to
/// * the `↳` line is where it was logged from (warnings and errors only)
///
/// Nothing is printed in release builds.
class AppLog {
  AppLog._();

  /// Something happened that is useful to follow the flow.
  static void info(String tag, Object? message) => _print('ℹ️', tag, message);

  /// An action finished successfully.
  static void success(String tag, Object? message) =>
      _print('✅', tag, message);

  /// Unexpected but handled; the app carries on.
  static void warn(String tag, Object? message) =>
      _print('⚠️', tag, message, withLocation: true);

  /// Something failed.
  static void error(String tag, Object? message, [StackTrace? stackTrace]) {
    _print('❌', tag, message, withLocation: true);
    if (kDebugMode && stackTrace != null) debugPrint('$stackTrace');
  }

  static void _print(
    String icon,
    String tag,
    Object? message, {
    bool withLocation = false,
  }) {
    if (!kDebugMode) return;
    debugPrint('$icon [$tag] $message');
    if (!withLocation) return;
    final location = _callSite();
    if (location != null) debugPrint('     ↳ $location');
  }

  static final RegExp _frame = RegExp(r'^#\d+\s+(.+?)\s+\((.+?)\)$');

  /// `Class.method (file.dart:line)` of the code that called [AppLog].
  static String? _callSite() {
    for (final line in StackTrace.current.toString().split('\n')) {
      if (line.contains('app_log.dart')) continue;
      final match = _frame.firstMatch(line.trim());
      if (match == null) continue;
      final member = match
          .group(1)!
          .replaceAll('.<anonymous closure>', '')
          .replaceAll('<fn>', '');
      // package:app/path/to/file.dart:12:5 -> file.dart:12
      final parts = match.group(2)!.split('/').last.split(':');
      final file = parts.length >= 2 ? '${parts[0]}:${parts[1]}' : parts.first;
      return '$member ($file)';
    }
    return null;
  }
}

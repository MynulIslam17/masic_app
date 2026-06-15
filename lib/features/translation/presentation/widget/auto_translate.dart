// lib/features/translation/widget/auto_translate.dart

import 'package:flutter/material.dart';
import 'package:masic_generation/features/translation/presentation/controller/translation_controller.dart';
import 'package:get/get.dart';
import '../../../../core/services/translation_service.dart';

/// Wraps a [Text] widget and automatically translates its content
/// whenever the active language changes.
///
/// **Basic usage:**
/// ```dart
/// AutoTranslate(child: Text('Hello World'))
/// ```
///
/// **Disable translation for a specific widget:**
/// ```dart
/// AutoTranslate(enable: false, child: Text('Keep as-is'))
/// ```
///
/// **Force a specific target language:**
/// ```dart
/// AutoTranslate(languageCode: 'fr', child: Text('Bonjour'))
/// ```
///
/// Only [Text] children are translated. Other widget types are returned
/// unchanged (no-op, no errors).
class AutoTranslate extends StatefulWidget {
  const AutoTranslate({
    super.key,
    required this.child,
    this.languageCode,
    this.enable = true,
  });

  /// The widget to translate. Only [Text] is supported.
  final Widget child;

  /// Override the target language. Defaults to the active language from
  /// [TranslationController].
  final String? languageCode;

  /// Set to false to bypass translation entirely.
  final bool enable;

  @override
  State<AutoTranslate> createState() => _AutoTranslateState();
}

class _AutoTranslateState extends State<AutoTranslate> {
  String? _translatedText;
  String? _lastSourceKey; // '<text>_<lang>' — avoids redundant API calls
  Worker? _worker;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    final controller = Get.find<TranslationController>();

    // Watch the global retranslateTrigger so all widgets re-translate in sync
    // when the user switches language.
    _worker = ever(controller.retranslateTrigger, (_) {
      _lastSourceKey = null;
      _translatedText = null;
      _translateChild();
    });

    _translateChild();
  }

  @override
  void didUpdateWidget(AutoTranslate oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldText = _extractText(oldWidget.child);
    final newText = _extractText(widget.child);

    if (oldText != newText ||
        oldWidget.languageCode != widget.languageCode ||
        oldWidget.enable != widget.enable) {
      _translateChild();
    }
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  // ─── Translation Logic ────────────────────────────────────────────────────

  Future<void> _translateChild() async {
    if (!widget.enable) {
      _clearTranslation();
      return;
    }

    final text = _extractText(widget.child);
    if (text == null || text.isEmpty) {
      _clearTranslation();
      return;
    }

    final targetCode =
        widget.languageCode ?? TranslationController.to.currentCode;
    final sourceKey = '${text}_$targetCode';

    // Same text + same language — nothing to do
    if (sourceKey == _lastSourceKey) return;

    // ── Cache hit: instant, no flicker ──────────────────────────────────────
    final cached = TranslationService().getCached(text, targetCode: targetCode);
    if (cached != null) {
      if (mounted) {
        setState(() {
          _translatedText = cached;
          _lastSourceKey = sourceKey;
        });
      }
      return;
    }

    // ── Cache miss: translate in background ─────────────────────────────────
    final translated = await TranslationService().translate(
      text,
      targetCode: targetCode,
    );

    if (mounted) {
      setState(() {
        _translatedText = translated;
        _lastSourceKey = sourceKey;
      });
    }
  }

  void _clearTranslation() {
    if (mounted) {
      setState(() {
        _translatedText = null;
        _lastSourceKey = null;
      });
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String? _extractText(Widget w) {
    if (w is Text) {
      if (w.data != null) return w.data;
      if (w.textSpan != null) return w.textSpan!.toPlainText();
    }
    return null;
  }

  Widget _buildTranslated() {
    if (_translatedText == null) return widget.child;

    final src = widget.child;
    if (src is Text) {
      return Text(
        _translatedText!,
        key: src.key,
        style: src.style,
        strutStyle: src.strutStyle,
        textAlign: src.textAlign,
        textDirection: src.textDirection,
        locale: src.locale,
        softWrap: src.softWrap,
        overflow: src.overflow,
        textScaler: src.textScaler,
        maxLines: src.maxLines,
        semanticsLabel: src.semanticsLabel,
        textWidthBasis: src.textWidthBasis,
        textHeightBehavior: src.textHeightBehavior,
      );
    }

    return widget.child;
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!widget.enable) return widget.child;
    return _buildTranslated();
  }
}
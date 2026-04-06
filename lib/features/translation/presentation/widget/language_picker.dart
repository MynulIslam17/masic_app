// lib/features/translation/widget/language_picker.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/language_constants.dart';
import '../controller/translation_controller.dart';

/// A ready-to-use language picker bottom sheet.
///
/// **Show it anywhere:**
/// ```dart
/// LanguagePicker.show(context);
/// ```
///
/// **With an onChange callback:**
/// ```dart
/// LanguagePicker.show(
///   context,
///   onChange: (lang) => print('Switched to ${lang.name}'),
/// );
/// ```
class LanguagePicker {
  LanguagePicker._();

  static void show(
      BuildContext context, {
        void Function(AppLanguage)? onChange,
      }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LanguagePickerSheet(onChange: onChange),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({this.onChange});

  final void Function(AppLanguage)? onChange;

  @override
  Widget build(BuildContext context) {
    final controller = TranslationController.to;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Select Language',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Language list
          Obx(() {
            final current = controller.currentCode;
            return Column(
              children: AppLanguages.all.map((lang) {
                final isSelected = lang.code == current;
                return ListTile(
                  leading: Text(lang.flag,
                      style: const TextStyle(fontSize: 28)),
                  title: Text(lang.name),
                  subtitle: Text(lang.code.toUpperCase(),
                      style: TextStyle(color: theme.hintColor)),
                  trailing: isSelected
                      ? Icon(Icons.check_circle,
                      color: theme.colorScheme.primary)
                      : null,
                  selected: isSelected,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.changeLanguage(
                      lang,
                      onChange: onChange != null ? () => onChange!(lang) : null,
                    );
                  },
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

/// A compact flag + code button that opens [LanguagePicker] on tap.
///
/// ```dart
/// LanguageButton()  // place in AppBar actions or settings screen
/// ```
class LanguageButton extends StatelessWidget {
  const LanguageButton({
    super.key,
    this.onChange,
  });

  final void Function(AppLanguage)? onChange;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = TranslationController.to;
      return InkWell(
        onTap: () => LanguagePicker.show(context, onChange: onChange),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.currentFlag,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 4),
              Text(
                controller.currentCode.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
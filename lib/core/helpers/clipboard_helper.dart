import 'package:flutter/services.dart';
import 'package:masic_generation/core/helpers/toast_message_helper.dart';

class ClipboardHelper {
  ClipboardHelper._();

  static Future<void> copy(String text, {String message = 'Copied'}) async {
    final value = text.trim();
    if (value.isEmpty || value.toUpperCase() == 'N/A') return;

    await Clipboard.setData(ClipboardData(text: value));
    ToastMessageHelper.show(message);
  }
}

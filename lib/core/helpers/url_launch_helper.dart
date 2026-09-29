import 'package:masic_generation/core/helpers/toast_message_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLaunchHelper {
  UrlLaunchHelper._();

  static Future<void> open(String raw) async {
    var text = raw.trim();
    if (text.isEmpty) return;

    if (!text.contains('://')) {
      text = 'https://$text';
    }

    final uri = Uri.tryParse(text);
    if (uri == null) {
      ToastMessageHelper.show('Invalid link');
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      ToastMessageHelper.show('Could not open link');
    }
  }
}

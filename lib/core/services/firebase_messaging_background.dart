import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:masic_generation/firebase_options.dart';

/// Background FCM handler (must be a top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isNotEmpty) return;

  final options = switch (defaultTargetPlatform) {
    TargetPlatform.iOS => DefaultFirebaseOptions.ios,
    TargetPlatform.android => DefaultFirebaseOptions.android,
    _ => DefaultFirebaseOptions.android,
  };

  try {
    await Firebase.initializeApp(options: options);
  } catch (e, stack) {
    debugPrint('firebaseMessagingBackgroundHandler init failed: $e\n$stack');
  }
}

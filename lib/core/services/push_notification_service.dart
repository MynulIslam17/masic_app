import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/services/firebase_messaging_background.dart';
import 'package:masic_generation/core/services/storage_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// Firebase Cloud Messaging + local notifications (foreground display).
class PushNotificationService {
  static const _androidChannelId = 'masic_high_importance_channel';
  static const _androidChannelName = 'Masic Notifications';

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initLocalNotifications();
    await _requestPermissions();

    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _scheduleOpenFromNotification(initialMessage);
    }

    _messaging.onTokenRefresh.listen(_persistToken);

    _initialized = true;
    await _persistToken(await getToken());
  }

  /// Returns the current FCM token (with short retries on iOS while APNs connects).
  Future<String?> getToken() async {
    try {
      if (Platform.isIOS) {
        for (var attempt = 0; attempt < 5; attempt++) {
          final apns = await _messaging.getAPNSToken();
          if (apns != null) break;
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      }
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('PushNotificationService.getToken: $e');
      return null;
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      return;
    }
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: (_) => _openNotificationScreen(),
    );

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _androidChannelId,
              _androidChannelName,
              description: 'Updates and alerts from Masic Generation',
              importance: Importance.high,
            ),
          );
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final android = notification.android;
    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: 'Updates and alerts from Masic Generation',
          importance: Importance.high,
          priority: Priority.high,
          icon: android?.smallIcon ?? '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    _openNotificationScreen();
  }

  void _scheduleOpenFromNotification(RemoteMessage message) {
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      _openNotificationScreen();
    });
  }

  void _openNotificationScreen() {
    if (Get.currentRoute == AppRoutes.notificationScreen) return;
    if (Get.key.currentState == null) return;
    Get.toNamed(AppRoutes.notificationScreen);
  }

  Future<void> _persistToken(String? token) async {
    if (token == null || token.isEmpty) return;
    if (!Get.isRegistered<StorageService>()) return;
    await Get.find<StorageService>().setString(StorageKeys.fcmToken, token);
  }
}

import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/services/firebase_messaging_background.dart';
import 'package:masic_generation/core/services/storage_service.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:permission_handler/permission_handler.dart';

typedef FcmTokenRefreshHandler = Future<void> Function(String token);

/// Firebase Cloud Messaging + local notifications (foreground display).
class PushNotificationService {
  static const _androidChannelId = 'masic_high_importance_channel';
  static const _androidChannelName = 'Masic Notifications';

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  FcmTokenRefreshHandler? _tokenRefreshHandler;
  StreamSubscription<String>? _tokenRefreshSubscription;

  void setTokenRefreshHandler(FcmTokenRefreshHandler? handler) {
    _tokenRefreshHandler = handler;
  }

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

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(_onTokenRefresh);

    _initialized = true;
    await _onTokenRefresh(await getToken());
  }

  Future<void> _onTokenRefresh(String? token) async {
    await _persistToken(token);
    if (token == null || token.isEmpty) return;
    await _tokenRefreshHandler?.call(token);
  }

  /// Returns the current FCM token (with retries on iOS while APNs connects).
  Future<String?> getToken() async {
    try {
      if (Platform.isIOS) {
        for (var attempt = 0; attempt < 10; attempt++) {
          final apns = await _messaging.getAPNSToken();
          if (apns != null) break;
          await Future<void>.delayed(const Duration(milliseconds: 800));
        }
      }
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('PushNotificationService.getToken: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('PushNotificationService.deleteToken: $e');
    }
    if (Get.isRegistered<StorageService>()) {
      await Get.find<StorageService>().remove(StorageKeys.fcmToken);
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
    if (notification == null) {
      final title = message.data['title']?.toString();
      final body = message.data['body']?.toString();
      if (title == null && body == null) return;
      await _showLocalNotification(
        id: message.hashCode,
        title: title,
        body: body,
      );
      return;
    }

    final android = notification.android;
    await _showLocalNotification(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      androidIcon: android?.smallIcon,
    );
  }

  Future<void> _showLocalNotification({
    required int id,
    String? title,
    String? body,
    String? androidIcon,
  }) async {
    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: 'Updates and alerts from Masic Generation',
          importance: Importance.high,
          priority: Priority.high,
          icon: androidIcon ?? '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    _openNotificationScreen();
  }

  void _scheduleOpenFromNotification(RemoteMessage message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 800), () {
        _openNotificationScreen();
      });
    });
  }

  void _openNotificationScreen() {
    if (Get.key.currentState == null) return;

    if (Get.isRegistered<AuthController>() && !AuthController.to.isLoggedIn()) {
      if (Get.currentRoute != AppRoutes.loginScreen) {
        Get.toNamed(AppRoutes.loginScreen);
      }
      return;
    }

    if (Get.currentRoute == AppRoutes.notificationScreen) return;
    Get.toNamed(AppRoutes.notificationScreen);
  }

  Future<void> _persistToken(String? token) async {
    if (token == null || token.isEmpty) return;
    if (!Get.isRegistered<StorageService>()) return;
    await Get.find<StorageService>().setString(StorageKeys.fcmToken, token);
  }
}

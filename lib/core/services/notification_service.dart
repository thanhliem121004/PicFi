import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../routes/app_router.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;
  static GlobalKey<ScaffoldMessengerState>? _scaffoldMessengerKey;

  static Future<void> init(GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) async {
    _scaffoldMessengerKey = scaffoldMessengerKey;

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      _fcmToken = await _messaging.getToken();
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNavigation(initialMessage.data);
    }
  }

  static Future<void> saveToken(String userId) async {
    _fcmToken = await _messaging.getToken();
    if (_fcmToken != null && userId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': _fcmToken});
    }
  }

  static Future<void> removeToken(String userId) async {
    if (userId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': FieldValue.delete()});
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    if (notification == null || _scaffoldMessengerKey?.currentContext == null) return;

    _showInAppNotification(
      notification.title ?? '',
      notification.body ?? '',
    );
  }

  static void _handleBackgroundMessage(RemoteMessage message) {
    _handleNavigation(message.data);
  }

  static void _handleNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    switch (type) {
      case 'expense':
        AppRouter.router.go('/expense-detail', extra: id ?? '');
        break;
      case 'profile':
        if (id != null) AppRouter.router.go('/profile/$id');
        break;
      case 'friends':
        AppRouter.router.go('/friends');
        break;
    }
  }

  static void _showInAppNotification(String title, String body) {
    _scaffoldMessengerKey?.currentState?.clearSnackBars();
    _scaffoldMessengerKey?.currentState?.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              body,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF006A65),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

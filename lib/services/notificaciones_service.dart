import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificacionesService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // El navigatorKey debe pasarse desde main.dart
  static late GlobalKey<NavigatorState> navigatorKey;

  /// Inicializa Firebase Messaging
  static Future<void> initializeFCM() async {
    await _messaging.requestPermission();

    final fcmToken = await _messaging.getToken();
    print('🔑 Token FCM: $fcmToken');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📲 Notificación en primer plano: ${message.notification?.title}');

      final context = navigatorKey.currentContext;
      if (context != null && message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.notification!.title ?? 'Notificación',
              style: const TextStyle(fontSize: 16),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Notificación abierta: ${message.notification?.title}');
    });

    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }

  static Future<void> _backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('🔔 Segundo plano: ${message.messageId}');
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/core/config.dart';

class NotificacionesService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static const String apiUrl = '${baseUrl}usuarios.php';
  // El navigatorKey debe pasarse desde main.dart
  static late GlobalKey<NavigatorState> navigatorKey;

  static Future<void> guardarTokenFCMEnBackend(int idUsuario) async {
    try {
      final token = await _messaging.getToken();

      if (token == null) {
        print("❌ Token FCM es null");
        return;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_usuario': idUsuario, 'token_fcm': token}),
      );

      if (response.statusCode == 200) {
        print("✅ Token FCM guardado en backend");
      } else {
        print("❌ Error al guardar token FCM en backend: ${response.body}");
      }
    } catch (e) {
      print("❌ Excepción al guardar token FCM: $e");
    }
  }

  /// Inicializa Firebase Messaging
  static Future<void> initializeFCM() async {
    await _messaging.requestPermission();

    final fcmToken = await _messaging.getToken();
    print('🔑 Token FCM: $fcmToken');

    // ✅ Suscribirse al topic "todos"
    try {
      await _messaging.subscribeToTopic("todos");
      print('📌 Suscrito al topic "todos"');
    } catch (e) {
      print('⚠️ Error al suscribirse al topic: $e');
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final context = navigatorKey.currentContext;

      // Extrae primero de `message.data`, si no hay, intenta desde `message.notification`
      final titulo =
          message.data['title'] ?? message.notification?.title ?? 'Sin título';
      final mensaje = message.data['body'] ?? message.notification?.body ?? '';

      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$titulo → \n$mensaje',
              style: const TextStyle(fontSize: 15),
            ),
            duration: const Duration(seconds: 9),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Notificación abierta: ${message.notification?.title}');

      final context = navigatorKey.currentContext;
      if (context != null) {
        navigatorKey.currentState?.pushNamed('/mapa');
      }
    });
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }

  static Future<void> _backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('🔔 Segundo plano: ${message.messageId}');
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'providers/user_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/usuarios_page.dart';
import 'pages/animales_page.dart';
import 'pages/dispositivos_page.dart';
import 'pages/mapa_page.dart';
import 'services/notificaciones_service.dart';
import 'pages/splash_screen.dart'; 

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 Notificación recibida en segundo plano: ${message.messageId}');
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificacionesService.navigatorKey = navigatorKey;
  await NotificacionesService.initializeFCM();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Geo Little Paws',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Montserrat',
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
        '/usuarios': (context) => const UsuariosPage(),
        '/animales': (context) => const AnimalesPage(),
        '/dispositivos': (context) => const DispositivosPage(),
        '/mapa': (context) => const MapaPage(),
      },
    );
  }
}

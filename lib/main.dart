import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/usuarios_page.dart';
import 'pages/animales_page.dart';
import 'pages/dispositivos_page.dart';
import 'pages/mapa_page.dart';


void main() {
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
      title: 'Geo Little Paws',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Montserrat',
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const HomePage(),
        '/usuarios': (context) => const UsuariosPage(),
        '/animales': (context) => const AnimalesPage(),
        '/dispositivos': (context) => const DispositivosPage(),
        '/mapa': (context) => const MapaPage(),
      },
    );
  }
}

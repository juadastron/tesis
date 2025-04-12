import 'package:flutter/material.dart';
import 'pages/login_page.dart'; // Asegúrate que el nombre coincida con tu archivo

void main() {
  runApp(const MyApp());
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
      home: const LoginScreen(), // <- Esta es tu pantalla de inicio
    );
  }
}

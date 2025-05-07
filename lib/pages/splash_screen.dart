import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../providers/user_provider.dart';
import 'home_page.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString('nombre');
    final email = prefs.getString('email');
    final rol = prefs.getString('rol');

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    Widget nextPage;

    if (nombre != null && email != null && rol != null) {
      userProvider.setUser(nombre: nombre, email: email, rol: rol);
      nextPage = const HomePage();
    } else {
      nextPage = const LoginScreen();
    }

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextPage),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false);
    final saludo = (user.nombre?.isNotEmpty ?? false)
        ? '¡Hola, ${user.nombre}!'
        : 'Bienvenido a';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7D4),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/patita.png', height: 100),
              const SizedBox(height: 20),
              Text(
                saludo,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Geo Little Paws',
                style: TextStyle(fontSize: 20, color: Color(0xFF6A1B9A)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

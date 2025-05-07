import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/splash_screen.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          // Fondo gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color(0xFFFFF7D4), // Tonos suaves de amarillo
                ],
              ),
            ),
          ),

          // Imagen decorativa en parte inferior derecha
          Positioned(
            bottom: 60,
            right: 40,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset('assets/images/patita.png', width: 110),
            ),
          ),
          Positioned(
            top: 70,
            left: 40,
            child: Opacity(
              opacity: 0.6,
              child: Image.asset('assets/images/patita.png', width: 110),
            ),
          ),

          // Contenido
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo circular
                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 241, 240, 201),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Image.asset('assets/images/fondo.png', height: 80),
                    ),
                    const SizedBox(height: 24),

                    // Título y subtítulo
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.paw,
                          color: Color.fromARGB(255, 70, 117, 192), // Púrpura
                          size: 26,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Geo Little Paws',
                          style: GoogleFonts.montserrat(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B9A), // Púrpura
                          ),
                        ),
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color.fromARGB(255, 70, 117, 192), // Púrpura
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Campo de correo electrónico
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Correo electrónico',
                        hintStyle: TextStyle(
                          color: const Color.fromARGB(255, 128, 128, 128),
                        ), // Gris oscuro para mayor contraste
                        prefixIcon: const SizedBox(
                          height: 48,
                          width: 48,
                          child: Center(
                            child: FaIcon(
                              FontAwesomeIcons.dog,
                              color: Color.fromARGB(
                                255,
                                70,
                                117,
                                192,
                              ), // Azul claro
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu correo';
                        }
                        if (!value.contains('@')) {
                          return 'Correo inválido';
                        }
                        return null;
                      },
                      onChanged: (value) => email = value.trim(),
                    ),
                    const SizedBox(height: 20),

                    // Campo de contraseña
                    TextFormField(
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Contraseña',
                        hintStyle: TextStyle(
                          color: const Color.fromARGB(255, 128, 128, 128),
                        ), // Gris oscuro para mayor contraste
                        prefixIcon: const SizedBox(
                          height: 48,
                          width: 48,
                          child: Center(
                            child: FaIcon(
                              FontAwesomeIcons.lock,
                              color: Color.fromARGB(
                                255,
                                70,
                                117,
                                192,
                              ), // Azul claro
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña';
                        }
                        return null;
                      },
                      onChanged: (value) => password = value,
                    ),
                    const SizedBox(height: 30),

                    // Botón "Ingresar"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await loginUsuario(
                              context,
                              email,
                              password,
                            );
                            if (success) {
                              final String nombre = user.nombre.toString();
                              final String email = user.email.toString();
                              final String rol = user.rol.toString();

                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('nombre', nombre);
                              await prefs.setString('email', email);
                              await prefs.setString('rol', rol);

                              user.setUser(
                                nombre: nombre,
                                email: email,
                                rol: rol,
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SplashScreen(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Correo o contraseña incorrectos',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6A1B9A), // Púrpura
                          shadowColor: Colors.black.withOpacity(
                            0.2,
                          ), // Sombra suave
                          elevation: 4, // Elevación para sombra
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Ingresar',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

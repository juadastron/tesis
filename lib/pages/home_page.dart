import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/usuario_model.dart';
import 'package:flutter_application_1/utils/notificador.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/animal_service.dart';
import '../models/animal_model.dart';
import '../pages/usuarios_page.dart' show editarUsuarioModal;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    final String? userRole = user.rol;

    final List<Map<String, dynamic>> drawerItems = [
      {
        'icon': FontAwesomeIcons.mapLocationDot,
        'text': 'Ubicación de animales',
        'route': '/mapa',
        'color': const Color(0xFF6A1B9A), // Morado
      },
      if (userRole == 'admin')
        {
          'icon': FontAwesomeIcons.user,
          'text': 'Usuarios',
          'route': '/usuarios',
          'color': const Color.fromRGBO(33, 150, 243, 1), // Azul
        },
      {
        'icon': FontAwesomeIcons.paw,
        'text': 'Animales',
        'route': '/animales',
        'color': const Color(0xFF6A1B9A), // Morado
      },
      {
        'icon': FontAwesomeIcons.microchip,
        'text': 'Collares',
        'route': '/dispositivos',
        'color': Colors.blue, // Azul
      },
      {
        'icon': FontAwesomeIcons.clockRotateLeft,
        'text': 'Historico de collares',
        'route': '/historialCollares',
        'color': const Color(0xFF6A1B9A), // Morado
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Geo Little Paws',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),

      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF6A1B9A)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 25,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.nombre ?? 'Usuario',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Geo Little Paws',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            ...drawerItems.map(
              (item) => _buildDrawerItem(
                context,
                icon: item['icon'],
                text: item['text'],
                route: item['route'],
                iconColor: item['color'],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.account_circle,
                color: Colors.deepPurple,
              ),
              title: Text(
                'Editar perfil',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                final usuarioLogueado = Usuario(
                  id: user.idUsuario!,
                  nombre: user.nombre ?? '',
                  email: user.email ?? '',
                  rol: user.rol ?? '',
                );

                Navigator.pop(
                  context,
                ); // Cierra el drawer ANTES de abrir el modal

                Future.delayed(const Duration(milliseconds: 200), () {
                  editarUsuarioModal(context, usuarioLogueado, () {
                    // Recarga si hace falta
                  });
                });
              },
            ),

            const Divider(),
            _buildDrawerItem(
              context,
              icon: Icons.logout,
              text: 'Cerrar sesión',
              iconColor: const Color.fromRGBO(33, 150, 243, 1), // Azul,
              onTap: () {
                Provider.of<UserProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),

      body: FutureBuilder<List<Animal>>(
        future: obtenerAnimales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar datos',
                style: GoogleFonts.montserrat(),
              ),
            );
          }

          final animales = snapshot.data ?? [];
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.fromARGB(255, 255, 255, 255), Color(0xFFFFF7D4)],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: 0.9,
                        child: Image.asset(
                          'assets/images/dormido.gif',
                          width: 200,
                          height: 200,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '¡Listos para cuidar a nuestros amigos peludos!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Protegiendo ${animales.length} peluditos',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/mapa');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.map, color: Colors.white),
                        label: Text(
                          'Ver mapa',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón de cerrar sesión en la esquina inferior izquierda
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: IconButton(
                      onPressed: () {
                        Provider.of<UserProvider>(
                          context,
                          listen: false,
                        ).logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      icon: const Icon(Icons.logout),
                      iconSize: 32,
                      color: Colors.blue,
                      tooltip: 'Cerrar sesión',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    String? route,
    VoidCallback? onTap,
    required Color iconColor,
  }) {
    return ListTile(
      leading: FaIcon(icon, color: iconColor),
      title: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap:
          onTap ??
          () {
            if (route != null) {
              Navigator.pop(context);
              Navigator.pushNamed(context, route);
            }
          },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    final String? userRole = user.rol;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Contenido principal
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.fromARGB(255, 255, 255, 255), Color(0xFFFFF7D4)],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _buildMenuItem(
                  context,
                  icon: FontAwesomeIcons.mapLocationDot,
                  label: 'Ver ubicación',
                  color: const Color(0xFF6A1B9A),
                  onTap: () {
                    Navigator.pushNamed(context, '/mapa');
                  },
                ),
                if (userRole == 'admin')
                  _buildMenuItem(
                    context,
                    icon: FontAwesomeIcons.user,
                    label: 'Usuarios',
                    color: const Color(0xFFBA68C8),
                    onTap: () {
                      Navigator.pushNamed(context, '/usuarios');
                    },
                  ),
                if (userRole == 'admin')
                  _buildMenuItem(
                    context,
                    icon: FontAwesomeIcons.paw,
                    label: 'Animales',
                    color: const Color(0xFFFFD54F),
                    onTap: () {
                      Navigator.pushNamed(context, '/animales');
                    },
                  ),
                if (userRole == 'admin')
                  _buildMenuItem(
                    context,
                    icon: FontAwesomeIcons.microchip,
                    label: 'Dispositivos',
                    color: const Color(0xFF42A5F5),
                    onTap: () {
                      Navigator.pushNamed(context, '/dispositivos');
                    },
                  ),
              ],
            ),
          ),

          // GIF en la parte inferior derecha
          Positioned(
            bottom: 0, // Distancia desde el borde inferior
            right: 0, // Distancia desde el borde derecho
            child: Opacity(
              opacity:
                  0.5, // Transparencia opcional para que no sea demasiado llamativo
              child: Image.asset(
                'assets/images/dormido.gif', // Ruta del GIF
                width: 150, // Tamaño del GIF
                height: 150,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Provider.of<UserProvider>(context, listen: false).logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.deepPurple, // Mismo color que el AppBar
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Cerrar sesión',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(icon, color: Colors.white, size: 36),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

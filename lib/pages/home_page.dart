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
  final String? userRole = user.rol; // Rol desde la API

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geo Little Paws'),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: Padding(
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
              color: Colors.deepPurple,
              onTap: () {
                Navigator.pushNamed(context, '/mapa');
              },
            ),
            if (userRole == 'admin')
              _buildMenuItem(
                context,
                icon: FontAwesomeIcons.user,
                label: 'Usuarios',
                color: Colors.teal,
                onTap: () {
                  Navigator.pushNamed(context, '/usuarios');
                },
              ),
            if (userRole == 'admin')
              _buildMenuItem(
                context,
                icon: FontAwesomeIcons.paw,
                label: 'Animales',
                color: Colors.orange,
                onTap: () {
                  Navigator.pushNamed(context, '/animales');
                },
              ),
            if (userRole == 'admin')
              _buildMenuItem(
                context,
                icon: FontAwesomeIcons.microchip,
                label: 'Dispositivos',
                color: Colors.indigo,
                onTap: () {
                  Navigator.pushNamed(context, '/dispositivos');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(2, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              color: Colors.white,
              size: 36,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

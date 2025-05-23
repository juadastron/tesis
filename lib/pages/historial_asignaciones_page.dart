import 'package:flutter/material.dart';
import '../services/asignacion_service.dart';
import '../models/asignacion_model.dart';
import 'package:google_fonts/google_fonts.dart';

class HistorialAsignacionesPage extends StatelessWidget {
  final int idDispositivo;

  const HistorialAsignacionesPage({super.key, required this.idDispositivo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Asignaciones', style: GoogleFonts.montserrat()),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: FutureBuilder<List<Asignacion>>(
        future: obtenerHistorialAsignaciones(idDispositivo),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error al cargar historial"));
          }

          final asignaciones = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: asignaciones.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final a = asignaciones[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text('Animal #${a.idAnimal}'),
                subtitle: Text(
                  'Inicio: ${a.fechaInicio}\nFin: ${a.fechaFin ?? "Actual"}',
                  style: GoogleFonts.montserrat(fontSize: 14),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

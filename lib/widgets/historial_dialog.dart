import 'package:flutter/material.dart';
import '../models/asignacion_model.dart';
import '../services/asignacion_service.dart';
import 'package:google_fonts/google_fonts.dart';

void mostrarHistorialAsignacionesDialog(
  BuildContext context,
  int idDispositivo,
) {
  showDialog(
    context: context,
    builder:
        (_) => Dialog(
          backgroundColor: const Color(0xFFF5F0FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: FutureBuilder<List<Asignacion>>(
            future: obtenerHistorialAsignaciones(idDispositivo),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'No hay historial disponible',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              final historial = snapshot.data!;

              return Container(
                width: 350,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Historial de Asignaciones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: historial.length,
                        itemBuilder: (context, index) {
                          final a = historial[index];
                          return ListTile(
                            leading: const Icon(
                              Icons.history,
                              color: Colors.deepPurple,
                            ),
                            title: Text(
                              '${a.nombreAnimal} (${a.especieAnimal})',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Inicio: ${a.fechaInicio}\nFin: ${a.fechaFin ?? "Actual"}',
                              style: GoogleFonts.montserrat(fontSize: 13),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cerrar"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
  );
}

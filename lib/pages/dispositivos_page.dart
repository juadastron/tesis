import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dispositivo_model.dart';
import '../services/dispositivo_service.dart';

class DispositivosPage extends StatefulWidget {
  const DispositivosPage({super.key});




  @override
  State<DispositivosPage> createState() => _DispositivosPageState();
}

class _DispositivosPageState extends State<DispositivosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dispositivos Registrados', style: GoogleFonts.montserrat()),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: const Color(0xFF6A1B9A),
      ),
      body: FutureBuilder<List<Dispositivo>>(
        future: obtenerDispositivos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.montserrat(),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No hay dispositivos registrados.',
                style: GoogleFonts.montserrat(),
              ),
            );
          }

          final dispositivos = snapshot.data!;

          return ListView.builder(
            itemCount: dispositivos.length,
            itemBuilder: (context, index) {
              final dispositivo = dispositivos[index];
              return ListTile(
                title: Text(
                  'IMEI: ${dispositivo.imei}',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado: ${dispositivo.estadoActual}',
                      style: GoogleFonts.montserrat(),
                    ),
                    if (dispositivo.estadoActual == 'asignado' &&
                        dispositivo.nombreAnimal != null)
                      Text(
                        'Asignado a: ${dispositivo.nombreAnimal} (${dispositivo.especieAnimal})',
                        style: GoogleFonts.montserrat(),
                      ),
                  ],
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () {
                        mostrarEditarDispositivo(context, dispositivo, () {
                          setState(() {});
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        if (dispositivo.estadoActual == 'asignado') {
                          // 🔥 Mostrar alerta elegante
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  'No se puede eliminar',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'Este dispositivo está asignado a un animal.\n\nDebes desvincularlo primero antes de eliminarlo.',
                                  style: GoogleFonts.montserrat(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Cancelar',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                      ); // Cerrar la alerta
                                      Navigator.pushNamed(
                                        context,
                                        '/animales',
                                      ); // 🔥 Ir a Animales
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6A1B9A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Text(
                                      'Ir a Animales',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text('Confirmar'),
                                  content: const Text(
                                    '¿Deseas eliminar este dispositivo?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(ctx, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm == true) {
                            final eliminado = await eliminarDispositivo(
                              dispositivo.id!,
                            );
                            if (eliminado) {
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error al eliminar',
                                    style: GoogleFonts.montserrat(),
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6A1B9A),
        onPressed: () {
          mostrarCrearDispositivo(context, () {
            setState(() {});
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// 🔵 Modal para crear dispositivo
void mostrarCrearDispositivo(BuildContext context, VoidCallback onCrear) {
  final imeiController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text('Nuevo Dispositivo', style: GoogleFonts.montserrat()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: imeiController,
              decoration: InputDecoration(
                labelText: 'IMEI',
                labelStyle: GoogleFonts.montserrat(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: GoogleFonts.montserrat()),
          ),
          ElevatedButton(
            onPressed: () async {
              final creado = await crearDispositivo(
                Dispositivo(
                  imei: imeiController.text,
                  estadoActual: 'disponible', // 🔥 Por defecto DISPONIBLE
                ),
              );
              if (creado) {
                Navigator.pop(ctx);
                onCrear();
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error al crear',
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                );
              }
            },
            child: Text('Guardar', style: GoogleFonts.montserrat()),
          ),
        ],
      );
    },
  );
}

// 🟣 Modal para editar dispositivo
void mostrarEditarDispositivo(
  BuildContext context,
  Dispositivo dispositivo,
  VoidCallback onUpdate,
) {
  final imeiController = TextEditingController(text: dispositivo.imei);
  final estadoController = TextEditingController(
    text: dispositivo.estadoActual,
  );

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text('Editar Dispositivo', style: GoogleFonts.montserrat()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: imeiController,
              decoration: InputDecoration(
                labelText: 'IMEI',
                labelStyle: GoogleFonts.montserrat(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: GoogleFonts.montserrat()),
          ),
          ElevatedButton(
            onPressed: () async {
              final actualizado = await actualizarDispositivo(
                Dispositivo(
                  id: dispositivo.id,
                  imei: imeiController.text,
                  estadoActual: estadoController.text,
                ),
              );
              if (actualizado) {
                Navigator.pop(ctx);
                onUpdate();
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error al actualizar',
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                );
              }
            },
            child: Text('Guardar', style: GoogleFonts.montserrat()),
          ),
        ],
      );
    },
  );
}

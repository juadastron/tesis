import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/asignacion_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/animal_model.dart';
import '../services/animal_service.dart';
import '../services/dispositivo_service.dart'; // donde esté tu método obtenerDispositivosDisponibles()
import '../models/dispositivo_model.dart'; // tu modelo de dispositivo

class AnimalesPage extends StatefulWidget {
  const AnimalesPage({super.key});

  @override
  State<AnimalesPage> createState() => _AnimalesPageState();
}

class _AnimalesPageState extends State<AnimalesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animales Registrados', style: GoogleFonts.montserrat()),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: FutureBuilder<List<Animal>>(
        future: obtenerAnimales(),
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
                'No hay animales registrados.',
                style: GoogleFonts.montserrat(),
              ),
            );
          }

          final animales = snapshot.data!;

          return ListView.builder(
            itemCount: animales.length,
            itemBuilder: (context, index) {
              final animal = animales[index];
              return ListTile(
                title: Text(
                  animal.nombre,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${animal.especie} | Edad: ${animal.edad ?? "N/D"} | Color: ${animal.color ?? "N/D"}',
                  style: GoogleFonts.montserrat(),
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.link, color: Colors.green),
                      tooltip: 'Asignar dispositivo',
                      onPressed: () {
                        mostrarAsignarDispositivo(
                          context,
                          animal.id!,
                        ); // 👈 Función que crearemos
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () {
                        mostrarEditarAnimal(context, animal, () {
                          setState(() {});
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: Text(
                                  'Confirmar',
                                  style: GoogleFonts.montserrat(),
                                ),
                                content: Text(
                                  '¿Deseas eliminar este animal?',
                                  style: GoogleFonts.montserrat(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(
                                      'Cancelar',
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(
                                      'Eliminar',
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          final eliminado = await eliminarAnimal(animal.id!);
                          if (eliminado) {
                            setState(() {});
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Error al eliminar",
                                  style: GoogleFonts.montserrat(),
                                ),
                              ),
                            );
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
          mostrarCrearAnimal(context, () {
            setState(() {});
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// FORMULARIOS
void mostrarAsignarDispositivo(BuildContext context, int idAnimal) {
  Dispositivo? dispositivoSeleccionado;

  showDialog(
    context: context,
    builder: (ctx) {
      return FutureBuilder<List<Dispositivo>>(
        future: obtenerDispositivosDisponibles(), // debe retornar solo los disponibles
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: Text('Error', style: GoogleFonts.montserrat()),
              content: Text('No se pudieron cargar los dispositivos.', style: GoogleFonts.montserrat()),
            );
          }

          final dispositivos = snapshot.data ?? [];

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Asignar dispositivo', style: GoogleFonts.montserrat()),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Dispositivo>(
                      decoration: InputDecoration(
                        labelText: 'Selecciona un dispositivo',
                        labelStyle: GoogleFonts.montserrat(),
                      ),
                      value: dispositivoSeleccionado,
                      items: dispositivos.map((dispositivo) {
                        return DropdownMenuItem(
                          value: dispositivo,
                          child: Text('IMEI: ${dispositivo.imei}', style: GoogleFonts.montserrat()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          dispositivoSeleccionado = value;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar', style: GoogleFonts.montserrat()),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (dispositivoSeleccionado == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Debes seleccionar un dispositivo', style: GoogleFonts.montserrat()),
                          ),
                        );
                        return;
                      }

                      final exito = await asignarDispositivoAnimal(idAnimal, dispositivoSeleccionado!.id!);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            exito ? 'Dispositivo asignado correctamente' : 'Error al asignar dispositivo',
                            style: GoogleFonts.montserrat(),
                          ),
                        ),
                      );
                    },
                    child: Text('Asignar', style: GoogleFonts.montserrat()),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}


void mostrarCrearAnimal(BuildContext context, VoidCallback onCrear) {
  final nombreController = TextEditingController();
  final especieController = TextEditingController();
  final edadController = TextEditingController();
  final colorController = TextEditingController();

  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: Text('Nuevo Animal', style: GoogleFonts.montserrat()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre",
                  labelStyle: GoogleFonts.montserrat(),
                ),
              ),
              TextField(
                controller: especieController,
                decoration: InputDecoration(
                  labelText: "Especie",
                  labelStyle: GoogleFonts.montserrat(),
                ),
              ),
              TextField(
                controller: edadController,
                decoration: InputDecoration(
                  labelText: "Edad",
                  labelStyle: GoogleFonts.montserrat(),
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: colorController,
                decoration: InputDecoration(
                  labelText: "Color",
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
                final creado = await crearAnimal(
                  Animal(
                    nombre: nombreController.text,
                    especie: especieController.text,
                    edad: int.tryParse(edadController.text),
                    color: colorController.text,
                  ),
                );

                if (creado) {
                  Navigator.pop(ctx);
                  onCrear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Error al crear",
                        style: GoogleFonts.montserrat(),
                      ),
                    ),
                  );
                }
              },
              child: Text("Guardar", style: GoogleFonts.montserrat()),
            ),
          ],
        ),
  );
}

void mostrarEditarAnimal(
  BuildContext context,
  Animal animal,
  VoidCallback onUpdate,
) {
  final nombreController = TextEditingController(text: animal.nombre);
  final especieController = TextEditingController(text: animal.especie);
  final edadController = TextEditingController(
    text: animal.edad?.toString() ?? '',
  );
  final colorController = TextEditingController(text: animal.color ?? '');

  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: Text('Editar Animal', style: GoogleFonts.montserrat()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre",
                  labelStyle: GoogleFonts.montserrat(),
                ),
              ),
              TextField(
                controller: especieController,
                decoration: InputDecoration(
                  labelText: "Especie",
                  labelStyle: GoogleFonts.montserrat(),
                ),
              ),
              TextField(
                controller: edadController,
                decoration: InputDecoration(
                  labelText: "Edad",
                  labelStyle: GoogleFonts.montserrat(),
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: colorController,
                decoration: InputDecoration(
                  labelText: "Color",
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
                final actualizado = await actualizarAnimal(
                  Animal(
                    id: animal.id,
                    nombre: nombreController.text,
                    especie: especieController.text,
                    edad: int.tryParse(edadController.text),
                    color: colorController.text,
                  ),
                );

                if (actualizado) {
                  Navigator.pop(ctx);
                  onUpdate();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Error al actualizar",
                        style: GoogleFonts.montserrat(),
                      ),
                    ),
                  );
                }
              },
              child: Text("Guardar", style: GoogleFonts.montserrat()),
            ),
          ],
        ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/asignacion_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/animal_model.dart';
import '../services/animal_service.dart';
import '../services/dispositivo_service.dart';
import '../models/dispositivo_model.dart';

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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: const Color(0xFF6A1B9A),
      ),
      body: FutureBuilder<List<Animal>>(
        future: obtenerAnimales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: \${snapshot.error}',
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

              return FutureBuilder<Map<String, dynamic>?>(
                future: obtenerAsignacionAnimal(animal.id!),
                builder: (context, asignacionSnapshot) {
                  final asignacion = asignacionSnapshot.data;

                  return ListTile(
                    title: Text(
                      animal.nombre,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.pets,
                              size: 16,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Especie: ${animal.especie}',
                              style: GoogleFonts.montserrat(fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.cake,
                              size: 16,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Edad: ${animal.edad ?? "N/D"}',
                              style: GoogleFonts.montserrat(fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.palette,
                              size: 16,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Color: ${animal.color ?? "N/D"}',
                              style: GoogleFonts.montserrat(fontSize: 13),
                            ),
                          ],
                        ),
                        if (asignacion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Collar:',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.perm_device_info,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'IMEI: ${asignacion["imei"]}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.date_range,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Desde: ${asignacion["fecha_inicio"].toString().split(" ")[0]}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon:
                              asignacion == null
                                  ? const Icon(Icons.link, color: Colors.green)
                                  : const Icon(
                                    Icons.link_off,
                                    color: Colors.redAccent,
                                  ),
                          tooltip:
                              asignacion == null
                                  ? 'Asignar dispositivo'
                                  : 'Desvincular dispositivo',
                          onPressed: () async {
                            if (asignacion == null) {
                              mostrarAsignarDispositivo(context, animal.id!);
                            } else {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      title: Text(
                                        'Desvincular Collar',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                      content: Text(
                                        '¿Deseas desvincular el dispositivo de este animal?',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(ctx, false),
                                          child: Text(
                                            'Cancelar',
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF6A1B9A,
                                            ),
                                          ),
                                          onPressed:
                                              () => Navigator.pop(ctx, true),
                                          child: Text(
                                            'Desvincular',
                                            style: GoogleFonts.montserrat(color:Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                              );

                              if (confirm == true) {
                                final exito =
                                    await desvincularDispositivoAnimal(
                                      asignacion["id_asignacion"],
                                    );
                                if (exito) {
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Collar desvinculado correctamente',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error al desvincular',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
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
                                      'Eliminar Animal',
                                      style: GoogleFonts.montserrat(),
                                    ),
                                    content: Text(
                                      '¿Deseas eliminar este animal?',
                                      style: GoogleFonts.montserrat(),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(ctx, false),
                                        child: Text(
                                          'Cancelar',
                                          style: GoogleFonts.montserrat(),
                                        ),
                                      ),

                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(
                                            244,
                                            67,
                                            54,
                                            1,
                                          ),
                                        ),
                                        onPressed:
                                            () => Navigator.pop(ctx, true),
                                        child: Text(
                                          'Eliminar',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirm == true) {
                              final eliminado = await eliminarAnimal(
                                animal.id!,
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
                          },
                        ),
                      ],
                    ),
                  );
                },
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

  // FORMULARIOS
  void mostrarAsignarDispositivo(BuildContext context, int idAnimal) {
    Dispositivo? dispositivoSeleccionado;

    showDialog(
      context: context,
      builder: (ctx) {
        return FutureBuilder<List<Dispositivo>>(
          future: obtenerDispositivos(), // debe retornar solo los disponibles
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text('Error', style: GoogleFonts.montserrat()),
                content: Text(
                  'No se pudieron cargar los dispositivos.',
                  style: GoogleFonts.montserrat(),
                ),
              );
            }
            final disponibles =
                (snapshot.data ?? [])
                    .where((d) => d.estadoActual == 'disponible')
                    .toList();

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(
                    'Asignar dispositivo',
                    style: GoogleFonts.montserrat(),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<Dispositivo>(
                        decoration: InputDecoration(
                          labelText: 'Selecciona un dispositivo',
                          labelStyle: GoogleFonts.montserrat(),
                        ),
                        value: dispositivoSeleccionado,
                        items:
                            disponibles.map((dispositivo) {
                              return DropdownMenuItem(
                                value: dispositivo,
                                child: Text(
                                  'IMEI: ${dispositivo.imei}',
                                  style: GoogleFonts.montserrat(),
                                ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                      ),
                      onPressed: () async {
                        if (dispositivoSeleccionado == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Debes seleccionar un dispositivo',
                                style: GoogleFonts.montserrat(),
                              ),
                            ),
                          );
                          return;
                        }

                        final exito = await asignarDispositivoAnimal(
                          idAnimal,
                          dispositivoSeleccionado!.id!,
                        );
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              exito
                                  ? 'Dispositivo asignado correctamente'
                                  : 'Error al asignar dispositivo',
                              style: GoogleFonts.montserrat(),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Asignar',
                        style: GoogleFonts.montserrat(color: Colors.white),
                      ),
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
      barrierDismissible: false,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            backgroundColor: const Color(0xFFF8F5F9),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nuevo Animal',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nombreController,
                    decoration: InputDecoration(
                      labelText: "Nombre",
                      labelStyle: GoogleFonts.montserrat(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6A1B9A)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF6A1B9A),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: especieController,
                    decoration: InputDecoration(
                      labelText: "Especie",
                      labelStyle: GoogleFonts.montserrat(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6A1B9A)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF6A1B9A),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: edadController,
                    decoration: InputDecoration(
                      labelText: "Edad",
                      labelStyle: GoogleFonts.montserrat(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6A1B9A)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF6A1B9A),
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: colorController,
                    decoration: InputDecoration(
                      labelText: "Color",
                      labelStyle: GoogleFonts.montserrat(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6A1B9A)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF6A1B9A),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.montserrat(
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
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
                        child: Text(
                          "Guardar",
                          style: GoogleFonts.montserrat(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
      barrierDismissible: false,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            backgroundColor: const Color(0xFFF8F5F9),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Editar Animal',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nombreController,
                    decoration: InputDecoration(
                      labelText: "Nombre",
                      labelStyle: GoogleFonts.montserrat(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6A1B9A)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF6A1B9A),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: especieController,
                    decoration: InputDecoration(
                      labelText: "Especie",
                      labelStyle: GoogleFonts.montserrat(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6A1B9A)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF6A1B9A),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: edadController,
                    decoration: InputDecoration(
                      labelText: "Edad",
                      labelStyle: GoogleFonts.montserrat(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6A1B9A)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF6A1B9A),
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: colorController,
                    decoration: InputDecoration(
                      labelText: "Color",
                      labelStyle: GoogleFonts.montserrat(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6A1B9A)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF6A1B9A),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.montserrat(
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
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
                        child: Text(
                          "Guardar",
                          style: GoogleFonts.montserrat(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

// Todo el contenido original se mantiene. Solo modificamos las etiquetas visuales.
// Etiquetas estilo: icono + texto en una burbuja redondeada gris clara

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/asignacion_service.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/utils/notificador.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/animal_model.dart';
import '../services/animal_service.dart';
import '../services/dispositivo_service.dart';
import '../models/dispositivo_model.dart';
import '../utils/validadores.dart';

class AnimalesPage extends StatefulWidget {
  const AnimalesPage({super.key});

  @override
  State<AnimalesPage> createState() => _AnimalesPageState();
}

class _AnimalesPageState extends State<AnimalesPage> {
  late UserProvider userProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }

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
                        if (userProvider.rol == 'admin')
                          IconButton(
                            icon:
                                asignacion == null
                                    ? const Icon(
                                      Icons.link,
                                      color: Colors.green,
                                    )
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
                                              style: GoogleFonts.montserrat(
                                                color: Colors.white,
                                              ),
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
                        if (userProvider.rol == 'admin')
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              mostrarEditarAnimal(context, animal, () {
                                setState(() {});
                              });
                            },
                          ),
                        if (userProvider.rol == 'admin')
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
                                            backgroundColor: Colors.red,
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
            // Esta función anónima se ejecuta solo si se creó exitosamente el animal
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
                title: Text(
                  'Error: ${snapshot.error}',
                  style: GoogleFonts.montserrat(),
                ),
                content: Text(
                  'No se pudieron cargar los dispositivos.',
                  style: GoogleFonts.montserrat(),
                ),
              );
            }
            final disponibles =
                (snapshot.data ?? [])
                    .where(
                      (d) =>
                          d.estadoActual == 'disponible' ||
                          d.estadoActual == 'inactivo',
                    )
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
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final especieController = TextEditingController();
    final edadController = TextEditingController();
    final colorController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, _) {
        final curvedValue = Curves.easeInOut.transform(anim1.value);
        return Transform.scale(
          scale: curvedValue,
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              backgroundColor: const Color(0xFFF8F5F9),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
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

                        campoBurbuja(
                          label: "Nombre",
                          controller: nombreController,
                          icon: Icons.pets,
                          validator: validarNombre,
                          colorIndex: 0,
                        ),
                        campoBurbuja(
                          label: "Especie",
                          controller: especieController,
                          icon: Icons.category,
                          validator: validarNombre,
                          colorIndex: 1,
                        ),
                        campoBurbuja(
                          label: "Edad",
                          controller: edadController,
                          icon: Icons.cake,
                          keyboardType: TextInputType.number,
                          validator: validarNumeros,
                          colorIndex: 2,
                        ),
                        campoBurbuja(
                          label: "Color",
                          controller: colorController,
                          icon: Icons.palette,
                          validator: validarNombre,
                          colorIndex: 1,
                        ),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
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
                                if (!formKey.currentState!.validate()) return;
                                final creado = await crearAnimal(
                                  Animal(
                                    nombre: nombreController.text,
                                    especie: especieController.text,
                                    edad: int.tryParse(edadController.text),
                                    color: colorController.text,
                                  ),
                                );
                                if (creado) {
                                  Navigator.pop(context);
                                  Notificador.mostrar(
                                    context: context,
                                    mensaje: "Animal creado con éxito",
                                    tipo: TipoNotificacion.success,
                                  );
                                  onCrear();
                                } else {
                                  FocusScope.of(context).unfocus();
                                  Notificador.mostrar(
                                    context: context,
                                    mensaje: "Error al crear el animal",
                                    tipo: TipoNotificacion.error,
                                  );
                                }
                              },
                              child: Text(
                                "Guardar",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void mostrarEditarAnimal(
    BuildContext context,
    Animal animal,
    VoidCallback onUpdate,
  ) {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: animal.nombre);
    final especieController = TextEditingController(text: animal.especie);
    final edadController = TextEditingController(
      text: animal.edad?.toString() ?? '',
    );
    final colorController = TextEditingController(text: animal.color ?? '');

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Editar Animal',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (context, animation, _, __) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: Dialog(
            backgroundColor: const Color(0xFFF5F0FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
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
                      campoBurbuja(
                        label: "Nombre",
                        controller: nombreController,
                        icon: Icons.pets,
                        validator: validarNombre,
                        colorIndex: 1,
                      ),
                      campoBurbuja(
                        label: "Especie",
                        controller: especieController,
                        icon: Icons.pets_outlined,
                        validator: validarNombre,
                        colorIndex: 0,
                      ),
                      campoBurbuja(
                        label: "Edad",
                        controller: edadController,
                        icon: Icons.cake,
                        keyboardType: TextInputType.number,
                        validator: validarNumeros,
                        colorIndex: 2,
                      ),
                      campoBurbuja(
                        label: "Color",
                        controller: colorController,
                        icon: Icons.color_lens,
                        validator: validarNombre,
                        colorIndex: 1,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancelar',
                              style: GoogleFonts.montserrat(
                                color: Color(0xFF6A1B9A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              final actualizado = await actualizarAnimal(
                                Animal(
                                  id: animal.id,
                                  nombre: nombreController.text,
                                  especie: especieController.text,
                                  edad: int.tryParse(edadController.text),
                                  color: colorController.text,
                                ),
                              );
                              Navigator.pop(context);
                              if (actualizado) {
                                onUpdate();
                                Notificador.mostrar(
                                  context: context,
                                  mensaje: "Animal actualizado con éxito",
                                  tipo: TipoNotificacion.success,
                                );
                              } else {
                                Notificador.mostrar(
                                  context: context,
                                  mensaje: "Error al actualizar",
                                  tipo: TipoNotificacion.error,
                                );
                              }
                            },
                            child: Text(
                              "Guardar",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget campoBurbuja({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int colorIndex = 0, // <- índice para alternar colores
  }) {
    final List<Color> colores = [
      const Color.fromRGBO(33, 150, 243, 1), // Azul
      const Color(0xFF6A1B9A), // Morado
      const Color.fromARGB(255, 214, 211, 151), // Amarillo
    ];
    final iconColor = colores[colorIndex % colores.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFFA),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: iconColor),
          border: InputBorder.none,
          labelStyle: GoogleFonts.montserrat(),
        ),
      ),
    );
  }
}

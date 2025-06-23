// Todo el contenido original se mantiene. Solo modificamos las etiquetas visuales.
// Etiquetas estilo: icono + texto en una burbuja redondeada gris clara

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/services/asignacion_service.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/utils/notificador.dart';
import 'package:flutter_application_1/widgets/solo_admin.dart';
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
  bool _cargando = true;
  List<Animal> _todosLosAnimales = [];
  List<Animal> _animalesFiltrados = [];
  final TextEditingController _busquedaController = TextEditingController();
  late UserProvider userProvider;

  Future<void> _cargarAnimales() async {
    final lista = await obtenerAnimales();
    setState(() {
      _todosLosAnimales = lista;
      _animalesFiltrados = lista;
      _cargando = false;
    });
  }

  void _filtrarAnimales(String query) {
    final input = query.toLowerCase();
    setState(() {
      _animalesFiltrados =
          _todosLosAnimales
              .where((animal) => animal.nombre.toLowerCase().contains(input))
              .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _busquedaController.addListener(() {
      _filtrarAnimales(_busquedaController.text);
    });
    _cargarAnimales();
  }

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
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6A1B9A),
      ),
      body:
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _busquedaController,
                      decoration: InputDecoration(
                        hintText: "Buscar por nombre...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF6A1B9A),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F5F9),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFF6A1B9A),
                            width: 2,
                          ),
                        ),
                      ),
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                  Expanded(
                    child:
                        _animalesFiltrados.isEmpty
                            ? Center(
                              child: Text(
                                'No hay animales registrados.',
                                style: GoogleFonts.montserrat(),
                              ),
                            )
                            : ListView.builder(
                              itemCount: _animalesFiltrados.length,
                              itemBuilder: (context, index) {
                                final animal = _animalesFiltrados[index];
                                return FutureBuilder<Map<String, dynamic>?>(
                                  future: obtenerAsignacionAnimal(animal.id!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {}
                                    final asignacion = snapshot.data;
                                    return _buildAnimalTile(animal, asignacion);
                                  },
                                );
                              },
                            ),
                  ),
                ],
              ),
      floatingActionButton: SoloAdmin(
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF6A1B9A),
          onPressed: () {
            mostrarCrearAnimal(context, () => _cargarAnimales());
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // FORMULARIOS
  void mostrarAsignarDispositivo(
    BuildContext context,
    int idAnimal,
    VoidCallback onCargar,
  ) {
    Dispositivo? dispositivoSeleccionado;

    showDialog(
      context: context,
      builder: (ctx) {
        return FutureBuilder<List<Dispositivo>>(
          future:
              obtenerDispositivosDisponibles(), // debe retornar solo los disponibles
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
            final disponibles = snapshot.data ?? [];
            print("DISPOSITIVOS DISPONIBLES:");
            for (var d in disponibles) {
              print("ID: ${d.id}, IMEI: ${d.imei}, Estado: ${d.estadoActual}");
            }
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
                        onCargar();
                        Navigator.pop(context);
                        Notificador.mostrar(
                          context: context,
                          mensaje:
                              exito
                                  ? "Dispositivo asignado correctamente"
                                  : "Error al asignar dispositivo",
                          tipo:
                              exito
                                  ? TipoNotificacion.success
                                  : TipoNotificacion.error,
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

  Widget _buildAnimalTile(Animal animal, Map<String, dynamic>? asignacion) {
    return ListTile(
      title: Text(
        animal.nombre,
        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.pets, size: 16, color: Colors.deepPurple),
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
              const Icon(Icons.cake, size: 16, color: Colors.deepPurple),
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
              const Icon(Icons.palette, size: 16, color: Colors.deepPurple),
              const SizedBox(width: 6),
              Text(
                'Color: ${animal.color ?? "N/D"}',
                style: GoogleFonts.montserrat(fontSize: 13),
              ),
            ],
          ),
          if (asignacion != null &&
              asignacion["imei"] != null &&
              asignacion["fecha_inicio"] != null) ...[
            const SizedBox(height: 4),
            Text(
              'Collar:',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                    style: GoogleFonts.montserrat(fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.date_range, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Desde: ${asignacion["fecha_inicio"].toString().split(" ")[0]}',
                    style: GoogleFonts.montserrat(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      trailing: _buildAcciones(animal, asignacion),
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
                          context: context,
                          label: "Nombre",
                          controller: nombreController,
                          icon: Icons.pets,
                          validator: validarNombre,
                          colorIndex: 0,
                          maxLength: 7,
                        ),
                        campoBurbuja(
                          context: context,
                          label: "Especie",
                          controller: especieController,
                          icon: Icons.category,
                          validator: validarNombre,
                          colorIndex: 1,
                          maxLength: 7,
                        ),
                        campoBurbuja(
                          context: context,
                          label: "Edad",
                          controller: edadController,
                          icon: Icons.cake,
                          keyboardType: TextInputType.number,
                          validator: validarNumeros,
                          colorIndex: 2,
                          maxLength: 3,
                        ),
                        campoBurbuja(
                          context: context,
                          label: "Color",
                          controller: colorController,
                          icon: Icons.palette,
                          validator: validarNombre,
                          colorIndex: 1,
                          maxLength: 7,
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
                        context: context,
                        label: "Nombre",
                        controller: nombreController,
                        icon: Icons.pets,
                        validator: validarNombre,
                        colorIndex: 1,
                        maxLength: 10,
                      ),
                      campoBurbuja(
                        context: context,
                        label: "Especie",
                        controller: especieController,
                        icon: Icons.pets_outlined,
                        validator: validarNombre,
                        colorIndex: 0,
                        maxLength: 10,
                      ),
                      campoBurbuja(
                        context: context,
                        label: "Edad",
                        controller: edadController,
                        icon: Icons.cake,
                        keyboardType: TextInputType.number,
                        validator: validarNumeros,
                        colorIndex: 2,
                        maxLength: 3,
                      ),
                      campoBurbuja(
                        context: context,
                        label: "Color",
                        controller: colorController,
                        icon: Icons.color_lens,
                        validator: validarNombre,
                        colorIndex: 1,
                        maxLength: 6,
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

  Widget _buildAcciones(Animal animal, Map<String, dynamic>? asignacion) {
    final tieneAsignacionValida =
        asignacion != null &&
        asignacion["imei"] != null &&
        asignacion["fecha_inicio"] != null;

    return SoloAdmin(
      child: Wrap(
        spacing: 8,
        children: [
          IconButton(
            icon: Icon(
              tieneAsignacionValida ? Icons.link_off : Icons.link,
              color: tieneAsignacionValida ? Colors.redAccent : Colors.green,
            ),
            tooltip:
                tieneAsignacionValida
                    ? 'Desvincular dispositivo'
                    : 'Asignar dispositivo',
            onPressed: () async {
              if (!tieneAsignacionValida) {
                mostrarAsignarDispositivo(
                  context,
                  animal.id!,
                  () => setState(() {}),
                );
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
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(
                              'Cancelar',
                              style: GoogleFonts.montserrat(),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
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
                  final idAsignacion = asignacion["id_asignacion"];
                  if (idAsignacion == null) {
                    Notificador.mostrar(
                      context: context,
                      mensaje: "Este collar no tiene asignación activa",
                      tipo: TipoNotificacion.error,
                    );
                    return;
                  }
                  final exito = await desvincularDispositivoAnimal(
                    idAsignacion,
                  );
                  if (exito) {
                    setState(() {});
                    Notificador.mostrar(
                      context: context,
                      mensaje: "Dispositivo desvinculado exitosamente",
                      tipo: TipoNotificacion.success,
                    );
                  } else {
                    Notificador.mostrar(
                      context: context,
                      mensaje: "No se pudo desvincular",
                      tipo: TipoNotificacion.error,
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
                _cargarAnimales(); // 👈 Recarga desde la API los animales actualizados
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final tieneDispositivoAsignado =
                  asignacion != null && asignacion["imei"] != null;
              if (tieneDispositivoAsignado) {
                Notificador.mostrar(
                  context: context,
                  mensaje:
                      "Debes desvincular el collar antes de eliminar el animal",
                  tipo: TipoNotificacion.error,
                );
                return;
              }
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
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.montserrat(),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            'Eliminar',
                            style: GoogleFonts.montserrat(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                final eliminado = await eliminarAnimal(animal.id!);
                if (eliminado) {
                  setState(() {});
                  Notificador.mostrar(
                    context: context,
                    mensaje: "Animal eliminado",
                    tipo: TipoNotificacion.success,
                  );
                } else {
                  Notificador.mostrar(
                    context: context,
                    mensaje: "Error: no se pudo eliminar el animal",
                    tipo: TipoNotificacion.error,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // Asegúrate de importar esto

  Widget campoBurbuja({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int colorIndex = 0,
    int maxLength = 50, // <-- parámetro opcional agregado
  }) {
    final List<Color> colores = [
      const Color.fromRGBO(33, 150, 243, 1),
      const Color(0xFF6A1B9A),
      const Color.fromARGB(255, 214, 211, 151),
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
        inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: iconColor),
          border: InputBorder.none,
          labelStyle: GoogleFonts.montserrat(),
          counterText: '', // <-- Oculta el contador por defecto
        ),
        onChanged: (value) {
          if (value.length > maxLength) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Máximo 7 caracteres permitidos'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
      ),
    );
  }
}

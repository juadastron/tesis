// Todo el contenido original se mantiene. Solo modificamos las etiquetas visuales.
// Etiquetas estilo: icono + texto en una burbuja redondeada gris clara

import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/dispositivo_model.dart';
import '../services/dispositivo_service.dart';
import '../services/permisos_service.dart';

class DispositivosPage extends StatefulWidget {
  const DispositivosPage({super.key});

  @override
  State<DispositivosPage> createState() => _DispositivosPageState();
}

class _DispositivosPageState extends State<DispositivosPage> {
  late UserProvider userProvider;
  final numeroCelularController = TextEditingController();
  List<Dispositivo> todosLosDispositivos = [];
  List<Dispositivo> dispositivosFiltrados = [];
  TextEditingController searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    cargarDispositivos();
  }

  Future<void> cargarDispositivos() async {
    final lista = await obtenerDispositivos();
    setState(() {
      todosLosDispositivos = lista;
      dispositivosFiltrados = lista;
    });
  }

  void filtrarDispositivos(String query) {
    final filtrados =
        todosLosDispositivos.where((dispositivo) {
          final imei = dispositivo.imei.toLowerCase();
          final input = query.toLowerCase();
          return imei.contains(input);
        }).toList();

    setState(() {
      dispositivosFiltrados = filtrados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dispositivos Registrados',
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: const Color(0xFF6A1B9A),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: filtrarDispositivos,
              style: GoogleFonts.montserrat(),
              decoration: InputDecoration(
                hintText: 'Buscar por IMEI...',
                hintStyle: GoogleFonts.montserrat(),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                dispositivosFiltrados.isEmpty
                    ? Center(
                      child: Text(
                        'No hay dispositivos registrados.',
                        style: GoogleFonts.montserrat(),
                      ),
                    )
                    : ListView.builder(
                      itemCount: dispositivosFiltrados.length,
                      itemBuilder: (context, index) {
                        final dispositivo = dispositivosFiltrados[index];
                        return ListTile(
                          title: Text(
                            'IMEI: ${dispositivo.imei}',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              _buildEtiquetaEstado(dispositivo.estadoActual),
                              if ([
                                    'asignado',
                                    'peligro',
                                    'inactividad',
                                  ].contains(dispositivo.estadoActual) &&
                                  dispositivo.nombreAnimal != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: _buildEtiquetaIcono(
                                    icono: Icons.pets,
                                    texto:
                                        'Asignado a: ${dispositivo.nombreAnimal} (${dispositivo.especieAnimal})',
                                  ),
                                ),
                              if (dispositivo.numeroCelular != null &&
                                  dispositivo.numeroCelular!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: _buildEtiquetaIcono(
                                    icono: Icons.phone_android,
                                    texto:
                                        '# celular: ${dispositivo.numeroCelular}',
                                    color: Colors.indigo,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Wrap(
                            spacing: 4, // espacio entre íconos
                            children: [
                              FutureBuilder<bool>(
                                future: PermisosService.verificarPermisoEdicion(
                                  userProvider.idUsuario!,
                                  dispositivo.id!,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState !=
                                      ConnectionState.done) {
                                    return const SizedBox.shrink(); // mientras carga
                                  }

                                  if (snapshot.hasData &&
                                      snapshot.data == true) {
                                    return Wrap(
                                      spacing: 4,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.settings,
                                            color: Colors.deepPurple,
                                          ),
                                          tooltip: 'Configurar',
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/configuracion',
                                              arguments: {
                                                'idDispositivo': dispositivo.id,
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.orange,
                                          ),
                                          tooltip: 'Editar',
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () {
                                            mostrarEditarDispositivo(
                                              context,
                                              dispositivo,
                                              () {
                                                cargarDispositivos();
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          tooltip: 'Eliminar',
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () async {
                                            if (dispositivo.estadoActual != 'disponible') {
                                              await showDialog(
                                                context: context,
                                                builder:
                                                    (ctx) => AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      title: const Text(
                                                        'No se puede eliminar',
                                                      ),
                                                      content: const Text(
                                                        'Este dispositivo está asignado a un animal.\n\nDebes desvincularlo primero antes de eliminarlo.',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    ctx,
                                                                  ),
                                                          child: const Text(
                                                            'Cancelar',
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(ctx);
                                                            Navigator.pushNamed(
                                                              context,
                                                              '/animales',
                                                            );
                                                          },
                                                          style:
                                                              ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    const Color(
                                                                      0xFF6A1B9A,
                                                                    ),
                                                              ),
                                                          child: const Text(
                                                            'Ir a Animales',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                            } else {
                                              final confirmar = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (ctx) => AlertDialog(
                                                      title: const Text(
                                                        '¿Confirmar eliminación?',
                                                      ),
                                                      content: const Text(
                                                        '¿Estás seguro de que deseas eliminar este dispositivo?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    ctx,
                                                                    false,
                                                                  ),
                                                          child: const Text(
                                                            'Cancelar',
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          style:
                                                              ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    ctx,
                                                                    true,
                                                                  ),
                                                          child: const Text(
                                                            'Eliminar',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );

                                              if (confirmar == true) {
                                                final ok =
                                                    await eliminarDispositivo(
                                                      dispositivo.id!,
                                                    );
                                                if (ok) cargarDispositivos();
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink(); // si no tiene permisos
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton:
          userProvider.rol == 'admin'
              ? FloatingActionButton(
                backgroundColor: const Color(0xFF6A1B9A),
                onPressed: () {
                  mostrarCrearDispositivo(context, () {
                    cargarDispositivos();
                  });
                },
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }

  Widget _buildEtiquetaEstado(String estado) {
    late IconData icono;
    late Color color;

    switch (estado) {
      case 'asignado':
        icono = Icons.lock;
        color = Color(0xFF6A1B9A); // morado
        break;
      case 'peligro':
        icono = Icons.warning_amber_rounded;
        color = Colors.red;
        break;
      case 'inactividad':
        icono = Icons.access_time;
        color = Colors.orange;
        break;
      default:
        icono = Icons.check_circle;
        color = Colors.green;
    }

    return _buildEtiquetaIcono(
      icono: icono,
      texto: 'Estado: $estado',
      color: color,
    );
  }

  Widget _buildEtiquetaIcono({
    required IconData icono,
    required String texto,
    Color color = Colors.black54,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            texto,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 🔵 Modal para crear dispositivo
  void mostrarCrearDispositivo(BuildContext context, VoidCallback onCrear) {
    // 🔐 Validación interna por seguridad
    if (userProvider.rol != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ No tienes permisos para agregar dispositivos."),
        ),
      );
      return;
    }
    final imeiController = TextEditingController();
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
                    'Nuevo Dispositivo',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: numeroCelularController,
                    decoration: InputDecoration(
                      labelText: 'Número de celular',
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
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: imeiController,
                    decoration: InputDecoration(
                      labelText: 'IMEI',
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
                          final dispositivo = Dispositivo(
                            imei: imeiController.text,
                            estadoActual: 'disponible',
                            numeroCelular: numeroCelularController.text,
                          );

                          final nuevo = await crearDispositivoYConfigurar(
                            dispositivo,
                            userProvider.idUsuario!,
                          );

                          if (nuevo != null) {
                            Navigator.pop(ctx);
                            onCrear();

                            Navigator.pushNamed(
                              context,
                              '/configuracion',
                              arguments: {'idDispositivo': nuevo.id},
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "✅ Este dispositivo se creo con configuraciones por defecto, puedes cambiarlas",
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text("❌ Error al crear o configurar"),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Guardar',
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

  void mostrarEditarDispositivo(
    BuildContext context,
    Dispositivo dispositivo,
    VoidCallback onUpdate,
  ) {
    final imeiController = TextEditingController(text: dispositivo.imei);
    final numeroCelularController = TextEditingController(
      text: dispositivo.numeroCelular ?? '',
    );
    final estadoController = TextEditingController(
      text: dispositivo.estadoActual,
    );

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
                    'Editar Dispositivo',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: numeroCelularController,
                    decoration: InputDecoration(
                      labelText: 'Número de celular',
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
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: imeiController,
                    decoration: InputDecoration(
                      labelText: 'IMEI',
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
                          final puedeEditar =
                              await PermisosService.verificarPermisoEdicion(
                                userProvider.idUsuario!,
                                dispositivo.id!,
                              );
                          if (!puedeEditar) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "❌ No tienes permisos para editar este dispositivo.",
                                  style: GoogleFonts.montserrat(),
                                ),
                              ),
                            );
                            return;
                          }
                          final actualizado = await actualizarDispositivo(
                            Dispositivo(
                              id: dispositivo.id,
                              imei: imeiController.text,
                              estadoActual: estadoController.text,
                              numeroCelular: numeroCelularController.text,
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
                        child: Text(
                          'Guardar',
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

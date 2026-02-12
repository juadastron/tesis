// Todo el contenido original se mantiene. Solo modificamos las etiquetas visuales.
// Etiquetas estilo: icono + texto en una burbuja redondeada gris clara

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/utils/notificador.dart';
import 'package:flutter_application_1/utils/permiso_utils.dart';
import 'package:flutter_application_1/utils/validadores.dart';
import 'package:flutter_application_1/widgets/historial_dialog.dart';
import 'package:flutter_application_1/widgets/solo_admin.dart';
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
                          trailing: SoloAdmin(
                            child: Table(
                              defaultColumnWidth: const FixedColumnWidth(40),
                              children: [
                                TableRow(
                                  children: [
                                    _botonAccion(
                                      icono: Icons.settings,
                                      color: Colors.deepPurple,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/configuracion',
                                          arguments: {
                                            'idDispositivo': dispositivo.id,
                                          },
                                        );
                                      },
                                    ),
                                    _botonAccion(
                                      icono: Icons.history,
                                      color: Colors.blueGrey,
                                      onTap: () {
                                        mostrarHistorialAsignacionesDialog(
                                          context,
                                          dispositivo.id!,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    _botonAccion(
                                      icono: Icons.edit,
                                      color: Colors.orange,
                                      onTap: () {
                                        mostrarEditarDispositivo(
                                          context,
                                          dispositivo,
                                          cargarDispositivos,
                                        );
                                      },
                                    ),
                                    _botonAccion(
                                      icono: Icons.delete,
                                      color: Colors.red,
                                      onTap: () async {
                                        if (dispositivo.estadoActual !=
                                            'disponible') {
                                          await _mostrarDialogoNoEliminable(
                                            context,
                                          );
                                        } else {
                                          final confirmar =
                                              await _mostrarDialogoConfirmarEliminar(
                                                context,
                                              );
                                          if (confirmar == true) {
                                            final ok =
                                                await eliminarDispositivo(
                                                  dispositivo.id!,
                                                );
                                            if (ok) cargarDispositivos();
                                            Notificador.mostrar(
                                              context: context,
                                              mensaje:
                                                  "Dispositivo eliminado correctamente",
                                              tipo: TipoNotificacion.success,
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
            mostrarCrearDispositivo(context, cargarDispositivos);
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _botonAccion({
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icono, color: color, size: 20),
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoNoEliminable(BuildContext context) async {
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('No se puede eliminar'),
            content: const Text(
              'Este dispositivo está asignado a un animal. Debes desvincularlo primero antes de eliminarlo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6A1B9A),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/animales');
                },
                child: const Text(
                  'Ir a Animales',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<bool?> _mostrarDialogoConfirmarEliminar(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('¿Confirmar eliminación?'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar este dispositivo?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildEtiquetaEstado(String estado) {
    late IconData icono;
    late Color color;

    switch (estado) {
      case 'salvo':
        icono = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case 'asignado':
        icono = Icons.lock;
        color = Color(0xFF6A1B9A); // morado
        break;
      case 'peligro':
        icono = Icons.warning_amber_rounded;
        color = Colors.red;
        break;
      case 'inactivo':
        icono = Icons.access_time;
        color = Colors.orange;
        break;
      default:
        icono = Icons.check_circle;
        color = const Color.fromARGB(255, 17, 81, 219);
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
    final formKey = GlobalKey<FormState>();

    if (!PermisoUtils.esAdmin(context)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ No tienes permisos para agregar dispositivos."),
        ),
      );
      return;
    }

    final imeiController = TextEditingController();
    final numeroCelularController = TextEditingController();

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
              child: Form(
                key: formKey,
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
                    campoBurbuja(
                      context: ctx,
                      label: "Número",
                      controller: numeroCelularController,
                      icon: Icons.phone_android,
                      validator: validarNumeroCelularEcuador,
                      colorIndex: 0,
                      maxLength: 10,
                    ),
                    const SizedBox(height: 20),
                    campoBurbuja(
                      context: ctx,
                      label: "IMEI",
                      controller: imeiController,
                      icon: Icons.confirmation_number,
                      validator: validarIMEI,
                      colorIndex: 1,
                      maxLength: 15,
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
                            if (!formKey.currentState!.validate()) return;
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
                              Navigator.pop(
                                ctx,
                              ); // Solo una vez, cierra el diálogo

                              onCrear();

                              Navigator.pushNamed(
                                context, // usa el contexto principal
                                '/configuracion',
                                arguments: {'idDispositivo': nuevo.id},
                              );

                              Notificador.mostrar(
                                context: context,
                                mensaje:
                                    "Este dispositivo se creó con configuraciones por defecto, puedes cambiarlas a tu gusto",
                                tipo: TipoNotificacion.alerta,
                              );
                            } else {
                              FocusScope.of(context).unfocus();
                              Notificador.mostrar(
                                context: context,
                                mensaje: "Error al crear el dispositivo",
                                tipo: TipoNotificacion.error,
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
    final formKey = GlobalKey<FormState>();

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
              child: Form(
                key: formKey,
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
                    campoBurbuja(
                      context: ctx,
                      label: "Número",
                      controller: numeroCelularController,
                      icon: Icons.phone_android,
                      validator: validarNumeroCelularEcuador,
                      colorIndex: 0,
                      maxLength: 10,
                    ),
                    const SizedBox(height: 20),
                    campoBurbuja(
                      context: ctx,
                      label: "IMEI",
                      controller: imeiController,
                      icon: Icons.confirmation_number,
                      validator: validarIMEI,
                      colorIndex: 1,
                      maxLength: 15,
                    ),
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
                            if (!formKey.currentState!.validate()) return;
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
                              Notificador.mostrar(
                                context: context,
                                mensaje: "Dispositivo actualizado con exito",
                                tipo: TipoNotificacion.success,
                              );
                            } else {
                              FocusScope.of(context).unfocus();
                              Notificador.mostrar(
                                context: context,
                                mensaje: "Error al actualizar",
                                tipo: TipoNotificacion.success,
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
          ),
    );
  }

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
          if (value.length == maxLength) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Máximo 10 caracteres permitidos'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
      ),
    );
  }
}

// Todo el contenido original se mantiene. Solo modificamos las etiquetas visuales.
// Etiquetas estilo: icono + texto en una burbuja redondeada gris clara

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
  List<Dispositivo> todosLosDispositivos = [];
  List<Dispositivo> dispositivosFiltrados = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
                              if (dispositivo.estadoActual == 'asignado' &&
                                  dispositivo.nombreAnimal != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: _buildEtiquetaIcono(
                                    icono: Icons.pets,
                                    texto:
                                        'Asignado a: ${dispositivo.nombreAnimal} (${dispositivo.especieAnimal})',
                                  ),
                                ),
                            ],
                          ),
                          trailing: Wrap(
                            spacing: 4, // espacio entre íconos
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
                                visualDensity: VisualDensity.compact,
                                onPressed: () async {
                                  // tu lógica de eliminación
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6A1B9A),
        onPressed: () {
          mostrarCrearDispositivo(context, () {
            cargarDispositivos();
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEtiquetaEstado(String estado) {
    final esAsignado = estado == 'asignado';
    final color = esAsignado ? Color(0xFF6A1B9A) : Colors.green;
    final icono = esAsignado ? Icons.lock : Icons.check;
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
                          final creado = await crearDispositivo(
                            Dispositivo(
                              imei: imeiController.text,
                              estadoActual: 'disponible',
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

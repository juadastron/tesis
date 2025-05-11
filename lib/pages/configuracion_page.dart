import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/MapaZonaPage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/configuracion_dispositivo.dart';
import '../models/zona_segura_model.dart';
import '../services/configuracion_service.dart';
import '../services/zonas_service.dart';

class ConfiguracionPage extends StatefulWidget {
  final int idDispositivo;

  const ConfiguracionPage({super.key, required this.idDispositivo});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  final _formKey = GlobalKey<FormState>();
  ZonaSegura? zonaActual;
  bool activarHorario = false;
  TimeOfDay horaInicio = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay horaFin = const TimeOfDay(hour: 6, minute: 0);

  final latitudController = TextEditingController();
  final longitudController = TextEditingController();
  final radioController = TextEditingController(text: '30');

  final configService = ConfiguracionService();
  final zonaService = ZonasService();

  @override
  void initState() {
    super.initState();
    cargarConfiguracion();
    cargarZona();
  }

  Future<void> cargarZona() async {
    final zona = await zonaService.obtenerZonaActiva(widget.idDispositivo);
    if (zona != null) {
      setState(() {
        zonaActual = zona;
        latitudController.text = zona.latitud.toString();
        longitudController.text = zona.longitud.toString();
        radioController.text = zona.radioMetros.toString();
      });
    }
  }

  Future<void> cargarConfiguracion() async {
    final config = await configService.obtenerConfiguracion(
      widget.idDispositivo,
    );
    if (config != null) {
      setState(() {
        activarHorario = config.activarHorario;
        horaInicio = _stringToTime(config.horaInicio);
        horaFin = _stringToTime(config.horaFin);
      });
    }
  }

  TimeOfDay _stringToTime(String timeStr) {
    final parts = timeStr.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> guardarConfiguracion() async {
    final nuevaConfig = ConfiguracionDispositivo(
      idDispositivo: widget.idDispositivo,
      activarHorario: activarHorario,
      horaInicio:
          "${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}:00",
      horaFin:
          "${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}:00",
    );

    final ok = await configService.guardarConfiguracion(nuevaConfig);
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Configuración guardada")));
    }
  }

  Future<void> crearZonaSegura() async {
    if (!_formKey.currentState!.validate()) return;
    final existeZona = latitudController.text.isNotEmpty;

    if (existeZona) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Confirmar"),
              content: const Text(
                "Ya existe una zona activa. ¿Deseas sobrescribirla?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Sí"),
                ),
              ],
            ),
      );

      if (confirmar != true) return;
    }
    final zona = ZonaSegura(
      idDispositivo: widget.idDispositivo,
      latitud: double.parse(latitudController.text),
      longitud: double.parse(longitudController.text),
      radioMetros: double.parse(radioController.text),
    );

    final response = await zonaService.crearZonaConRespuesta(zona);

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📍 Zona segura registrada")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ Error: ${response['error'] ?? 'Verifica las coordenadas en Google Maps'}",
          ),
        ),
      );
    }
    await cargarZona();
  }

  Future<void> seleccionarHoraInicio() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: horaInicio,
    );
    if (hora != null) setState(() => horaInicio = hora);
  }

  Future<void> seleccionarHoraFin() async {
    final hora = await showTimePicker(context: context, initialTime: horaFin);
    if (hora != null) setState(() => horaFin = hora);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("⚙️ Configuración del dispositivo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🕒 Configuración de horario",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SwitchListTile(
                      title: const Text("Activar horario nocturno"),
                      value: activarHorario,
                      onChanged: (val) => setState(() => activarHorario = val),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: seleccionarHoraInicio,
                          child: Text(
                            "Hora inicio: ${horaInicio.format(context)}",
                          ),
                        ),
                        ElevatedButton(
                          onPressed: seleccionarHoraFin,
                          child: Text("Hora fin: ${horaFin.format(context)}"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: guardarConfiguracion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          minimumSize: const Size(10, 40),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          "Guardar horario nocturno",
                          style: GoogleFonts.montserrat(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "📍 Zona segura",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (zonaActual != null)
                      
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            bottom: 12.0,
                          ),
                          child: Card(
                            color: const Color(0xFFEDE7F6),
                            child: ListTile(
                              title: Text(
                                "Zona actual",
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Latitud: ${zonaActual!.latitud}\nLongitud: ${zonaActual!.longitud}\nRadio: ${zonaActual!.radioMetros} m",
                                
                                style: GoogleFonts.montserrat(),
                              ),
                              
                            ),
                          ),
                        ),
                        
                      TextFormField(
                        controller: latitudController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Latitud"),
                        validator: (value) {
                          final lat = double.tryParse(value ?? '');
                          if (lat == null || lat < -90 || lat > 90) {
                            return "Latitud inválida (-90 a 90)";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: longitudController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Longitud",
                        ),
                        validator: (value) {
                          final lon = double.tryParse(value ?? '');
                          if (lon == null || lon < -180 || lon > 180) {
                            return "Longitud inválida (-180 a 180)";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: radioController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Radio (m)",
                        ),
                        validator: (value) {
                          final radio = double.tryParse(value ?? '');
                          if (radio == null || radio < 10) {
                            return "Radio mínimo permitido: 10m";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: crearZonaSegura,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A1B9A),
                                minimumSize: const Size(10, 40),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                "Registrar zona segura",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12), // Espacio entre botones
                            ElevatedButton(
                              onPressed: () {
                                if (zonaActual != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => MapaZonaPage(
                                            latitud: zonaActual!.latitud,
                                            longitud: zonaActual!.longitud,
                                            radioMetros:
                                                zonaActual!.radioMetros,
                                          ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 70, 117, 192),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                "Ver en mapa",
                                style: GoogleFonts.montserrat(
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                              
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

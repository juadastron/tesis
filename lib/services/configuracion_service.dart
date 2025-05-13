import 'dart:convert';
import 'package:flutter_application_1/core/config.dart'; // tu baseUrl está aquí
import 'package:http/http.dart' as http;
import '../models/configuracion_dispositivo.dart'; // Asegúrate de que el nombre del archivo sea correcto

class ConfiguracionService {
  final String apiUrl = '${baseUrl}configuraciones.php';

  Future<ConfiguracionDispositivo?> obtenerConfiguracion(
    int idDispositivo,
  ) async {
    final response = await http.get(
      Uri.parse('$apiUrl?id_dispositivo=$idDispositivo'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null && data is Map<String, dynamic> && data.isNotEmpty) {
        return ConfiguracionDispositivo.fromJson(data);
      }
    }

    return null; // Sin datos o error
  }

  Future<bool> guardarConfiguracion(ConfiguracionDispositivo config) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id_dispositivo': config.idDispositivo,
        'activar_horario_nocturno': config.activarHorario,
        'hora_inicio_nocturna': config.horaInicio,
        'hora_fin_nocturna': config.horaFin,
        'activar_siesta': config.activarSiesta,
        'hora_inicio_siesta': config.horaInicioSiesta,
        'hora_fin_siesta': config.horaFinSiesta,
        'umbral_inactividad_min': config.umbralInactividadMin,
        'modo_ahorro': config.modoAhorro,
        'frecuencia_gps_minutos': config.frecuenciaGpsMinutos,
      }),
    );
    print("🔍 BODY: ${response.body}");
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final decoded = json.decode(response.body);
      return decoded['success'] == true;
    } else {
      print("❌ BODY vacío o error HTTP (${response.statusCode})");
      return false;
    }
  }
}

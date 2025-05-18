import 'dart:convert';
import 'package:flutter_application_1/core/config.dart'; // baseUrl
import 'package:http/http.dart' as http;
import '../models/configuracion_dispositivo.dart';

class ConfiguracionMqttService {
  final String mqttApiUrl = '${baseUrl}enviar_config.php';

  Future<void> enviarConfiguracion(ConfiguracionDispositivo config) async {
    final payload = {
      "id_dispositivo": config.idDispositivo,
      "imei": config.imei,
      "activar_horario_nocturno": config.activarHorario ? 1 : 0,
      "hora_inicio_nocturna": config.horaInicio,
      "hora_fin_nocturna": config.horaFin,
      "activar_siesta": config.activarSiesta ? 1 : 0,
      "hora_inicio_siesta": config.horaInicioSiesta,
      "hora_fin_siesta": config.horaFinSiesta,
      "modo_ahorro": config.modoAhorro ? 1 : 0,
      "frecuencia_gps_minutos": config.frecuenciaGpsMinutos,
      "umbral_inactividad_min": config.umbralInactividadMin,
    };

    print("📤 Enviando configuración MQTT: ${jsonEncode(payload)}");

    final response = await http.post(
      Uri.parse(mqttApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    print("📥 Respuesta del servidor: ${response.statusCode}");
    print("📦 BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("❌ Error al publicar configuración: ${response.body}");
    }
  }
}

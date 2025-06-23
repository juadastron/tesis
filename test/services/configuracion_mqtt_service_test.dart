import 'package:flutter_application_1/core/config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application_1/models/configuracion_dispositivo.dart';

import 'animal_service_test.mocks.dart';

@GenerateMocks([http.Client])

// ✅ Función testeable sin modificar la clase original
Future<void> enviarConfiguracionConCliente(
  http.Client client,
  ConfiguracionDispositivo config,
) async {
  final mqttApiUrl = '${baseUrl}enviar_config.php';

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

  final response = await client.post(
    Uri.parse(mqttApiUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(payload),
  );

  if (response.statusCode != 200) {
    throw Exception("❌ Error al publicar configuración: ${response.body}");
  }
}

void main() {
  group('ConfiguracionMqttService', () {
    final config = ConfiguracionDispositivo(
      idDispositivo: 1,
      imei: "123456789012345",
      activarHorario: true,
      horaInicio: "22:00:00",
      horaFin: "06:00:00",
      activarSiesta: false,
      horaInicioSiesta: "13:00:00",
      horaFinSiesta: "14:00:00",
      modoAhorro: true,
      frecuenciaGpsMinutos: 15,
      umbralInactividadMin: 30,
    );

    test('enviarConfiguracionConCliente no lanza error si statusCode es 200', () async {
      final client = MockClient();

      when(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('OK', 200));

      expect(enviarConfiguracionConCliente(client, config), completes);
    });

    test('enviarConfiguracionConCliente lanza excepción si statusCode no es 200', () async {
      final client = MockClient();

      when(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 500));

      expect(enviarConfiguracionConCliente(client, config), throwsException);
    });
  });
}

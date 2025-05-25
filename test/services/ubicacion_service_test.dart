import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application_1/core/config.dart';

import 'animal_service_test.mocks.dart';

@GenerateMocks([http.Client])

void main() {
  group('ubicacion_service.dart', () {
    test('obtenerDispositivosAsignadosConCliente filtra correctamente', () async {
      final client = MockClient();

      final mockResponse = jsonEncode({
        "success": true,
        "dispositivos": [
          {"id": 1, "estado_actual": "asignado"},
          {"id": 2, "estado_actual": "libre"},
          {"id": 3, "estado_actual": "inactividad"},
        ]
      });

      when(client.get(Uri.parse('${baseUrl}ubicaciones.php')))
          .thenAnswer((_) async => http.Response(mockResponse, 200));

      final dispositivos = await obtenerDispositivosAsignadosConCliente(client);

      expect(dispositivos.length, 2);
      expect(dispositivos[0]['estado_actual'], 'asignado');
      expect(dispositivos[1]['estado_actual'], 'inactividad');
    });

    test('obtenerRecorridoUltimoDiaConCliente devuelve recorrido válido', () async {
      final client = MockClient();

      final mockResponse = jsonEncode({
        "success": true,
        "recorrido": [
          {"latitud": -4.0, "longitud": -79.2},
          {"latitud": -4.01, "longitud": -79.21},
        ]
      });

      when(client.get(Uri.parse('${baseUrl}ubicaciones.php?id_dispositivo=123&recorrido=1')))
          .thenAnswer((_) async => http.Response(mockResponse, 200));

      final recorrido = await obtenerRecorridoUltimoDiaConCliente(client, '123');

      expect(recorrido.length, 2);
      expect(recorrido[0]['latitud'], -4.0);
    });
  });
}




Future<List<Map<String, dynamic>>> obtenerDispositivosAsignadosConCliente(http.Client client) async {
  final response = await client.get(Uri.parse('${baseUrl}ubicaciones.php'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final estadosValidos = ['asignado', 'peligro', 'inactividad'];

    if (data['success'] == true) {
      final dispositivos = (data['dispositivos'] as List)
          .where((d) => estadosValidos.contains(d['estado_actual']))
          .map((d) => d as Map<String, dynamic>)
          .toList();
      return dispositivos;
    } else {
      throw Exception('Respuesta con success=false');
    }
  } else {
    throw Exception('Error HTTP: ${response.statusCode}');
  }
}

Future<List<Map<String, dynamic>>> obtenerRecorridoUltimoDiaConCliente(
  http.Client client,
  String idDispositivo,
) async {
  final response = await client.get(
    Uri.parse('${baseUrl}ubicaciones.php?id_dispositivo=$idDispositivo&recorrido=1'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return List<Map<String, dynamic>>.from(data['recorrido']);
    }
  }
  throw Exception('Error al obtener recorrido');
}

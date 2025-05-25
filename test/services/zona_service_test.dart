import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application_1/models/zona_segura_model.dart';
import 'package:flutter_application_1/core/config.dart';

import 'animal_service_test.mocks.dart';

@GenerateMocks([http.Client])

void main() {
  group('zonas_service.dart', () {
    test('obtenerZonasConCliente devuelve lista de zonas', () async {
      final client = MockClient();

      final mockResponse = jsonEncode([
        {
          "id_zona": 1,
          "id_dispositivo": 10,
          "latitud": -4.0,
          "longitud": -79.2,
          "radio_metros": 30,
          "activo": 1
        }
      ]);

      when(client.get(Uri.parse('${baseUrl}zonas.php?id_animal=5')))
          .thenAnswer((_) async => http.Response(mockResponse, 200));

      final zonas = await obtenerZonasConCliente(client, 5);

      expect(zonas.length, 1);
      expect(zonas.first.latitud, -4.0);
    });

    test('crearZonaConCliente devuelve mapa con success', () async {
      final client = MockClient();
      final zona = ZonaSegura(
        idDispositivo: 10,
        latitud: -4.1,
        longitud: -79.3,
        radioMetros: 50,
      );

      when(client.post(
        Uri.parse('${baseUrl}zonas.php'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({"success": true}), 200));

      final respuesta = await crearZonaConCliente(client, zona);

      expect(respuesta["success"], true);
    });
  });
}


Future<List<ZonaSegura>> obtenerZonasConCliente(http.Client client, int idAnimal) async {
  final response = await client.get(Uri.parse('${baseUrl}zonas.php?id_animal=$idAnimal'));
  if (response.statusCode == 200) {
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => ZonaSegura.fromJson(json)).toList();
  }
  return [];
}

Future<Map<String, dynamic>> crearZonaConCliente(
  http.Client client,
  ZonaSegura zona,
) async {
  final response = await client.post(
    Uri.parse('${baseUrl}zonas.php'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'id_dispositivo': zona.idDispositivo,
      'latitud': zona.latitud,
      'longitud': zona.longitud,
      'radio_metros': zona.radioMetros,
    }),
  );

  return json.decode(response.body);
}

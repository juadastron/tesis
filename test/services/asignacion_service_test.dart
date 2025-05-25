import 'dart:convert';

import 'package:flutter_application_1/core/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';


import 'animal_service_test.mocks.dart';


Future<bool> asignarDispositivoAnimalConCliente(http.Client client, int idAnimal, int idDispositivo) async {
  final response = await client.post(
    Uri.parse('${baseUrl}asignaciones.php'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "id_animal": idAnimal,
      "id_dispositivo": idDispositivo,
    }),
  );

  final data = jsonDecode(response.body);
  return data["success"] == true;
}

Future<bool> desvincularDispositivoAnimalConCliente(http.Client client, int idAsignacion) async {
  final response = await client.put(
    Uri.parse('${baseUrl}asignaciones.php'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({'id_asignacion': idAsignacion}),
  );

  final data = jsonDecode(response.body);
  return data["success"] == true;
}


@GenerateMocks([http.Client])

void main() {
  group('asignacion_service.dart', () {
    test('asignarDispositivoAnimalConCliente devuelve true si el backend responde success', () async {
      final client = MockClient();

      when(client.post(
        Uri.parse('${baseUrl}asignaciones.php'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({'success': true}), 200));

      final exito = await asignarDispositivoAnimalConCliente(client, 1, 10);
      expect(exito, isTrue);
    });

    test('desvincularDispositivoAnimalConCliente devuelve true si el backend responde success', () async {
      final client = MockClient();

      when(client.put(
        Uri.parse('${baseUrl}asignaciones.php'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({'success': true}), 200));

      final exito = await desvincularDispositivoAnimalConCliente(client, 99);
      expect(exito, isTrue);
    });
  });
}
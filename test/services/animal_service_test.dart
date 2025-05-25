import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:flutter_application_1/models/animal_model.dart';
import 'package:flutter_application_1/core/config.dart';
import 'animal_service_test.mocks.dart' as mocks;



Future<bool> crearAnimalConCliente(http.Client client, Animal animal) async {
  final response = await client.post(
    Uri.parse("$baseUrl/animales.php"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(animal.toJson()),
  );

  final resultado = jsonDecode(response.body);
  return resultado["success"] == true;
}



// Genera mocks para http.Client
@GenerateMocks([http.Client])
void main() {
  group('animal_service.dart', () {
    test(
      'crearAnimalConCliente devuelve true si el backend responde success',
      () async {
        final client = mocks.MockClient();

        final animal = Animal(
          nombre: 'Luna',
          especie: 'Gato',
          edad: 3,
          color: 'Negro',
        );

        when(
          client.post(
            Uri.parse('$baseUrl/animales.php'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode({"success": true}), 200),
        );

        final exito = await crearAnimalConCliente(client, animal);

        expect(exito, isTrue);
      },
    );

    test(
      'crearAnimalConCliente devuelve false si el backend responde error',
      () async {
        final client = mocks.MockClient();

        final animal = Animal(
          nombre: 'Max',
          especie: 'Perro',
          edad: 4,
          color: 'Blanco',
        );

        when(
          client.post(
            Uri.parse('$baseUrl/animales.php'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode({"success": false}), 200),
        );

        final exito = await crearAnimalConCliente(client, animal);

        expect(exito, isFalse);
      },
    );
  });
}

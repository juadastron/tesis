import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application_1/models/usuario_model.dart';
import 'package:flutter_application_1/core/config.dart';

import 'animal_service_test.mocks.dart';


@GenerateMocks([http.Client])

void main() {
  group('usuario_service.dart', () {
    test('obtenerUsuariosConCliente devuelve lista de usuarios', () async {
      final client = MockClient();

      final mockResponse = jsonEncode([
        {
          "id_usuario": 1,
          "nombre": "Juan",
          "email": "juan@mail.com",
          "rol": "admin"
        },
        {
          "id_usuario": 2,
          "nombre": "Ana",
          "email": "ana@mail.com",
          "rol": "voluntario"
        }
      ]);

      when(client.get(Uri.parse("${baseUrl}usuarios.php")))
          .thenAnswer((_) async => http.Response(mockResponse, 200));

      final usuarios = await obtenerUsuariosConCliente(client);
      expect(usuarios.length, 2);
      expect(usuarios.first.nombre, "Juan");
    });

    test('crearUsuarioConCliente devuelve true si backend responde success', () async {
      final client = MockClient();
      final usuario = Usuario(nombre: "Carlos", email: "carlos@mail.com", rol: "admin");

      when(client.post(
        Uri.parse("${baseUrl}usuarios.php"),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({"success": true}), 200));

      final exito = await crearUsuarioConCliente(client, usuario);
      expect(exito, isTrue);
    });
  });
}



Future<List<Usuario>> obtenerUsuariosConCliente(http.Client client) async {
  final response = await client.get(Uri.parse("${baseUrl}usuarios.php"));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Usuario.fromJson(e)).toList();
  } else {
    throw Exception('Error al cargar usuarios');
  }
}

Future<bool> crearUsuarioConCliente(http.Client client, Usuario usuario) async {
  final response = await client.post(
    Uri.parse("${baseUrl}usuarios.php"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(usuario.toJson()),
  );

  if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
    final resultado = jsonDecode(response.body);
    return resultado["success"] == true;
  } else {
    return false;
  }
}



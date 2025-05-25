import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application_1/core/config.dart';
import 'package:flutter_application_1/models/dispositivo_model.dart';

import 'animal_service_test.mocks.dart';



Future<Dispositivo?> crearDispositivoConCliente(
  http.Client client,
  Dispositivo dispositivo,
  int idUsuario,
) async {
  final body = dispositivo.toJson();
  body["id_usuario"] = idUsuario.toString();

  final response = await client.post(
    Uri.parse('${baseUrl}dispositivos.php'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data["success"] == true) {
      return Dispositivo(
        id: data["id_dispositivo"],
        imei: data["imei"],
        estadoActual: dispositivo.estadoActual,
        numeroCelular: dispositivo.numeroCelular,
      );
    }
  }

  return null;
}

Future<List<Dispositivo>> obtenerDispositivosDisponiblesConCliente(http.Client client) async {
  final response = await client.get(
    Uri.parse('${baseUrl}dispositivos.php?disponibles=1'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Dispositivo.fromJson(e)).toList();
  } else {
    throw Exception("Error al cargar dispositivos disponibles");
  }
}

@GenerateMocks([http.Client])

void main() {
  group('dispositivo_service.dart', () {
    test('crearDispositivoConCliente devuelve dispositivo si éxito', () async {
      final client = MockClient();
      final dispositivo = Dispositivo(
        imei: '123456789012345',
        estadoActual: 'activo',
        numeroCelular: '0999999999',
      );

      when(client.post(
        Uri.parse('${baseUrl}dispositivos.php'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        jsonEncode({
          "success": true,
          "id_dispositivo": 10,
          "imei": "123456789012345"
        }),
        200,
      ));

      final creado = await crearDispositivoConCliente(client, dispositivo, 1);
      expect(creado, isNotNull);
      expect(creado!.id, 10);
      expect(creado.imei, '123456789012345');
    });

    test('obtenerDispositivosDisponiblesConCliente devuelve lista', () async {
      final client = MockClient();

      final mockResponse = jsonEncode([
        {
          "id_dispositivo": 1,
          "imei": "123456789012345",
          "estado_actual": "activo",
        },
        {
          "id_dispositivo": 2,
          "imei": "987654321098765",
          "estado_actual": "inactivo",
        }
      ]);

      when(client.get(
        Uri.parse('${baseUrl}dispositivos.php?disponibles=1'),
      )).thenAnswer((_) async => http.Response(mockResponse, 200));

      final dispositivos = await obtenerDispositivosDisponiblesConCliente(client);

      expect(dispositivos.length, 2);
      expect(dispositivos.first.imei, '123456789012345');
    });
  });
}

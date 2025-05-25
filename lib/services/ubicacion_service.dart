import 'dart:convert';
import 'package:flutter_application_1/core/config.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> obtenerDispositivosAsignados() async {
  final response = await http.get(Uri.parse('${baseUrl}ubicaciones.php'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      final dispositivos = (data['dispositivos'] as List)
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

Future<List<Map<String, dynamic>>> obtenerRecorridoUltimoDia(String idDispositivo) async {
  final response = await http.get(
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

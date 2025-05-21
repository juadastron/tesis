import 'dart:convert';
import 'package:flutter_application_1/models/asignacion_model.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';

Future<bool> asignarDispositivoAnimal(int idAnimal, int idDispositivo) async {
  final response = await http.post(
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

Future<bool> desvincularDispositivoAnimal(int idAsignacion) async {
  final response = await http.put(
    Uri.parse('${baseUrl}asignaciones.php'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({'id_asignacion': idAsignacion}),
  );

  final data = jsonDecode(response.body);
  return data["success"] == true;
}


Future<Map<String, dynamic>?> obtenerAsignacionAnimal(int idAnimal) async {
  final response = await http.get(Uri.parse('${baseUrl}asignaciones.php?id_animal=$idAnimal'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data != null && data.isNotEmpty) {
      return data;
    }
  }
  return null;
}

Future<List<Asignacion>> obtenerHistorialAsignaciones(int idDispositivo) async {
  final response = await http.get(
    Uri.parse('${baseUrl}asignaciones.php?id_dispositivo=$idDispositivo'),
  );
  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    return (data['asignaciones'] as List)
        .map((json) => Asignacion.fromJson(json))
        .toList();
  }
  return [];
}

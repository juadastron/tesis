import 'dart:convert';
import 'package:flutter_application_1/core/config.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> obtenerDispositivosAsignados() async {
  final response = await http.get(Uri.parse('${baseUrl}ubicaciones.php'));

  final data = jsonDecode(response.body);

  if (data['success'] == true) {
    final dispositivos = (data['dispositivos'] as List)
        .where((d) => d['estado_actual'] == 'asignado')
        .map((d) => d as Map<String, dynamic>)
        .toList();
    return dispositivos;
  } else {
    throw Exception('Error al cargar dispositivos: ${data['message']}');
  }
}

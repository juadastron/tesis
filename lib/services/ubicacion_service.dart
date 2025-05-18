import 'dart:convert';
import 'package:flutter_application_1/core/config.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> obtenerDispositivosAsignados() async {
  final response = await http.get(Uri.parse('${baseUrl}ubicaciones.php'));

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

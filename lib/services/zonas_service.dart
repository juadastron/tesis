import 'dart:convert';
import 'package:flutter_application_1/core/config.dart';
import 'package:http/http.dart' as http;
import '../models/zona_segura_model.dart';

class ZonasService {
  final String apiUrl = '${baseUrl}zonas.php';

  // Obtener todas las zonas por ID de animal (opcional)
  Future<List<ZonaSegura>> obtenerZonas(int idAnimal) async {
    final response = await http.get(Uri.parse('$apiUrl?id_animal=$idAnimal'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ZonaSegura.fromJson(json)).toList();
    }
    return [];
  }

  
  // Obtener solo una zona activa por dispositivo
  Future<ZonaSegura?> obtenerZonaActiva(int idDispositivo) async {
    final response = await http.get(Uri.parse('$apiUrl?id_dispositivo=$idDispositivo'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      if (jsonList.isNotEmpty) {
        return ZonaSegura.fromJson(jsonList.first);
      }
    }
    return null;
  }

  // Crear o actualizar zona, con respuesta completa
  Future<Map<String, dynamic>> crearZonaConRespuesta(ZonaSegura zona) async {
    final response = await http.post(
      Uri.parse(apiUrl),
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
}

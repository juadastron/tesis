import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart'; // para baseUrl
import '../models/dispositivo_model.dart'; // tu modelo Dispositivo

Future<List<Dispositivo>> obtenerDispositivosDisponibles() async {
  final response = await http.get(Uri.parse("${baseUrl}dispositivos.php?estado=disponible"));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Dispositivo.fromJson(e)).toList();
  } else {
    throw Exception('Error al cargar dispositivos disponibles');
  }
}

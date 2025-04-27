import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../models/dispositivo_model.dart';

Future<List<Dispositivo>> obtenerDispositivos() async {
  final response = await http.get(Uri.parse('${baseUrl}dispositivos.php'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Dispositivo.fromJson(e)).toList();
  } else {
    throw Exception('Error al cargar dispositivos');
  }
}

Future<bool> crearDispositivo(Dispositivo dispositivo) async {
  final response = await http.post(
    Uri.parse('${baseUrl}dispositivos.php'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(dispositivo.toJson()),
  );

  final data = jsonDecode(response.body);
  return data["success"] == true;
}

Future<bool> actualizarDispositivo(Dispositivo dispositivo) async {
  final response = await http.put(
    Uri.parse('${baseUrl}dispositivos.php'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(dispositivo.toJson(incluirId: true)),
  );

  final data = jsonDecode(response.body);
  return data["success"] == true;
}

Future<bool> eliminarDispositivo(int idDispositivo) async {
  final response = await http.delete(
    Uri.parse('${baseUrl}dispositivos.php'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({'id_dispositivo': idDispositivo}),
  );

  final data = jsonDecode(response.body);
  return data["success"] == true;
}

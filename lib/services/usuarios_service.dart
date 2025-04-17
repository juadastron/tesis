import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../models/usuario_model.dart';

Future<List<Usuario>> obtenerUsuarios() async {
  final response = await http.get(Uri.parse("${baseUrl}usuarios.php"));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Usuario.fromJson(e)).toList();
  } else {
    throw Exception('Error al cargar usuarios');
  }
}

Future<bool> crearUsuario(Usuario usuario) async {
  final response = await http.post(
    
    Uri.parse("${baseUrl}usuarios.php"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(usuario.toJson()),
  );
  print('📨 RESPUETA DEL SERVIDOR: ${response.body}');

  final resultado = jsonDecode(response.body);
  return resultado["success"] == true;
}

Future<bool> actualizarUsuario(Usuario usuario) async {
  final response = await http.put(
    Uri.parse("${baseUrl}usuarios.php"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(usuario.toJson(incluirId: true)),
  );

  final resultado = jsonDecode(response.body);
  return resultado["success"] == true;
}

Future<bool> eliminarUsuario(int id) async {
  final response = await http.delete(
    Uri.parse("${baseUrl}usuarios.php"),
    headers: {"Content-Type": "application/x-www-form-urlencoded"},
    body: "id_usuario=$id",
  );

  final resultado = jsonDecode(response.body);
  return resultado["success"] == true;
}

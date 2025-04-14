import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';

String? globalUserRole; // 🔐 Aquí guardamos el rol para usarlo en HomePage

Future<bool> loginUsuario(String email, String password) async {
  final url = Uri.parse("${baseUrl}login.php");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email.trim(),
      "password": password.trim(),
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      globalUserRole = data["rol"]; // ✅ guardamos el rol
      return true;
    }
  }

  return false;
}

Future<bool> registrarUsuario(String nombre, String email, String password) async {
  final url = Uri.parse("${baseUrl}registro.php");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "nombre": nombre,
      "email": email,
      "password": password,
      "rol": "admin", // o "usuario"
    }),
  );

  final data = jsonDecode(response.body);

  return data["success"] == true;
}

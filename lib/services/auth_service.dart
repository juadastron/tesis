import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';

Future<void> loginUsuario(String email, String password) async {
  final url = Uri.parse("${baseUrl}login.php");
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );

  final data = jsonDecode(response.body);
  if (data["success"] == true) {
    print("Bienvenido, ${data["nombre"]}");
    // Aquí podrías navegar al HomeScreen con Navigator.push()
  } else {
    print("Error: ${data["message"]}");
  }
}

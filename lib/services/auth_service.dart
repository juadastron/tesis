
import '../core/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

Future<bool> loginUsuario(BuildContext context, String email, String password) async {
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
      Provider.of<UserProvider>(context, listen: false).setUser(
        nombre: data["nombre"],
        email: data["email"],
        rol: data["rol"],
      );
      return true;
    }
  }

  return false;
}

Future<bool> registrarUsuario(String nombre, String email, String password, String rol) async {
  final url = Uri.parse("${baseUrl}registro.php");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "nombre": nombre,
      "email": email,
      "password": password,
      "rol": rol, // o "usuario"
    }),
  );

  final data = jsonDecode(response.body);

  return data["success"] == true;
}

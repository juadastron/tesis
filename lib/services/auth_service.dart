import 'package:flutter_application_1/services/notificaciones_service.dart';

import '../core/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/usuario_model.dart';

Future<bool> loginUsuario(
  BuildContext context,
  String email,
  String password,
) async {
  final url = Uri.parse("${baseUrl}login.php");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email.trim(), "password": password.trim()}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      final idUsuario = int.parse(data["id_usuario"].toString());

      // ✅ Guardar en Provider
      Provider.of<UserProvider>(context, listen: false).setUser(
        idUsuario: idUsuario,
        nombre: data["nombre"],
        email: data["email"],
        rol: data["rol"],
      );

      // ✅ Enviar token FCM al backend
      await NotificacionesService.guardarTokenFCMEnBackend(idUsuario);

      return true;
    }
  }

  return false;
}

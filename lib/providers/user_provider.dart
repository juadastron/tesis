import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class UserProvider extends ChangeNotifier {
  int? idUsuario;
  String? nombre;
  String? email;
  String? rol;

  void setUser({
    required int idUsuario,
    required String nombre,
    required String email,
    required String rol,
  }) {
    this.idUsuario = idUsuario;
    this.nombre = nombre;
    this.email = email;
    this.rol = rol;
    notifyListeners();
  }

  void logout() async {
    idUsuario = null;
    nombre = null;
    email = null;
    rol = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}

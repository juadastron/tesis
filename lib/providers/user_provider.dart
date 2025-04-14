import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? nombre;
  String? email;
  String? rol;

  void setUser({required String nombre, required String email, required String rol}) {
    this.nombre = nombre;
    this.email = email;
    this.rol = rol;
    notifyListeners();
  }

  void logout() {
    nombre = null;
    email = null;
    rol = null;
    notifyListeners();
  }
}

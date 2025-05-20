import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';

class PermisosService {
  static Future<bool> verificarPermisoEdicion(int idUsuario, int idDispositivo) async {
    final url = Uri.parse(
      '${baseUrl}dispositivos.php?permiso_edicion=1&id_usuario=$idUsuario&id_dispositivo=$idDispositivo',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['puede_editar'] == true;
    }

    return false;
  }
}

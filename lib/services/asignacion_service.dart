import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';

Future<bool> asignarDispositivoAnimal(int idAnimal, int idDispositivo) async {
  final response = await http.post(
    Uri.parse('${baseUrl}asignaciones.php'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "id_animal": idAnimal,
      "id_dispositivo": idDispositivo,
    }),
  );

  final data = jsonDecode(response.body);
  return data["success"] == true;
}

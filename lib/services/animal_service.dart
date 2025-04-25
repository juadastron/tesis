import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../models/animal_model.dart';

Future<List<Animal>> obtenerAnimales() async {
  final response = await http.get(Uri.parse("${baseUrl}animales.php"));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Animal.fromJson(e)).toList();
  } else {
    throw Exception('Error al cargar animales');
  }
}

Future<bool> crearAnimal(Animal animal) async {
  final response = await http.post(
    Uri.parse("${baseUrl}animales.php"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(animal.toJson()),
  );
  print('📨 RESPUETA CREAR: ${response.body}');

  final resultado = jsonDecode(response.body);
  return resultado["success"] == true;
}

Future<bool> actualizarAnimal(Animal animal) async {
  final response = await http.put(
    Uri.parse("${baseUrl}animales.php"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(animal.toJson(incluirId: true)),
  );
  print('📨 RESPUETA ACTUALIZAR: ${response.body}');

  final resultado = jsonDecode(response.body);
  return resultado["success"] == true;
}

Future<bool> eliminarAnimal(int id) async {
  final response = await http.delete(
    Uri.parse("${baseUrl}animales.php"),
    headers: {"Content-Type": "application/x-www-form-urlencoded"},
    body: "id_animal=$id",
  );

  final resultado = jsonDecode(response.body);
  return resultado["success"] == true;
}

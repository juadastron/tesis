import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../models/animal_model.dart';

Future<List<Animal>> obtenerAnimales() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/animales.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Animal.fromJson(e)).toList();
    } else {
      print("Error HTTP: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("Excepción en obtenerAnimales(): $e");
    return [];
  }
}

Future<bool> crearAnimal(Animal animal) async {
  final response = await http.post(
    Uri.parse("${baseUrl}animales.php"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(animal.toJson()),
  );

  final resultado = jsonDecode(response.body);
  return resultado["success"] == true;
}

Future<bool> actualizarAnimal(Animal animal) async {
  final response = await http.put(
    Uri.parse("${baseUrl}animales.php"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(animal.toJson(incluirId: true)),
  );

  final resultado = jsonDecode(response.body);
  return resultado["success"] == true;
}

Future<bool> eliminarAnimal(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/animales.php?id_animal=$id'),
  );

  if (response.body.isEmpty) {
    print("error vacio del server");
    return false;
  }

  final resultado = jsonDecode(response.body);

  if (!resultado['success']) {
    print("error"+resultado);
  }

  return resultado['success'] == true;
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DireccionService {
  static const _apiKey = '5b3ce3597851110001cf62488b8b18199e3a45f9b318879e929d5990';
  static const _baseUrl = 'https://api.openrouteservice.org/v2/directions/foot-walking';

  static Future<List<LatLng>> obtenerRuta(LatLng inicio, LatLng fin) async {
    final url = Uri.parse('$_baseUrl?api_key=$_apiKey');

    final body = {
      "coordinates": [
        [inicio.longitude, inicio.latitude],
        [fin.longitude, fin.latitude]
      ]
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'];

      return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
    } else {
      throw Exception('Error al obtener la ruta: ${response.body}');
    }
  }
}

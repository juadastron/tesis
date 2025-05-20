import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DireccionService {
  static const _apiKey =
      '5b3ce3597851110001cf62488b8b18199e3a45f9b318879e929d5990';
  static const _baseUrl = 'https://api.openrouteservice.org/v2/directions';

  static Future<List<LatLng>> obtenerRuta(
    LatLng inicio,
    LatLng fin,
    String modo,
  ) async {
    final url = Uri.parse('$_baseUrl/$modo?geometry_format=geojson');

    final body = {
      "coordinates": [
        [inicio.longitude, inicio.latitude],
        [fin.longitude, fin.latitude],
      ],
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": _apiKey,
        "Accept": "application/json",
      },

      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final routes = data['routes'];
      if (routes != null && routes.isNotEmpty) {
        final encoded = routes[0]['geometry']; // es un string polyline
        final decoded = PolylinePoints().decodePolyline(encoded);

        return decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();
      } else {
        throw Exception('La API no devolvió rutas válidas.');
      }
    } else {
      throw Exception('Error al obtener la ruta: ${response.body}');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class DireccionService {
  static const _apiKey =
      '5b3ce3597851110001cf62488b8b18199e3a45f9b318879e929d5990';
  static const _baseUrl =
      'https://api.openrouteservice.org/v2/directions/foot-walking?geometry_format=geojson';

  static Future<List<LatLng>> obtenerRuta(LatLng inicio, LatLng fin) async {
    final url = Uri.parse(_baseUrl);

    final body = {
      "coordinates": [
        [inicio.longitude, inicio.latitude],
        [fin.longitude, fin.latitude],
      ],
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json", "Authorization": _apiKey},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final encoded = data['routes'][0]['geometry'];

      // ✅ Decodificar polyline
      final points = PolylinePoints().decodePolyline(encoded);

      return points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    } else {
      throw Exception('Error al obtener la ruta: ${response.body}');
    }
  }
}

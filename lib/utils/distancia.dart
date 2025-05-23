import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

double calcularDistanciaTotal(List<LatLng> puntos) {
  double total = 0;
  for (int i = 0; i < puntos.length - 1; i++) {
    total += _distanciaEnKm(puntos[i], puntos[i + 1]);
  }
  return total;
}

double _distanciaEnKm(LatLng a, LatLng b) {
  const R = 6371; // Radio de la Tierra en km
  final dLat = _gradosARadianes(b.latitude - a.latitude);
  final dLon = _gradosARadianes(b.longitude - a.longitude);
  final lat1 = _gradosARadianes(a.latitude);
  final lat2 = _gradosARadianes(b.latitude);

  final a1 = sin(dLat / 2) * sin(dLat / 2) +
      sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
  final c = 2 * atan2(sqrt(a1), sqrt(1 - a1));
  return R * c;
}

double _gradosARadianes(double grado) => grado * pi / 180;

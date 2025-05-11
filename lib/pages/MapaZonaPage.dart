import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaZonaPage extends StatelessWidget {
  final double latitud;
  final double longitud;
  final double radioMetros;

  const MapaZonaPage({
    super.key,
    required this.latitud,
    required this.longitud,
    required this.radioMetros,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng centro = LatLng(latitud, longitud);

    return Scaffold(
      appBar: AppBar(title: const Text("🗺️ Zona Segura en el Mapa")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: centro,
          zoom: 16,
        ),
        circles: {
          Circle(
            circleId: const CircleId("zona_segura"),
            center: centro,
            radius: radioMetros,
            fillColor: Colors.purple.withOpacity(0.3),
            strokeColor: Colors.purple,
            strokeWidth: 2,
          )
        },
        markers: {
          Marker(markerId: const MarkerId("centro"), position: centro)
        },
        onMapCreated: (controller) {},
      ),
    );
  }
}

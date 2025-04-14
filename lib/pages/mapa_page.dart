import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  GoogleMapController? _mapController;
  Set<Marker> _marcadores = {};
  List<dynamic> _dispositivos = [];
  String? _dispositivoSeleccionado;

  static const CameraPosition _posicionInicial = CameraPosition(
    target: LatLng(-3.99313, -79.20422),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _cargarDispositivos();
  }

  Future<void> _cargarDispositivos() async {
    try {
      final response = await http.get(Uri.parse("http://10.0.2.2/geo_little_paws_api/ubicaciones.php"));
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          _dispositivos = data['dispositivos'];
          _marcadores = _dispositivos.map((d) {
            return Marker(
              markerId: MarkerId(d['id_dispositivo'].toString()),
              position: LatLng(double.parse(d['latitud']), double.parse(d['longitud'])),
              infoWindow: InfoWindow(title: d['imei'] ?? 'Dispositivo'),
            );
          }).toSet();
        });
      } else {
        print("Error al cargar dispositivos: ${data['message']}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _centrarEnDispositivo(String idDispositivo) {
    final dispositivo = _dispositivos.firstWhere((d) => d['id_dispositivo'].toString() == idDispositivo);
    final lat = double.parse(dispositivo['latitud']);
    final lng = double.parse(dispositivo['longitud']);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de dispositivos'),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _posicionInicial,
            markers: _marcadores,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: _dispositivoSeleccionado,
                  hint: const Text('Seleccionar dispositivo'),
                  items: _dispositivos.map((d) {
                    return DropdownMenuItem<String>(
                      value: d['id_dispositivo'].toString(),
                      child: Text(d['imei'] ?? 'Dispositivo'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _dispositivoSeleccionado = value;
                    });
                    if (value != null) _centrarEnDispositivo(value);
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

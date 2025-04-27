import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/ubicacion_service.dart'; // 🔥
import 'package:flutter/foundation.dart'; // 👈 para Factory
import 'package:flutter/gestures.dart';

BitmapDescriptor? _iconoPatita;

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
    _cargarIcono();
  _cargarDispositivos();
  }

Future<void> _cargarIcono() async {
  _iconoPatita = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(48, 48)),
    'assets/images/64.png',
  );
}

  Future<void> _cargarDispositivos() async {
    try {
      final dispositivosAsignados = await obtenerDispositivosAsignados();

      setState(() {
        _dispositivos = dispositivosAsignados;
        _marcadores =
            _dispositivos.map((d) {
              return Marker(
                markerId: MarkerId(d['id_dispositivo'].toString()),
                position: LatLng(
                  double.parse(d['latitud']),
                  double.parse(d['longitud']),
                ),
                icon: _iconoPatita ?? BitmapDescriptor.defaultMarker, 
                infoWindow: InfoWindow(title: d['imei'] ?? 'Dispositivo'),
              );
            }).toSet();
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void _centrarEnDispositivo(String idDispositivo) {
    final dispositivo = _dispositivos.firstWhere(
      (d) => d['id_dispositivo'].toString() == idDispositivo,
    );
    final lat = double.parse(dispositivo['latitud']);
    final lng = double.parse(dispositivo['longitud']);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17),
    );
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
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
          ),

          // 👇 El Dropdown que estará encima y sí recibirá toques
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      value: _dispositivoSeleccionado,
                      hint: const Text('Seleccionar dispositivo'),
                      items:
                          _dispositivos.map((d) {
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

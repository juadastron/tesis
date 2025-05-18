import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/ubicacion_service.dart';
import '../services/direccion_service.dart';
import 'package:location/location.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

BitmapDescriptor? _iconoPatita;

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  GoogleMapController? _mapController;
  Set<Marker> _marcadores = {};
  Set<Polyline> _polilineas = {};
  List<dynamic> _dispositivos = [];
  String? _dispositivoSeleccionado;

  static const CameraPosition _posicionInicial = CameraPosition(
    target: LatLng(-3.99313, -79.20422),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _cargarIcono().then((_) => _cargarDispositivos());
  }

  Future<void> _cargarIcono() async {
    _iconoPatita = await BitmapDescriptor.asset(
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
                position: LatLng(d['latitud'], d['longitud']),
                icon: _iconoPatita ?? BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(
                  title:
                      d['nombre_animal'] != null && d['especie_animal'] != null
                          ? '${d['nombre_animal']} (${d['especie_animal']})'
                          : 'Dispositivo',
                ),
              );
            }).toSet();
      });
      print('Dispositivos recibidos: $_dispositivos');
      print('Marcadores: $_marcadores');
    } catch (e) {
      print("Error al cargar dispositivos: $e");
    }
  }

  void _centrarEnDispositivo(String idDispositivo) {
    final dispositivo = _dispositivos.firstWhere(
      (d) => d['id_dispositivo'].toString() == idDispositivo,
    );
    final lat = dispositivo['latitud'];
    final lng = dispositivo['longitud'];
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17),
    );
  }

  Future<void> _mostrarRuta(LatLng destino) async {
    final location = Location();
    final ubicacion = await location.getLocation();
    final origen = LatLng(ubicacion.latitude!, ubicacion.longitude!);
    final ruta = await DireccionService.obtenerRuta(origen, destino); 
    print('Ubicación actual: ${ubicacion.latitude}, ${ubicacion.longitude}');
    setState(() {
      _polilineas = {
        Polyline(
          polylineId: const PolylineId('ruta'),
          points: ruta,
          color: Colors.deepPurple,
          width: 4,
        ),
      };
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(origen, 15));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ubicación de los animales',
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6A1B9A),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _posicionInicial,
            markers: _marcadores,
            polylines: _polilineas,
            onMapCreated: (controller) => _mapController = controller,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF6A1B9A),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _dispositivoSeleccionado,
                        isExpanded: true,
                        hint: Text(
                          'Seleccionar dispositivo',
                          style: GoogleFonts.montserrat(
                            color: Colors.grey[700],
                          ),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF6A1B9A),
                        ),
                        style: GoogleFonts.montserrat(color: Colors.black),
                        items:
                            _dispositivos.map((d) {
                              return DropdownMenuItem<String>(
                                value: d['id_dispositivo'].toString(),
                                child: Text(
                                  d['nombre_animal'] != null &&
                                          d['especie_animal'] != null
                                      ? '${d['nombre_animal']} (${d['especie_animal']})'
                                      : d['imei'] ?? 'Dispositivo',
                                ),
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
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_dispositivoSeleccionado != null) {
                        final dispositivo = _dispositivos.firstWhere(
                          (d) =>
                              d['id_dispositivo'].toString() ==
                              _dispositivoSeleccionado,
                        );
                        final lat = dispositivo['latitud'];
                        final lng = dispositivo['longitud'];
                        
                        _mostrarRuta(LatLng(lat, lng));
                      }
                    },
                    icon: const Icon(Icons.alt_route),
                    label: Text('Cargar ruta', style: GoogleFonts.montserrat()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

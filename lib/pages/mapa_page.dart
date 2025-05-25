import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/ubicacion_service.dart'
    as UbicacionService;
import 'package:flutter_application_1/utils/notificador.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/ubicacion_service.dart';
import '../services/direccion_service.dart';
import 'package:location/location.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import '../utils/distancia.dart';

BitmapDescriptor? _iconoPatita;

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  double? _ultimaDistanciaKm;
  GoogleMapController? _mapController;
  Set<Marker> _marcadores = {};
  Set<Polyline> _polilineas = {};
  List<dynamic> _dispositivos = [];
  String? _dispositivoSeleccionado;
  String _modoSeleccionado = 'foot-walking';
  Marker? _miUbicacion;

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
    print('Dispositivos cargados: $_dispositivos');
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

  LatLngBounds _boundsFromLatLngList(List<LatLng> puntos) {
    final latitudes = puntos.map((p) => p.latitude);
    final longitudes = puntos.map((p) => p.longitude);

    final southwest = LatLng(
      latitudes.reduce((a, b) => a < b ? a : b),
      longitudes.reduce((a, b) => a < b ? a : b),
    );

    final northeast = LatLng(
      latitudes.reduce((a, b) => a > b ? a : b),
      longitudes.reduce((a, b) => a > b ? a : b),
    );

    return LatLngBounds(southwest: southwest, northeast: northeast);
  }

  Future<void> _mostrarRuta(LatLng destino) async {
    final location = Location();
    final ubicacion = await location.getLocation();
    final origen = LatLng(ubicacion.latitude!, ubicacion.longitude!);
    final ruta = await DireccionService.obtenerRuta(
      origen,
      destino,
      _modoSeleccionado,
    );
    final distanciaTotal = calcularDistanciaTotal(ruta);
    // 🟪 Guardar en variable para mostrar como etiqueta flotante
    setState(() {
      _ultimaDistanciaKm = distanciaTotal;
    });
    final puntoMedio = ruta[ruta.length ~/ 2];
    final marcadorDistancia = Marker(
      markerId: const MarkerId('distancia_km'),
      position: puntoMedio,
      infoWindow: InfoWindow(title: '${distanciaTotal.toStringAsFixed(2)} km'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    // 🔵 Crea marcador de tu ubicación
    final marcadorUbicacion = Marker(
      markerId: const MarkerId('mi_ubicacion'),
      position: origen,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Estás aquí'),
    );

    setState(() {
      _miUbicacion = marcadorUbicacion;

      _polilineas = {
        Polyline(
          polylineId: const PolylineId('ruta'),
          points: ruta,
          color: Colors.deepPurple,
          width: 4,
        ),
      };

      // Agrega el marcador de ubicación a la lista
      _marcadores.addAll([_miUbicacion!, marcadorDistancia]);
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(origen, 15));
  }

  Widget _buildBotonModo(IconData icono, String modo) {
    return FloatingActionButton(
      heroTag: modo,
      onPressed: () {
        setState(() {
          _modoSeleccionado = modo;
        });
      },
      backgroundColor:
          _modoSeleccionado == modo ? const Color(0xFF6A1B9A) : Colors.white,
      foregroundColor:
          _modoSeleccionado == modo ? Colors.white : const Color(0xFF6A1B9A),
      elevation: 4,
      mini: true,
      child: Icon(icono),
    );
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                          'Seleccionar animal a localizar',
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
                                      ? '${d['nombre_animal']} (${d['especie_animal']}) - Collar ${d['id_dispositivo']}'
                                      : 'Dispositivo - ID ${d['id_dispositivo']}',
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _dispositivoSeleccionado = value;
                            _ultimaDistanciaKm = null;
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
                      if (_dispositivoSeleccionado == null) {
                        Notificador.mostrar(
                          context: context,
                          mensaje: "Debes seleccionar un animal primero",
                          tipo: TipoNotificacion.alerta,
                        );
                      }
                    },
                    icon: const Icon(Icons.alt_route),
                    label: Text('Cargar ruta', style: GoogleFonts.montserrat()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A), // 💜 morado
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      _ultimaDistanciaKm = null;
                      if (_dispositivoSeleccionado != null) {
                        final recorrido =
                            await UbicacionService.obtenerRecorridoUltimoDia(
                              _dispositivoSeleccionado!,
                            );

                        for (var punto in recorrido) {
                          print(
                            '⏱️ ${punto['timestamp']} → 📍 ${punto['latitud']}, ${punto['longitud']}',
                          );
                        }
                        final puntos =
                            recorrido
                                .map((u) => LatLng(u['latitud'], u['longitud']))
                                .toList();

                        setState(() {
                          _polilineas = {
                            Polyline(
                              polylineId: const PolylineId('recorrido'),
                              points: puntos,
                              color: Colors.orange,
                              width: 4,
                            ),
                          };
                        });

                        if (puntos.isNotEmpty) {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngBounds(
                              _boundsFromLatLngList(puntos),
                              60,
                            ),
                          );
                        }
                      }
                      if (_dispositivoSeleccionado == null) {
                        Notificador.mostrar(
                          context: context,
                          mensaje: "Debes seleccionar un animal primero",
                          tipo: TipoNotificacion.alerta,
                        );
                      }
                    },
                    icon: const Icon(Icons.timeline),
                    label: Text(
                      'Recorrido ultimas 24H',
                      style: GoogleFonts.montserrat(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
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

          // Selector flotante de modo de transporte
          Positioned(
            bottom: 140,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBotonModo(Icons.directions_walk, 'foot-walking'),
                const SizedBox(height: 10),
                _buildBotonModo(Icons.directions_car, 'driving-car'),
                const SizedBox(height: 10),
                _buildBotonModo(Icons.directions_bike, 'cycling-regular'),
              ],
            ),
          ),
          if (_ultimaDistanciaKm != null)
            Positioned(
              bottom: 150,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Text(
                  '${_ultimaDistanciaKm!.toStringAsFixed(2)} km',
                  style: GoogleFonts.montserrat(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

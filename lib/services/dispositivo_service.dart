import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../models/dispositivo_model.dart';
import '../models/configuracion_dispositivo.dart';
import 'configuracion_service.dart';
import 'configuracion_mqtt_service.dart';

Future<List<Dispositivo>> obtenerDispositivos() async {
  final response = await http.get(Uri.parse('${baseUrl}dispositivos.php'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Dispositivo.fromJson(e)).toList();
  } else {
    throw Exception('Error al cargar dispositivos');
  }
}

Future<Dispositivo?> crearDispositivo(
  Dispositivo dispositivo,
  int idUsuario,
) async {
  final body = dispositivo.toJson();
  body["id_usuario"] =
      idUsuario.toString(); // Conversión segura

  final response = await http.post(
    Uri.parse('${baseUrl}dispositivos.php'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data["success"] == true) {
      return Dispositivo(
        id: data["id_dispositivo"],
        imei: data["imei"],
        estadoActual: dispositivo.estadoActual,
        numeroCelular: dispositivo.numeroCelular,
      );
    }
  }

  return null;
}

Future<bool> actualizarDispositivo(Dispositivo dispositivo) async {
  final response = await http.put(
    Uri.parse('${baseUrl}dispositivos.php'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(dispositivo.toJson(incluirId: true)),
  );

  final data = jsonDecode(response.body);
  return data["success"] == true;
}

Future<bool> eliminarDispositivo(int idDispositivo) async {
  final response = await http.delete(
    Uri.parse('${baseUrl}dispositivos.php'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({'id_dispositivo': idDispositivo}),
  );

  if (response.body.isEmpty) {
    throw Exception("❌ Respuesta vacía del servidor al eliminar.");
  }

  final data = jsonDecode(response.body);
  return data["success"] == true;
}

// ✅ NUEVO: Crear y configurar automáticamente
Future<Dispositivo?> crearDispositivoYConfigurar(
  Dispositivo dispositivo,
  int idUsuario,
) async {
  final nuevo = await crearDispositivo(dispositivo, idUsuario);
  if (nuevo == null) return null;

  final config = ConfiguracionDispositivo(
    idDispositivo: nuevo.id!,
    imei: nuevo.imei,
    activarHorario: false,
    horaInicio: "22:00:00",
    horaFin: "06:00:00",
    activarSiesta: false,
    horaInicioSiesta: "13:00:00",
    horaFinSiesta: "14:00:00",
    modoAhorro: true,
    frecuenciaGpsMinutos: 15,
    umbralInactividadMin: 30,
  );

  final guardado = await ConfiguracionService().guardarConfiguracion(config);
  if (!guardado) return null;

  await ConfiguracionMqttService().enviarConfiguracion(config);
  return nuevo;
}

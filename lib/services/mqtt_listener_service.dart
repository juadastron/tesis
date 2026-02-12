import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttListenerService {
  final client = MqttServerClient('u3mznfuca.localto.net', 'flutter_client');
  Function(Map<String, dynamic>)? onUbicacionRecibida;

  Future<void> conectar() async {
    client.port = 6373;
    client.logging(on: true); // Activar logs para debug
    client.keepAlivePeriod = 20;
    client.secure = false;
    client.setProtocolV311();

    client.onDisconnected = () => print('❌ MQTT desconectado');
    client.onConnected = () => print('✅ MQTT conectado');
    client.onSubscribed = (topic) => print('📡 Suscrito a $topic');

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .withWillQos(MqttQos.atMostOnce)
        .authenticateAs('tu_usuario', '7kilometrosporta'); // 👈 Agrega autenticación

    client.connectionMessage = connMessage;

    try {
      print('🚀 Conectando al broker...');
      await client.connect();
      client.subscribe('geo_little_paws/ubicacion', MqttQos.atMostOnce);

      client.updates!.listen((event) {
        final recMsg = event[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(recMsg.payload.message);
        print("📩 MQTT recibido: $payload"); // 👈 Asegura que se imprime

        try {
          final data = jsonDecode(payload);
          if (data['tipo_evento'] == 'ubicacion') {
            onUbicacionRecibida?.call(data);
          }
        } catch (e) {
          print("⚠️ Error al decodificar MQTT: $e");
        }
      });
    } catch (e) {
      print('❌ Error al conectar MQTT: $e');
    }
  }

  void desconectar() {
    client.disconnect();
  }
}

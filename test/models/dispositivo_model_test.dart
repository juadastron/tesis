import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/dispositivo_model.dart';

void main() {
  group('Dispositivo Model', () {
    test('fromJson convierte Map a objeto Dispositivo correctamente', () {
      final json = {
        'id_dispositivo': '20',
        'imei': '123456789012345',
        'estado_actual': 'activo',
        'ultima_conexion': '2025-05-24 10:00:00',
        'creado_en': '2025-05-01 12:00:00',
        'nombre_animal': 'Toby',
        'especie_animal': 'Perro',
        'numero_celular': '0999999999',
      };

      final dispositivo = Dispositivo.fromJson(json);

      expect(dispositivo.id, 20);
      expect(dispositivo.imei, '123456789012345');
      expect(dispositivo.estadoActual, 'activo');
      expect(dispositivo.ultimaConexion, '2025-05-24 10:00:00');
      expect(dispositivo.creadoEn, '2025-05-01 12:00:00');
      expect(dispositivo.nombreAnimal, 'Toby');
      expect(dispositivo.especieAnimal, 'Perro');
      expect(dispositivo.numeroCelular, '0999999999');
    });

    test('toJson devuelve Map con todos los campos y con id incluido', () {
      final dispositivo = Dispositivo(
        id: 20,
        imei: '123456789012345',
        estadoActual: 'activo',
        ultimaConexion: '2025-05-24 10:00:00',
        creadoEn: '2025-05-01 12:00:00',
        numeroCelular: '0999999999',
      );

      final json = dispositivo.toJson(incluirId: true);

      expect(json['id_dispositivo'], '20');
      expect(json['imei'], '123456789012345');
      expect(json['estado_actual'], 'activo');
      expect(json['ultima_conexion'], '2025-05-24 10:00:00');
      expect(json['creado_en'], '2025-05-01 12:00:00');
      expect(json['numero_celular'], '0999999999');
    });

    test('toJson sin incluirId no debe tener id_dispositivo', () {
      final dispositivo = Dispositivo(
        id: 99,
        imei: '987654321098765',
        estadoActual: 'inactivo',
      );

      final json = dispositivo.toJson(incluirId: false);

      expect(json.containsKey('id_dispositivo'), false);
      expect(json['imei'], '987654321098765');
      expect(json['estado_actual'], 'inactivo');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/zona_segura_model.dart';

void main() {
  group('ZonaSegura Model', () {
    test('fromJson convierte un Map válido a objeto correctamente', () {
      final json = {
        "id_zona": "9",
        "id_dispositivo": "77",
        "latitud": "-4.0078",
        "longitud": "-79.2023",
        "radio_metros": "50",
        "activo": "1",
      };

      final zona = ZonaSegura.fromJson(json);

      expect(zona.id, 9);
      expect(zona.idDispositivo, 77);
      expect(zona.latitud, -4.0078);
      expect(zona.longitud, -79.2023);
      expect(zona.radioMetros, 50);
      expect(zona.activo, true);
    });

    test('toJson convierte el objeto a Map con todos los campos', () {
      final zona = ZonaSegura(
        id: 5,
        idDispositivo: 33,
        latitud: -3.98,
        longitud: -79.21,
        radioMetros: 100,
        activo: false,
      );

      final json = zona.toJson();

      expect(json['id_zona'], 5);
      expect(json['id_dispositivo'], 33);
      expect(json['latitud'], -3.98);
      expect(json['longitud'], -79.21);
      expect(json['radio_metros'], 100);
      expect(json['activo'], 0);
    });

    test('fromJson maneja valor booleano como true correctamente', () {
      final json = {
        "id_zona": "1",
        "id_dispositivo": "1",
        "latitud": "-4.0",
        "longitud": "-79.2",
        "radio_metros": "30",
        "activo": true, // booleano real
      };

      final zona = ZonaSegura.fromJson(json);

      expect(zona.activo, true);
    });
  });
}

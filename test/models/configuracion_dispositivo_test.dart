import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/configuracion_dispositivo.dart';

void main() {
  group('ConfiguracionDispositivo Model', () {
    test('fromJson crea una instancia correctamente con todos los campos', () {
      final json = {
        "id_config": "5",
        "id_dispositivo": "99",
        "imei": "1234567890",
        "activar_horario_nocturno": "1",
        "hora_inicio_nocturna": "21:00:00",
        "hora_fin_nocturna": "05:30:00",
        "activar_siesta": "1",
        "hora_inicio_siesta": "12:00:00",
        "hora_fin_siesta": "13:30:00",
        "modo_ahorro": "1",
        "frecuencia_gps_minutos": "15",
        "umbral_inactividad_min": "45"
      };

      final config = ConfiguracionDispositivo.fromJson(json);

      expect(config.id, 5);
      expect(config.idDispositivo, 99);
      expect(config.imei, "1234567890");
      expect(config.activarHorario, true);
      expect(config.horaInicio, "21:00:00");
      expect(config.horaFin, "05:30:00");
      expect(config.activarSiesta, true);
      expect(config.horaInicioSiesta, "12:00:00");
      expect(config.horaFinSiesta, "13:30:00");
      expect(config.modoAhorro, true);
      expect(config.frecuenciaGpsMinutos, 15);
      expect(config.umbralInactividadMin, 45);
    });

    test('toJson devuelve un Map correctamente', () {
      final config = ConfiguracionDispositivo(
        id: 5,
        idDispositivo: 99,
        imei: "1234567890",
        activarHorario: true,
        horaInicio: "21:00:00",
        horaFin: "05:30:00",
        activarSiesta: true,
        horaInicioSiesta: "12:00:00",
        horaFinSiesta: "13:30:00",
        modoAhorro: true,
        frecuenciaGpsMinutos: 15,
        umbralInactividadMin: 45,
      );

      final json = config.toJson();

      expect(json["id_dispositivo"], 99);
      expect(json["imei"], "1234567890");
      expect(json["activar_horario_nocturno"], 1);
      expect(json["hora_inicio_nocturna"], "21:00:00");
      expect(json["hora_fin_nocturna"], "05:30:00");
      expect(json["activar_siesta"], 1);
      expect(json["hora_inicio_siesta"], "12:00:00");
      expect(json["hora_fin_siesta"], "13:30:00");
      expect(json["modo_ahorro"], 1);
      expect(json["frecuencia_gps_minutos"], 15);
      expect(json["umbral_inactividad_min"], 45);
    });

    test('fromJson maneja valores nulos y por defecto correctamente', () {
      final json = {
        "id_dispositivo": "50",
        "imei": null,
        "activar_horario_nocturno": null,
        "activar_siesta": null,
        "modo_ahorro": null,
        "frecuencia_gps_minutos": null,
        "umbral_inactividad_min": null,
      };

      final config = ConfiguracionDispositivo.fromJson(json);

      expect(config.idDispositivo, 50);
      expect(config.imei, "");
      expect(config.activarHorario, false);
      expect(config.horaInicio, "22:00:00");
      expect(config.horaFin, "06:00:00");
      expect(config.activarSiesta, false);
      expect(config.horaInicioSiesta, "13:00:00");
      expect(config.horaFinSiesta, "14:00:00");
      expect(config.modoAhorro, false);
      expect(config.frecuenciaGpsMinutos, 10);
      expect(config.umbralInactividadMin, 30);
    });
  });
}

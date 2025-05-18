class ConfiguracionDispositivo {
  final int? id;
  final int idDispositivo;
  final bool activarHorario;
  final String horaInicio;
  final String horaFin;

  final bool activarSiesta;
  final String imei;
  final String horaInicioSiesta;
  final String horaFinSiesta;
  final int umbralInactividadMin;
  final bool modoAhorro;
  final int frecuenciaGpsMinutos;

  ConfiguracionDispositivo({
    this.id,
    required this.idDispositivo,
    required this.imei,
    this.activarHorario = false,
    this.horaInicio = '22:00:00',
    this.horaFin = '06:00:00',
    this.activarSiesta = false,
    this.horaInicioSiesta = '13:00:00',
    this.horaFinSiesta = '14:00:00',
    this.umbralInactividadMin = 30,
    this.modoAhorro = false,
    this.frecuenciaGpsMinutos = 10,
  });

  factory ConfiguracionDispositivo.fromJson(
    Map<String, dynamic> json,
  ) => ConfiguracionDispositivo(
    id: int.tryParse(json['id_config'].toString()),
    idDispositivo: int.parse(json['id_dispositivo'].toString()),
    imei: json['imei'] ?? '',
    activarHorario: json['activar_horario_nocturno'].toString() == '1',
    horaInicio: json['hora_inicio_nocturna'] ?? '22:00:00',
    horaFin: json['hora_fin_nocturna'] ?? '06:00:00',
    activarSiesta: json['activar_siesta'].toString() == '1',
    horaInicioSiesta: json['hora_inicio_siesta'] ?? '13:00:00',
    horaFinSiesta: json['hora_fin_siesta'] ?? '14:00:00',
    umbralInactividadMin:
        int.tryParse(json['umbral_inactividad_min']?.toString() ?? '') ?? 30,
    modoAhorro: json['modo_ahorro'].toString() == '1',
    frecuenciaGpsMinutos:
        int.tryParse(json['frecuencia_gps_minutos']?.toString() ?? '') ?? 10,
  );

  Map<String, dynamic> toJson() => {
    "id_dispositivo": idDispositivo,
    "imei": imei,
    "activar_horario_nocturno": activarHorario ? 1 : 0,
    "hora_inicio_nocturna": horaInicio,
    "hora_fin_nocturna": horaFin,
    "activar_siesta": activarSiesta ? 1 : 0,
    "hora_inicio_siesta": horaInicioSiesta,
    "hora_fin_siesta": horaFinSiesta,
    "modo_ahorro": modoAhorro ? 1 : 0,
    "frecuencia_gps_minutos": frecuenciaGpsMinutos,
    "umbral_inactividad_min": umbralInactividadMin,
  };
}

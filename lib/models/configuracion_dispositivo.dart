class ConfiguracionDispositivo {
  final int? id;
  final int idDispositivo;
  final bool activarHorario;
  final String horaInicio;
  final String horaFin;

  ConfiguracionDispositivo({
    this.id,
    required this.idDispositivo,
    this.activarHorario = false,
    this.horaInicio = '22:00:00',
    this.horaFin = '06:00:00',
  });

  factory ConfiguracionDispositivo.fromJson(Map<String, dynamic> json) =>
      ConfiguracionDispositivo(
        id: int.tryParse(json['id_config'].toString()),
        idDispositivo: int.parse(json['id_dispositivo'].toString()),
        activarHorario: json['activar_horario_nocturno'].toString() == '1' || json['activar_horario_nocturno'] == true,
        horaInicio: json['hora_inicio_nocturna'],
        horaFin: json['hora_fin_nocturna'],
      );
}

class ZonaSegura {
  final int? id;
  final int idDispositivo;
  final double latitud;
  final double longitud;
  final double radioMetros;
  final bool activo;

  ZonaSegura({
    this.id,
    required this.idDispositivo,
    required this.latitud,
    required this.longitud,
    this.radioMetros = 30,
    this.activo = true,
  });

  factory ZonaSegura.fromJson(Map<String, dynamic> json) => ZonaSegura(
        id: int.tryParse(json['id_zona'].toString()),
        idDispositivo: int.parse(json['id_dispositivo'].toString()),
        latitud: double.parse(json['latitud'].toString()),
        longitud: double.parse(json['longitud'].toString()),
        radioMetros: double.parse(json['radio_metros'].toString()),
        activo: json['activo'] == "1" || json['activo'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id_zona': id,
        'id_dispositivo': idDispositivo,
        'latitud': latitud,
        'longitud': longitud,
        'radio_metros': radioMetros,
        'activo': activo ? 1 : 0,
      };
}

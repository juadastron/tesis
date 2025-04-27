class Dispositivo {
  final int? id;
  final String imei;
  final String estadoActual;
  final String? ultimaConexion;
  final String? creadoEn;
  final String? nombreAnimal;
  final String? especieAnimal;

  Dispositivo({
    this.id,
    required this.imei,
    required this.estadoActual,
    this.ultimaConexion,
    this.creadoEn,
    this.nombreAnimal,
    this.especieAnimal,
  });

  factory Dispositivo.fromJson(Map<String, dynamic> json) {
    return Dispositivo(
      id: int.tryParse(json['id_dispositivo'].toString()),
      imei: json['imei'],
      estadoActual: json['estado_actual'],
      ultimaConexion: json['ultima_conexion'],
      creadoEn: json['creado_en'],
      nombreAnimal: json['nombre_animal'],
      especieAnimal: json['especie_animal'],
    );
  }

  Map<String, dynamic> toJson({bool incluirId = false}) {
    final data = {
      'imei': imei,
      'estado_actual': estadoActual,
      'ultima_conexion': ultimaConexion,
      'creado_en': creadoEn,
    };

    if (incluirId && id != null) {
      data['id_dispositivo'] = id.toString();
    }

    return data;
  }
}

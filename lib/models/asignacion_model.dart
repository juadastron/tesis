class Asignacion {
  final int idAsignacion;
  final int idAnimal;
  final String nombreAnimal;
  final String especieAnimal;
  final String fechaInicio;
  final String? fechaFin;

  Asignacion({
    required this.idAsignacion,
    required this.idAnimal,
    required this.nombreAnimal,
    required this.especieAnimal,
    required this.fechaInicio,
    this.fechaFin,
  });

  factory Asignacion.fromJson(Map<String, dynamic> json) {
    return Asignacion(
      idAsignacion: json['id_asignacion'],
      idAnimal: json['id_animal'],
      nombreAnimal: json['nombre_animal'],
      especieAnimal: json['especie_animal'],
      fechaInicio: json['fecha_inicio'],
      fechaFin: json['fecha_fin'],
    );
  }
}

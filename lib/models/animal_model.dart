class Animal {
  final int? id;
  final String nombre;
  final String especie;
  final int? edad;
  final String? color;
  final String? fotoUrl;

  Animal({
    this.id,
    required this.nombre,
    required this.especie,
    this.edad,
    this.color,
    this.fotoUrl,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: int.tryParse(json['id_animal'].toString()),
      nombre: json['nombre'],
      especie: json['especie'],
      edad: json['edad'] != null ? int.tryParse(json['edad'].toString()) : null,
      color: json['color'],
      fotoUrl: json['foto_url'],
    );
  }

  Map<String, dynamic> toJson({bool incluirId = false}) {
    final data = {
      'nombre': nombre,
      'especie': especie,
      'edad': edad,
      'color': color,
      'foto_url': fotoUrl,
    };

    if (incluirId && id != null) {
      data['id_animal'] = id;
    }

    return data;
  }
}

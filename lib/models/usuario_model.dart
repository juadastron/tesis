class Usuario {
  final int? id; // Puede ser null cuando creas uno nuevo
  final String nombre;
  final String email;
  final String rol;
  final String? password; // <-- Nueva propiedad opcional

  Usuario({
    this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.password, // <-- solo se envía si es nuevo
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: int.tryParse(json['id_usuario'].toString()),
      nombre: json['nombre'],
      email: json['email'],
      rol: json['rol'],
    );
  }

  Map<String, dynamic> toJson({bool incluirId = false}) {
    final data = {'nombre': nombre, 'email': email, 'rol': rol};

    if (incluirId && id != null) {
      data['id_usuario'] = id.toString();
    }

    if (password != null) {
      data['password'] = password.toString();
    }

    return data;
  }
}

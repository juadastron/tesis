import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/usuario_model.dart';

void main() {
  group('Usuario Model', () {
    test('fromJson crea correctamente un objeto Usuario', () {
      final json = {
        'id_usuario': '42',
        'nombre': 'Ana Torres',
        'email': 'ana@example.com',
        'rol': 'admin',
      };

      final usuario = Usuario.fromJson(json);

      expect(usuario.id, 42);
      expect(usuario.nombre, 'Ana Torres');
      expect(usuario.email, 'ana@example.com');
      expect(usuario.rol, 'admin');
      expect(usuario.password, isNull); // No debe tener password
    });

    test('toJson sin incluir id ni password', () {
      final usuario = Usuario(
        nombre: 'Luis Soto',
        email: 'luis@example.com',
        rol: 'editor',
      );

      final json = usuario.toJson();

      expect(json.containsKey('id_usuario'), false);
      expect(json.containsKey('password'), false);
      expect(json['nombre'], 'Luis Soto');
      expect(json['email'], 'luis@example.com');
      expect(json['rol'], 'editor');
    });

    test('toJson con incluirId y password', () {
      final usuario = Usuario(
        id: 77,
        nombre: 'Carlos Ruiz',
        email: 'carlos@example.com',
        rol: 'lector',
        password: 'superseguro123',
      );

      final json = usuario.toJson(incluirId: true);

      expect(json['id_usuario'], '77');
      expect(json['nombre'], 'Carlos Ruiz');
      expect(json['email'], 'carlos@example.com');
      expect(json['rol'], 'lector');
      expect(json['password'], 'superseguro123');
    });
  });
}

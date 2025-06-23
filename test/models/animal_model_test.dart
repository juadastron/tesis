import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/animal_model.dart';

void main() {
  group('Animal Model', () {
    test('fromJson convierte Map a Animal correctamente', () {
      final json = {
        'id_animal': '10',
        'nombre': 'Bobby',
        'especie': 'Perro',
        'edad': '4',
        'color': 'Negro',
        'foto_url': 'http://example.com/bobby.jpg',
      };

      final animal = Animal.fromJson(json);

      expect(animal.id, 10);
      expect(animal.nombre, 'Bobby');
      expect(animal.especie, 'Perro');
      expect(animal.edad, 4);
      expect(animal.color, 'Negro');
      expect(animal.fotoUrl, 'http://example.com/bobby.jpg');
    });

    test('toJson convierte Animal a Map correctamente (sin id)', () {
      final animal = Animal(
        nombre: 'Michi',
        especie: 'Gato',
        edad: 3,
        color: 'Blanco',
        fotoUrl: null,
      );
      final json = animal.toJson();

      expect(json.containsKey('id_animal'), false);
      expect(json['nombre'], 'Michi');
      expect(json['especie'], 'Gato');
      expect(json['edad'], 3);
      expect(json['color'], 'Blanco');
      expect(json['foto_url'], null);
    });

    test('toJson con incluirId agrega id al Map', () {
      final animal = Animal(
        id: 99,
        nombre: 'Loro',
        especie: 'Ave',
      );

      final json = animal.toJson(incluirId: true);

      expect(json['id_animal'], 99);
    });
  });
}

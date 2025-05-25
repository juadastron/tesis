import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/asignacion_model.dart';

void main() {
  group('Asignacion Model', () {
    test('fromJson convierte correctamente el Map en Asignacion', () {
      final json = {
        "id_asignacion": 7,
        "id_animal": 12,
        "nombre_animal": "Rocky",
        "especie_animal": "Perro",
        "fecha_inicio": "2025-05-01",
        "fecha_fin": "2025-05-15",
      };

      final asignacion = Asignacion.fromJson(json);

      expect(asignacion.idAsignacion, 7);
      expect(asignacion.idAnimal, 12);
      expect(asignacion.nombreAnimal, 'Rocky');
      expect(asignacion.especieAnimal, 'Perro');
      expect(asignacion.fechaInicio, '2025-05-01');
      expect(asignacion.fechaFin, '2025-05-15');
    });

    test('fromJson maneja fechaFin nula correctamente', () {
      final json = {
        "id_asignacion": 8,
        "id_animal": 13,
        "nombre_animal": "Luna",
        "especie_animal": "Gato",
        "fecha_inicio": "2025-05-01",
        "fecha_fin": null,
      };

      final asignacion = Asignacion.fromJson(json);

      expect(asignacion.fechaFin, isNull);
    });
  });
}

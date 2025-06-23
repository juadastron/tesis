import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/pages/dispositivos_page.dart';
import 'package:flutter_application_1/providers/user_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Prueba funcional - DispositivosPage', () {
    testWidgets('Crear dispositivo con estado disponible y mostrar alerta si no se puede eliminar', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => UserProvider()
                ..setUser(
                  idUsuario: 1,
                  nombre: "Admin",
                  email: "admin@gmail.com",
                  rol: "admin",
                ),
            ),
          ],
          child: const MaterialApp(home: DispositivosPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap en botón para crear nuevo dispositivo
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Ingresar datos
      await tester.enterText(find.bySemanticsLabel('Número'), '0991234567');
      await tester.enterText(find.bySemanticsLabel('IMEI'), '490154203237518');

      // Guardar
      final guardarBtn = find.text('Guardar');
      await tester.tap(guardarBtn);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifica que el dispositivo aparece y tiene estado disponible
      final estadoDisponible = find.textContaining('Estado: disponible');
      expect(estadoDisponible, findsWidgets);

      // Tap en ícono de eliminar dispositivo
      final eliminarBtn = find.byIcon(Icons.delete).first;
      await tester.tap(eliminarBtn);
      await tester.pumpAndSettle();

      // Si el dispositivo está asignado o no disponible, se debe mostrar el AlertDialog de no eliminable
      if (find.textContaining('no se puede eliminar').evaluate().isNotEmpty ||
          find.textContaining('debes desvincularlo primero').evaluate().isNotEmpty) {
        expect(find.textContaining('debes desvincularlo primero'), findsOneWidget);
        final irBtn = find.text('Ir a Animales');
        await tester.tap(irBtn);
        await tester.pumpAndSettle();
        expect(find.textContaining('Animales'), findsWidgets);
      }
    });
  });
}

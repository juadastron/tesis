import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/pages/dispositivos_page.dart';
import 'package:flutter_application_1/providers/user_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Prueba funcional - Historial de Asignaciones', () {
    testWidgets('Visualiza historial o muestra mensaje si no hay', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => UserProvider()
                ..setUser(
                  idUsuario: 1,
                  nombre: 'Admin',
                  email: 'admin@gmail.com',
                  rol: 'admin',
                ),
            ),
          ],
          child: const MaterialApp(home: DispositivosPage()),
        ),
      );
      await tester.pumpAndSettle();

      // ✅ Toca el botón de historial (ícono de reloj)
      final historialBtn = find.byIcon(Icons.history).last;
      expect(historialBtn, findsOneWidget);
      await tester.tap(historialBtn);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ✅ Verifica que se cargue el contenido o muestre mensaje de vacío
      final tituloDialogo = find.text('Historial de Asignaciones');
      final sinHistorial = find.textContaining('No hay historial disponible');
      final tieneAnimales = find.textContaining('Inicio:');

      expect(tituloDialogo, findsOneWidget);
      expect(sinHistorial.evaluate().isNotEmpty || tieneAnimales.evaluate().isNotEmpty, true,
          reason: 'Debe mostrarse historial o mensaje de que no hay datos');

      // ✅ Cierra el diálogo
      final cerrarBtn = find.text('Cerrar');
      await tester.tap(cerrarBtn);
      await tester.pumpAndSettle();
      expect(find.text('Historial de Asignaciones'), findsNothing);
    });
  });
}

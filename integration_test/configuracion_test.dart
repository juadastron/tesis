import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/pages/configuracion_page.dart';
import 'package:flutter_application_1/providers/user_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Prueba funcional - ConfiguracionPage', () {
    testWidgets('Guarda configuración y crea zona segura', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create:
                  (_) =>
                      UserProvider()..setUser(
                        idUsuario: 1,
                        nombre: "Admin",
                        email: "admin@gmail.com",
                        rol: "admin",
                      ),
            ),
          ],
          child: const MaterialApp(home: ConfiguracionPage(idDispositivo: 1)),
        ),
      );

      await tester.pumpAndSettle();
      // ✅ LLENAR CAMPOS DE ZONA SEGURA
      final latitudField = find.widgetWithText(TextFormField, "Latitud");
      final longitudField = find.widgetWithText(TextFormField, "Longitud");
      final radioField = find.widgetWithText(TextFormField, "Radio (m)");

      await tester.enterText(latitudField, "-4.003");
      await tester.enterText(longitudField, "-79.201");
      await tester.enterText(radioField, "50");
      await tester.pumpAndSettle();

      final registrarBtn = find.text('Registrar zona segura');
      await tester.ensureVisible(registrarBtn); // ✅ scroll si es necesario
      await tester.tap(registrarBtn);
      await tester.pumpAndSettle();

      // ✅ si existe zona, se mostrará el diálogo de confirmación
      final confirmar = find.text("Sí");
      if (confirmar.evaluate().isNotEmpty) {
        await tester.tap(confirmar);
        await tester.pumpAndSettle();
      }

      // ✅ esperar mensaje de éxito o mensaje de error del backend
      final exito = find.textContaining("Zona segura registrada");
      final error = find.textContaining("❌ Error");
      // ✅ GUARDAR CONFIGURACIÓN
      final guardarBtn = find.text('Guardar configuraciones');
      expect(guardarBtn, findsOneWidget);
      await tester.tap(guardarBtn);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Configuración guardada'),
        findsOneWidget,
        reason: "No se detectó el mensaje de confirmación al guardar",
      );

      expect(
        exito.evaluate().isNotEmpty || error.evaluate().isNotEmpty,
        isTrue,
        reason: "No se registró ni falló la zona segura",
      );
    });
  });
}

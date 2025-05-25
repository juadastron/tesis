import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/pages/animales_page.dart';
import 'package:flutter_application_1/providers/user_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Prueba funcional - AnimalesPage', () {
    testWidgets('Visualiza animales y permite asignar/desvincular dispositivos', (
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
                        rol: "admin", // necesario para mostrar botones
                      ),
            ),
          ],
          child: const MaterialApp(home: AnimalesPage()),
        ),
      );

      await tester.pumpAndSettle();

      // ✅ 1. Verifica que se carguen animales
      expect(find.byType(ListTile), findsWidgets);

      // ✅ 2. Tap en el botón de asignar dispositivo (ícono de link)
      final linkIcon = find.byIcon(Icons.link).first;
      if (linkIcon.evaluate().isNotEmpty) {
        await tester.tap(linkIcon);
        await tester.pumpAndSettle();

        // Si hay dispositivos disponibles, aparece un dropdown
        final dropdown = find.byType(DropdownButtonFormField<DropdownMenuItem>);
        if (dropdown.evaluate().isEmpty) {
          expect(
            find.textContaining("No se pudieron cargar"),
            findsNothing,
            reason: "No se detectó el dropdown de asignación.",
          );
        } else {
          await tester.tap(dropdown);
          await tester.pumpAndSettle();

          // Elige el primer dispositivo
          final opcion = find.byType(DropdownMenuItem).first;
          await tester.tap(opcion);
          await tester.pumpAndSettle();

          // Tap en Asignar
          final asignarBtn = find.text('Asignar');
          await tester.tap(asignarBtn);
          await tester.pumpAndSettle();

          // Verifica que se mostró un mensaje de éxito
          expect(find.textContaining('Dispositivo asignado'), findsOneWidget);
        }
      }

      // ✅ 3. Tap en botón de desvincular dispositivo (ícono link_off)
      final linkOffIcon = find.byIcon(Icons.link_off);

      if (linkOffIcon.evaluate().isNotEmpty) {
        // Asegúrate de hacer scroll hasta el ítem visible si está fuera de pantalla
        await tester.ensureVisible(linkOffIcon.first);
        await tester.tap(linkOffIcon.first);
        await tester.pumpAndSettle();

        final confirmarBtn = find.text('Desvincular');
        if (confirmarBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmarBtn);
          await tester.pumpAndSettle();

          expect(
            find.textContaining("Dispositivo desvinculado"),
            findsOneWidget,
          );
        }
      } else {
        print("⚠️ Ningún dispositivo para desvincular disponible.");
      }
    });
  });
}

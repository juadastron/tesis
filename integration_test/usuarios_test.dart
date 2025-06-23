import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/usuarios_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/user_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Prueba funcional - UsuariosPage', () {
    testWidgets('Crear, editar y eliminar usuario', (tester) async {
      // Simula sesión como admin
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => UserProvider()
                ..setUser(
                  idUsuario: 9999,
                  nombre: 'AdminTest',
                  email: 'admin@test.com',
                  rol: 'admin',
                ),
            ),
          ],
          child: const MaterialApp(home: UsuariosPage()),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ───── CREAR USUARIO ─────
      final fab = find.byIcon(Icons.add);
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Nuevo Usuario',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'nuevooo@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        '123456',
      );

      final rolDropdown = find.byType(DropdownButtonFormField<String>);
      await tester.tap(rolDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Voluntario').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Nuevo Usuario'), findsWidgets);

      // ───── EDITAR USUARIO ─────
      final editarBtn = find.widgetWithIcon(IconButton, Icons.edit).first;
      await tester.tap(editarBtn);
      await tester.pumpAndSettle();

      final nombreCampo = find.widgetWithText(TextFormField, 'Nombre');
      await tester.enterText(nombreCampo, 'Usuario Editado');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Usuario Editado'), findsWidgets);

      // ───── ELIMINAR USUARIO ─────
      final eliminarBtn = find.widgetWithIcon(IconButton, Icons.delete).first;
      await tester.tap(eliminarBtn);
      await tester.pumpAndSettle();

      // Confirmar en el AlertDialog
      final confirmar = find.text('Eliminar');
      expect(confirmar, findsOneWidget);
      await tester.tap(confirmar);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Validar que el usuario ya no aparece
      expect(find.text('Usuario Editado'), findsNothing);
    });
  });
}

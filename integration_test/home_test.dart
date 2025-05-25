import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/mapa_page.dart';
import 'package:flutter_application_1/providers/user_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Prueba funcional - HomePage', () {
    testWidgets('Carga datos, muestra mapa, drawer y logout', (tester) async {
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
          child: MaterialApp(
            home: const HomePage(),
            routes: {
              '/mapa': (_) => const MapaPage(),
              '/login': (_) => const Scaffold(body: Text('Login')),
              '/usuarios': (_) => const Scaffold(body: Text('Usuarios')),
              '/animales': (_) => const Scaffold(body: Text('Animales')),
              '/dispositivos': (_) => const Scaffold(body: Text('Collares')),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ✅ Verifica que cargue título y contenido
      expect(find.text('Geo Little Paws'), findsOneWidget);
      expect(find.textContaining('peluditos'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);

      // ✅ Presiona "Ver mapa" y vuelve atrás usando botón de retroceso
      final btnMapa = find.text('Ver mapa');
      expect(btnMapa, findsOneWidget);
      await tester.tap(btnMapa);
      await tester.pumpAndSettle();

      final backBtn = find.byTooltip('Back');
      if (backBtn.evaluate().isNotEmpty) {
        await tester.tap(backBtn);
        await tester.pumpAndSettle();
      }

      // ✅ Abre Drawer
      final scaffoldState =
          tester.state(find.byType(Scaffold)) as ScaffoldState;
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // ✅ Navega por las opciones del Drawer
      if (find.text('Usuarios').evaluate().isNotEmpty) {
        await tester.tap(find.text('Usuarios'));
        await tester.pumpAndSettle();
        expect(find.text('Usuarios'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        scaffoldState.openDrawer();
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Animales'));
      await tester.pumpAndSettle();
      expect(find.text('Animales'), findsOneWidget);
      if (backBtn.evaluate().isNotEmpty) {
        await tester.tap(backBtn);
        await tester.pumpAndSettle();
      }
      await tester.pumpAndSettle();
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Collares'));
      await tester.pumpAndSettle();
      expect(find.text('Collares'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // ✅ Cierra sesión desde Drawer
      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);

      // ✅ Vuelve a abrir Home y cierra sesión con ícono inferior
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
          child: MaterialApp(
            home: const HomePage(),
            routes: {'/login': (_) => const Scaffold(body: Text('Login'))},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final logoutIcon = find.byIcon(Icons.logout).last;
      await tester.tap(logoutIcon);
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);
    });
  });
}

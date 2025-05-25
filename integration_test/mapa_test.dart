import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/mapa_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_application_1/providers/user_provider.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Prueba funcional - MapaPage', () {
    testWidgets('Cargar ruta y recorrido en MapaPage como admin', (tester) async {
      // Inicia app con usuario admin
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
          child: const MaterialApp(home: MapaPage()),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifica título y mapa
      expect(find.text('Ubicación de los animales'), findsOneWidget);
      expect(find.byType(GoogleMap), findsOneWidget);

      // Abre y selecciona del Dropdown
      final dropdown = find.byType(DropdownButton<String>);
      expect(dropdown, findsOneWidget);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final opciones = find.byType(DropdownMenuItem<String>);
      expect(opciones, findsWidgets);
      await tester.tap(opciones.first);
      await tester.pumpAndSettle();

      // Presiona "Cargar ruta"
      final btnRuta = find.text('Cargar ruta');
      expect(btnRuta, findsOneWidget);
      await tester.tap(btnRuta);
      await tester.pump(const Duration(seconds: 15)); // esperar carga

      // Presiona "Recorrido ultimas 24H"
      final btnRecorrido = find.text('Recorrido ultimas 24H');
      expect(btnRecorrido, findsOneWidget);
      await tester.tap(btnRecorrido);
      await tester.pump(const Duration(seconds: 15)); // esperar carga

      // Espera hasta que aparezca un widget que contenga "km"
      bool encontrado = false;
      const timeout = Duration(seconds: 15);
      final inicio = DateTime.now();

      while (DateTime.now().difference(inicio) < timeout) {
        await tester.pump(const Duration(milliseconds: 500));
        final etiquetaDistancia = find.textContaining('km');
        if (etiquetaDistancia.evaluate().isNotEmpty) {
          encontrado = true;
          break;
        }
      }

      expect(encontrado, isTrue, reason: 'La etiqueta con la distancia no apareció');

      // Captura opcional
      await binding.takeScreenshot('mapa_ruta_y_recorrido');
    });
  });
}

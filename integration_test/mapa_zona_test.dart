import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/MapaZonaPage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_application_1/providers/user_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Prueba funcional - MapaZonaPage', () {
    testWidgets('Mostrar zona segura en el mapa como admin', (tester) async {
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
          child: const MaterialApp(
            home: MapaZonaPage(
              latitud: -3.99313,
              longitud: -79.20422,
              radioMetros: 100.0,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que se muestra el título
      expect(find.text("🗺️ Zona Segura en el Mapa"), findsOneWidget);

      // Verificar que se carga el widget GoogleMap
      expect(find.byType(GoogleMap), findsOneWidget);
    });
  });
}

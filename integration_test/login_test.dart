import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/pages/splash_screen.dart';
import 'package:flutter_application_1/providers/user_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        home: const LoginScreen(),
        routes: {
          '/splash': (_) => const SplashScreen(),
        },
      ),
    );
  }

  group('Prueba funcional - Login', () {
    testWidgets('Ingreso correcto con datos válidos', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final correoField = find.byType(TextFormField).at(0);
      final passField = find.byType(TextFormField).at(1);
      final ingresarBtn = find.text('Ingresar');

      await tester.enterText(correoField, 'admin@gmail.com');
      await tester.enterText(passField, '123456');
      await tester.tap(ingresarBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('Valida campos vacíos', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final ingresarBtn = find.text('Ingresar');
      await tester.tap(ingresarBtn);
      await tester.pump();

      expect(find.text('Por favor ingresa tu correo'), findsOneWidget);
      expect(find.text('Por favor ingresa tu contraseña'), findsOneWidget);
    });
  });
}

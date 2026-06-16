import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/gastos/data/gasto_repository_local.dart';
import 'features/gastos/screens/lista_gastos_screen.dart';

void main() {
  runApp(const TuAhorroApp());
}

class TuAhorroApp extends StatelessWidget {
  const TuAhorroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuAhorro',
      debugShowCheckedModeBanner: false,
      // Localización para español colombiano (formatos de fecha y moneda).
      locale: const Locale('es', 'CO'),
      supportedLocales: const [Locale('es', 'CO')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20), // Verde oscuro fintech
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: ListaGastosScreen(
        repository: GastoRepositoryLocal(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/theme_controller.dart';
import 'core/theme/theme_scope.dart';
import 'features/gastos/data/gasto_repository_local.dart';
import 'features/gastos/screens/lista_gastos_screen.dart';

void main() {
  runApp(const TuAhorroApp());
}

class TuAhorroApp extends StatefulWidget {
  const TuAhorroApp({super.key});

  @override
  State<TuAhorroApp> createState() => _TuAhorroAppState();
}

class _TuAhorroAppState extends State<TuAhorroApp> {
  final _themeController = ThemeController();

  @override
  void initState() {
    super.initState();
    _themeController.addListener(_onThemeChanged);
    _themeController.load();
  }

  void _onThemeChanged() => setState(() {});

  @override
  void dispose() {
    _themeController.removeListener(_onThemeChanged);
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = _themeController.current;
    return ThemeScope(
      controller: _themeController,
      child: MaterialApp(
        title: 'TuAhorro',
        debugShowCheckedModeBanner: false,
        locale: const Locale('es', 'CO'),
        supportedLocales: const [Locale('es', 'CO')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: appTheme.toThemeData(),
        darkTheme: appTheme.toDarkThemeData(),
        home: ListaGastosScreen(
          repository: GastoRepositoryLocal(),
        ),
      ),
    );
  }
}

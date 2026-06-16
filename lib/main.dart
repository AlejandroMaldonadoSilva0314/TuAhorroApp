import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'features/gastos/data/gasto_repository_local.dart';
import 'features/gastos/logic/notificacion_service.dart';
import 'features/gastos/logic/settings_service.dart';
import 'features/gastos/models/app_settings.dart';
import 'features/gastos/screens/lista_gastos_screen.dart';
import 'features/gastos/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacionService().init();
  final settings = await SettingsService().cargar();
  runApp(TuAhorroApp(initialSettings: settings));
}

class TuAhorroApp extends StatefulWidget {
  const TuAhorroApp({super.key, required this.initialSettings});

  final AppSettings initialSettings;

  @override
  State<TuAhorroApp> createState() => _TuAhorroAppState();
}

class _TuAhorroAppState extends State<TuAhorroApp> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  ThemeMode get _themeMode {
    switch (_settings.tema) {
      case TemaApp.claro:
        return ThemeMode.light;
      case TemaApp.oscuro:
        return ThemeMode.dark;
      case TemaApp.sistema:
        return ThemeMode.system;
    }
  }

  ThemeData _buildTheme(Brightness brightness) {
    return brightness == Brightness.dark ? AppTheme.dark() : AppTheme.light();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuAhorro',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'CO'),
      supportedLocales: const [Locale('es', 'CO')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _themeMode,
      home: _settings.onboardingCompletado
          ? ListaGastosScreen(
              repository: GastoRepositoryLocal(),
              onSettingsChanged: (s) => setState(() => _settings = s),
            )
          : OnboardingScreen(
              repository: GastoRepositoryLocal(),
              onCompleted: (s) => setState(() => _settings = s),
            ),
    );
  }
}

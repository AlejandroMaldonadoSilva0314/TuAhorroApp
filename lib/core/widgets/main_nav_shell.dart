import 'package:flutter/material.dart';

import '../../features/ajustes/screens/ajustes_screen.dart';
import '../../features/bolsillos/data/bolsillo_repository.dart';
import '../../features/bolsillos/screens/bolsillos_screen.dart';
import '../../features/gastos/data/gasto_repository.dart';
import '../../features/gastos/screens/lista_gastos_screen.dart';
import '../../features/metas/data/meta_repository.dart';
import '../../features/metas/screens/metas_screen.dart';
import '../theme/app_theme.dart';

class MainNavShell extends StatefulWidget {
  const MainNavShell({super.key, required this.repository});

  final GastoRepository repository;

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  int _tabActual = 0;
  late final BolsilloRepository _bolsillos;
  late final MetaRepository _metas;

  @override
  void initState() {
    super.initState();
    _bolsillos = BolsilloRepository();
    _metas = MetaRepository();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base900,
      body: IndexedStack(
        index: _tabActual,
        children: [
          ListaGastosScreen(repository: widget.repository),
          BolsillosScreen(repository: _bolsillos),
          MetasScreen(repository: _metas),
          AjustesScreen(repository: widget.repository),
        ],
      ),
      bottomNavigationBar: _NavBar(
        tabActual: _tabActual,
        onCambio: (i) => setState(() => _tabActual = i),
      ),
    );
  }
}

// ── NAVIGATION BAR PREMIUM ──────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  const _NavBar({required this.tabActual, required this.onCambio});

  final int tabActual;
  final ValueChanged<int> onCambio;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface100,
        border: const Border(
          top: BorderSide(color: AppColors.outlineDim, width: 1),
        ),
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        selectedIndex: tabActual,
        onDestinationSelected: onCambio,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 64,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Bolsillos',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag_rounded),
            label: 'Metas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}

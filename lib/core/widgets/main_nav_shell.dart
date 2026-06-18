import 'package:flutter/material.dart';

import '../../features/bolsillos/data/bolsillo_repository.dart';
import '../../features/bolsillos/screens/bolsillos_screen.dart';
import '../../features/gastos/data/gasto_repository.dart';
import '../../features/gastos/screens/ajustes_screen.dart';
import '../../features/gastos/screens/lista_gastos_screen.dart';
import '../../features/metas/data/meta_repository.dart';
import '../../features/metas/screens/metas_screen.dart';
import '../theme/app_design_system.dart';

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
      body: IndexedStack(
        index: _tabActual,
        children: [
          ListaGastosScreen(repository: widget.repository),
          BolsillosScreen(repository: _bolsillos),
          MetasScreen(repository: _metas),
          AjustesScreen(
            repository: widget.repository,
            onSettingsChanged: (_) {},
          ),
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
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        boxShadow: AppShadows.navBar,
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
        selectedIndex: tabActual,
        onDestinationSelected: onCambio,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 68,
        destinations: const [
          NavigationDestination(
            icon:         Icon(Icons.home_outlined,                   size: 24),
            selectedIcon: Icon(Icons.home_rounded,                    size: 24),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon:         Icon(Icons.account_balance_wallet_outlined,  size: 24),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded,   size: 24),
            label: 'Bolsillos',
          ),
          NavigationDestination(
            icon:         Icon(Icons.rocket_launch_outlined, size: 24),
            selectedIcon: Icon(Icons.rocket_launch_rounded,  size: 24),
            label: 'Metas',
          ),
          NavigationDestination(
            icon:         Icon(Icons.tune_outlined,  size: 24),
            selectedIcon: Icon(Icons.tune_rounded,   size: 24),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}

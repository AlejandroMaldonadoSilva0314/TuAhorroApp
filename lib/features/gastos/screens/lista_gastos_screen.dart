import 'package:flutter/material.dart';

import '../data/gasto_repository.dart';
import '../logic/insights_calculator.dart';
import '../logic/plata_para_hoy.dart';
import '../logic/presupuesto_semanal.dart';
import '../logic/transaccion_filter.dart';
import '../models/categoria.dart';
import '../models/gasto.dart';
import '../models/transaccion_filtro.dart';
import '../widgets/dashboard_resumen.dart';
import '../models/bolsillo.dart';
import '../widgets/gasto_card.dart';
import 'bolsillos_screen.dart';
import 'categorias_screen.dart';
import 'estadisticas_screen.dart';
import 'fiados_screen.dart';
import 'insights_screen.dart';
import 'metas_screen.dart';
import 'ajustes_screen.dart';
import 'registro_screen.dart';

class ListaGastosScreen extends StatefulWidget {
  const ListaGastosScreen({
    super.key,
    required this.repository,
    this.onSettingsChanged,
  });

  final GastoRepository repository;
  final void Function(dynamic)? onSettingsChanged;

  @override
  State<ListaGastosScreen> createState() => _ListaGastosScreenState();
}

class _ListaGastosScreenState extends State<ListaGastosScreen> {
  List<Gasto> _gastos = [];
  List<Gasto> _gastosFiltrados = [];
  List<Bolsillo> _bolsillos = [];
  List<Categoria> _categorias = [];
  double _presupuesto = 0;
  List<String> _insightMensajes = [];
  bool _cargando = true;
  String? _error;
  TransaccionFiltro _filtro = TransaccionFiltro.vacio;
  final _filter = TransaccionFilter();
  final _busquedaController = TextEditingController();
  bool _mostrarBusqueda = false;

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _aplicarFiltros() {
    setState(() {
      _gastosFiltrados = _filter.aplicar(_gastos, _filtro);
    });
  }

  void _limpiarFiltros() {
    _busquedaController.clear();
    setState(() {
      _filtro = TransaccionFiltro.vacio;
      _gastosFiltrados = _gastos;
      _mostrarBusqueda = false;
    });
  }

  Future<void> _cargarGastos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final resultados = await Future.wait([
        widget.repository.obtenerGastos(),
        widget.repository.obtenerPresupuestoSemanal(),
        widget.repository.obtenerBolsillos(),
        widget.repository.obtenerCategorias(),
      ]);
      if (mounted) {
        setState(() {
          _gastos = resultados[0] as List<Gasto>;
          _presupuesto = resultados[1] as double;
          _bolsillos = resultados[2] as List<Bolsillo>;
          _categorias = resultados[3] as List<Categoria>;
          _insightMensajes = InsightsCalculator(
            nombreCategoria: _nombreCategoria,
          ).calcular(_gastos).mensajes;
          _gastosFiltrados = _filter.aplicar(_gastos, _filtro);
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar los gastos.';
          _cargando = false;
        });
      }
    }
  }

  Future<void> _eliminarGasto(String id) async {
    await widget.repository.eliminarGasto(id);
    await _cargarGastos();
  }

  double get _totalIngresos => _gastos
      .where((g) => g.tipo == TipoTransaccion.ingreso)
      .fold(0, (sum, g) => sum + g.monto);

  double get _totalGastos => _gastos
      .where((g) => g.tipo == TipoTransaccion.gasto)
      .fold(0, (sum, g) => sum + g.monto);

  double get _saldo => _totalIngresos - _totalGastos;

  double get _gastadoSemana =>
      PresupuestoSemanal().gastadoEstaSemana(_gastos);

  double get _disponibleSemana =>
      _presupuesto > 0 ? PresupuestoSemanal().disponible(presupuesto: _presupuesto, gastos: _gastos) : 0;

  double get _plataParaHoy => PlataParaHoy().calcular(
        saldo: _saldo,
        disponibleSemanal: _presupuesto > 0 ? _disponibleSemana : null,
      );

  Future<void> _actualizarPresupuesto(double monto) async {
    await widget.repository.guardarPresupuestoSemanal(monto);
    setState(() => _presupuesto = monto);
  }

  String _nombreCategoria(String id) =>
      _categorias.where((c) => c.id == id).firstOrNull?.nombre ?? id;

  void _navegarA(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
    await _cargarGastos();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TuAhorro',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _mostrarBusqueda ? Icons.search_off_rounded : Icons.search_rounded,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _mostrarBusqueda = !_mostrarBusqueda;
                if (!_mostrarBusqueda) {
                  _busquedaController.clear();
                  _filtro = _filtro.copyWith(limpiarBusqueda: true);
                  _aplicarFiltros();
                }
              });
            },
            tooltip: 'Buscar',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _cargarGastos,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarA(RegistroScreen(
          onGuardar: widget.repository.agregarGasto,
          bolsillos: _bolsillos,
          categorias: _categorias,
        )),
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.15),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: 0,
          onDestinationSelected: (index) {
            switch (index) {
              case 1:
                _navegarA(EstadisticasScreen(repository: widget.repository));
              case 2:
                _navegarA(BolsillosScreen(repository: widget.repository));
              case 3:
                _mostrarMenuMas();
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Estadísticas',
            ),
            NavigationDestination(
              icon: Icon(Icons.wallet_outlined),
              selectedIcon: Icon(Icons.wallet_rounded),
              label: 'Bolsillos',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz_rounded),
              selectedIcon: Icon(Icons.more_horiz_rounded),
              label: 'Más',
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarMenuMas() {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.auto_awesome_rounded,
              label: 'Insights',
              color: cs.primary,
              onTap: () {
                Navigator.pop(ctx);
                _navegarA(InsightsScreen(repository: widget.repository));
              },
            ),
            _MenuTile(
              icon: Icons.flag_rounded,
              label: 'Metas de ahorro',
              color: cs.primary,
              onTap: () {
                Navigator.pop(ctx);
                _navegarA(MetasScreen(repository: widget.repository));
              },
            ),
            _MenuTile(
              icon: Icons.handshake_outlined,
              label: 'Fiados',
              color: cs.primary,
              onTap: () {
                Navigator.pop(ctx);
                _navegarA(FiadosScreen(repository: widget.repository));
              },
            ),
            _MenuTile(
              icon: Icons.category_rounded,
              label: 'Categorías',
              color: cs.primary,
              onTap: () {
                Navigator.pop(ctx);
                _navegarA(CategoriasScreen(repository: widget.repository));
              },
            ),
            _MenuTile(
              icon: Icons.settings_rounded,
              label: 'Ajustes',
              color: cs.primary,
              onTap: () {
                Navigator.pop(ctx);
                _navegarA(AjustesScreen(
                  repository: widget.repository,
                  onSettingsChanged: (s) {
                    widget.onSettingsChanged?.call(s);
                  },
                ));
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48,
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 16),
            FilledButton(onPressed: _cargarGastos, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    if (_gastos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_long_outlined, size: 48,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 20),
            Text('No hay movimientos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Toca + para agregar el primero',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    final headerWidgets = <Widget>[
      DashboardResumen(
        ingresos: _totalIngresos,
        gastos: _totalGastos,
        saldo: _saldo,
        plataParaHoy: _plataParaHoy,
        presupuestoSemanal: _presupuesto,
        gastadoSemana: _gastadoSemana,
        disponibleSemana: _disponibleSemana,
        onEditarPresupuesto: _actualizarPresupuesto,
        insightMensajes: _insightMensajes,
        onTapInsights: () => _navegarA(InsightsScreen(repository: widget.repository)),
      ),
    ];

    if (_mostrarBusqueda) {
      headerWidgets.add(_buildBarraBusqueda());
    }

    headerWidgets.add(_buildChipsFiltro());

    if (_filtro.estaActivo) {
      headerWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                '${_gastosFiltrados.length} resultado${_gastosFiltrados.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _limpiarFiltros,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Limpiar'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      );
    }

    headerWidgets.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Text(
          'Movimientos recientes',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
        ),
      ),
    );

    return RefreshIndicator(
      onRefresh: _cargarGastos,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 0, bottom: 80),
        itemCount: _gastosFiltrados.length + headerWidgets.length,
        itemBuilder: (context, index) {
          if (index < headerWidgets.length) {
            return headerWidgets[index];
          }
          final gasto = _gastosFiltrados[index - headerWidgets.length];
          return GastoCard(
            gasto: gasto,
            categorias: _categorias,
            onEliminar: () => _eliminarGasto(gasto.id),
          );
        },
      ),
    );
  }

  Widget _buildBarraBusqueda() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _busquedaController,
        decoration: InputDecoration(
          hintText: 'Buscar por título...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _busquedaController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _busquedaController.clear();
                    _filtro = _filtro.copyWith(limpiarBusqueda: true);
                    _aplicarFiltros();
                  },
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        ),
        onChanged: (valor) {
          _filtro = valor.isEmpty
              ? _filtro.copyWith(limpiarBusqueda: true)
              : _filtro.copyWith(busqueda: valor);
          _aplicarFiltros();
        },
      ),
    );
  }

  Widget _buildChipsFiltro() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          FilterChip(
            label: const Text('Ingreso'),
            selected: _filtro.tipo == TipoTransaccion.ingreso,
            onSelected: (sel) {
              setState(() {
                _filtro = sel
                    ? _filtro.copyWith(tipo: TipoTransaccion.ingreso)
                    : _filtro.copyWith(limpiarTipo: true);
              });
              _aplicarFiltros();
            },
            selectedColor: colorScheme.primaryContainer,
          ),
          FilterChip(
            label: const Text('Gasto'),
            selected: _filtro.tipo == TipoTransaccion.gasto,
            onSelected: (sel) {
              setState(() {
                _filtro = sel
                    ? _filtro.copyWith(tipo: TipoTransaccion.gasto)
                    : _filtro.copyWith(limpiarTipo: true);
              });
              _aplicarFiltros();
            },
            selectedColor: colorScheme.primaryContainer,
          ),
          ChoiceChip(
            label: Text(_filtro.categoriaId != null
                ? _nombreCategoria(_filtro.categoriaId!)
                : 'Categoría'),
            selected: _filtro.categoriaId != null,
            onSelected: (_) => _mostrarSelectorCategoria(),
            avatar: _filtro.categoriaId != null
                ? GestureDetector(
                    onTap: () {
                      _filtro = _filtro.copyWith(limpiarCategoria: true);
                      _aplicarFiltros();
                    },
                    child: const Icon(Icons.close, size: 16),
                  )
                : null,
          ),
          ActionChip(
            label: Text(
              _filtro.fechaDesde != null || _filtro.fechaHasta != null
                  ? _formatoRangoFechas()
                  : 'Fechas',
            ),
            avatar: _filtro.fechaDesde != null || _filtro.fechaHasta != null
                ? GestureDetector(
                    onTap: () {
                      _filtro = _filtro.copyWith(
                        limpiarFechaDesde: true,
                        limpiarFechaHasta: true,
                      );
                      _aplicarFiltros();
                    },
                    child: const Icon(Icons.close, size: 16),
                  )
                : const Icon(Icons.date_range, size: 16),
            onPressed: _mostrarSelectorFechas,
          ),
        ],
      ),
    );
  }

  void _mostrarSelectorCategoria() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Seleccionar categoría',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          ..._categorias.map(
            (cat) => ListTile(
              leading: Icon(cat.icono, size: 20),
              title: Text(cat.nombre),
              trailing:
                  _filtro.categoriaId == cat.id ? const Icon(Icons.check) : null,
              onTap: () {
                Navigator.pop(ctx);
                _filtro = _filtro.copyWith(categoriaId: cat.id);
                _aplicarFiltros();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarSelectorFechas() async {
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _filtro.fechaDesde != null && _filtro.fechaHasta != null
          ? DateTimeRange(start: _filtro.fechaDesde!, end: _filtro.fechaHasta!)
          : null,
    );
    if (rango != null) {
      _filtro = _filtro.copyWith(
        fechaDesde: rango.start,
        fechaHasta: rango.end,
      );
      _aplicarFiltros();
    }
  }

  String _formatoRangoFechas() {
    String fmt(DateTime d) => '${d.day}/${d.month}';
    if (_filtro.fechaDesde != null && _filtro.fechaHasta != null) {
      return '${fmt(_filtro.fechaDesde!)} - ${fmt(_filtro.fechaHasta!)}';
    }
    if (_filtro.fechaDesde != null) return 'Desde ${fmt(_filtro.fechaDesde!)}';
    return 'Hasta ${fmt(_filtro.fechaHasta!)}';
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right_rounded, size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
      onTap: onTap,
    );
  }
}

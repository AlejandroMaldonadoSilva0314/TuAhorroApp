import 'package:flutter/material.dart';

import '../../../core/theme/theme_scope.dart';
import '../../../core/utils/formatos.dart';
import '../../ajustes/screens/ajustes_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appTheme = ThemeScope.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appTheme.gradient),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TuAhorro',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (!_cargando && _error == null)
              Text(
                'Total: ${Formatos.moneda(_totalGastos)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_mostrarBusqueda ? Icons.search_off : Icons.search),
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
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EstadisticasScreen(repository: widget.repository),
                ),
              );
              await _cargarGastos();
            },
            tooltip: 'Estadísticas',
          ),
          IconButton(
            icon: const Icon(Icons.insights_rounded),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => InsightsScreen(repository: widget.repository),
                ),
              );
              await _cargarGastos();
            },
            tooltip: 'Insights',
          ),
          IconButton(
            icon: const Icon(Icons.flag_rounded),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MetasScreen(repository: widget.repository),
                ),
              );
              await _cargarGastos();
            },
            tooltip: 'Metas',
          ),
          IconButton(
            icon: const Icon(Icons.handshake_outlined),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FiadosScreen(repository: widget.repository),
                ),
              );
              await _cargarGastos();
            },
            tooltip: 'Fiados',
          ),
          IconButton(
            icon: const Icon(Icons.wallet_rounded),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BolsillosScreen(repository: widget.repository),
                ),
              );
              await _cargarGastos();
            },
            tooltip: 'Bolsillos',
          ),
          IconButton(
            icon: const Icon(Icons.category_rounded),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CategoriasScreen(repository: widget.repository),
                ),
              );
              await _cargarGastos();
            },
            tooltip: 'Categorías',
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AjustesScreen(
                    repository: widget.repository,
                    onSettingsChanged: (s) {
                      widget.onSettingsChanged?.call(s);
                    },
                  ),
                ),
              );
              await _cargarGastos();
            },
            tooltip: 'Ajustes',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarGastos,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AjustesScreen()),
            ),
            tooltip: 'Personalizar',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RegistroScreen(
                onGuardar: widget.repository.agregarGasto,
                bolsillos: _bolsillos,
                categorias: _categorias,
              ),
            ),
          );
          await _cargarGastos();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo gasto'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            FilledButton(onPressed: _cargarGastos, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    if (_gastos.isEmpty) {
      return const Center(
        child: Text('No hay gastos registrados aún.'),
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
        onTapInsights: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => InsightsScreen(repository: widget.repository),
            ),
          );
          await _cargarGastos();
        },
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

    return RefreshIndicator(
      onRefresh: _cargarGastos,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
          // Tipo
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
          // Categoría
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
          // Rango de fechas
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Seleccionar categoría',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

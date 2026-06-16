import 'package:flutter/material.dart';

import '../../../core/utils/formatos.dart';
import '../data/gasto_repository.dart';
import '../logic/estadisticas_calculator.dart';
import '../models/categoria.dart';
import '../models/gasto.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key, required this.repository});

  final GastoRepository repository;

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final _calculator = EstadisticasCalculator();
  List<Gasto> _gastos = [];
  List<Categoria> _categorias = [];
  late int _anio;
  late int _mes;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    final ahora = DateTime.now();
    _anio = ahora.year;
    _mes = ahora.month;
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final results = await Future.wait([
      widget.repository.obtenerGastos(),
      widget.repository.obtenerCategorias(),
    ]);
    _gastos = results[0] as List<Gasto>;
    _categorias = results[1] as List<Categoria>;
    if (mounted) setState(() => _cargando = false);
  }

  String _nombreCategoria(String id) =>
      _categorias.where((c) => c.id == id).firstOrNull?.nombre ?? id;

  void _mesAnterior() {
    setState(() {
      if (_mes == 1) {
        _mes = 12;
        _anio--;
      } else {
        _mes--;
      }
    });
  }

  void _mesSiguiente() {
    final ahora = DateTime.now();
    if (_anio == ahora.year && _mes >= ahora.month) return;
    setState(() {
      if (_mes == 12) {
        _mes = 1;
        _anio++;
      } else {
        _mes++;
      }
    });
  }

  String get _nombreMes {
    const nombres = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${nombres[_mes]} $_anio';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stats = _calculator.calcular(_gastos, _anio, _mes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSelectorMes(colorScheme),
                const SizedBox(height: 16),
                _buildTarjetasResumen(stats, colorScheme),
                const SizedBox(height: 20),
                if (stats.categoriaMayorGastoId != null) ...[
                  _buildMayorCategoria(stats, colorScheme),
                  const SizedBox(height: 20),
                ],
                if (stats.top3Categorias.isNotEmpty) ...[
                  _buildTop3(stats, colorScheme),
                  const SizedBox(height: 20),
                ],
                if (stats.gastosPorCategoria.isNotEmpty)
                  _buildGrafico(stats, colorScheme),
              ],
            ),
    );
  }

  Widget _buildSelectorMes(ColorScheme cs) {
    final ahora = DateTime.now();
    final esActual = _anio == ahora.year && _mes == ahora.month;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _mesAnterior,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          _nombreMes,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: esActual ? null : _mesSiguiente,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildTarjetasResumen(EstadisticasMensuales stats, ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: _TarjetaMetrica(
            titulo: 'Gastos',
            valor: Formatos.moneda(stats.totalGastos),
            color: Colors.red.shade700,
            icono: Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TarjetaMetrica(
            titulo: 'Ingresos',
            valor: Formatos.moneda(stats.totalIngresos),
            color: Colors.green.shade700,
            icono: Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TarjetaMetrica(
            titulo: 'Ahorro',
            valor: Formatos.moneda(stats.ahorroNeto),
            color: stats.ahorroNeto >= 0 ? Colors.blue.shade700 : Colors.orange.shade700,
            icono: stats.ahorroNeto >= 0 ? Icons.savings : Icons.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildMayorCategoria(EstadisticasMensuales stats, ColorScheme cs) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Icon(Icons.trending_up, color: cs.primary),
        ),
        title: const Text('Mayor gasto'),
        subtitle: Text(_nombreCategoria(stats.categoriaMayorGastoId!)),
        trailing: Text(
          Formatos.moneda(stats.montoMayorCategoria),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildTop3(EstadisticasMensuales stats, ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top categorías',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...stats.top3Categorias.asMap().entries.map((entry) {
              final i = entry.key;
              final cat = entry.value;
              final medallas = ['🥇', '🥈', '🥉'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(medallas[i], style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_nombreCategoria(cat.key))),
                    Text(
                      Formatos.moneda(cat.value),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGrafico(EstadisticasMensuales stats, ColorScheme cs) {
    final maxMonto = stats.gastosPorCategoria.values
        .fold(0.0, (a, b) => a > b ? a : b);
    if (maxMonto == 0) return const SizedBox.shrink();

    final colores = [
      cs.primary,
      cs.tertiary,
      cs.secondary,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];

    final entradas = stats.gastosPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gastos por categoría',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...entradas.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final porcentaje = e.value / maxMonto;
              final color = colores[i % colores.length];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_nombreCategoria(e.key), style: const TextStyle(fontSize: 13)),
                        Text(
                          Formatos.moneda(e.value),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: porcentaje,
                        minHeight: 12,
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TarjetaMetrica extends StatelessWidget {
  const _TarjetaMetrica({
    required this.titulo,
    required this.valor,
    required this.color,
    required this.icono,
  });

  final String titulo;
  final String valor;
  final Color color;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icono, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: TextStyle(fontSize: 12, color: color),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valor,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

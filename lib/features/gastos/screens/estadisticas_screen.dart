import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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
      appBar: AppBar(title: const Text('Estadísticas')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSelectorMes(colorScheme),
                const SizedBox(height: 16),
                _buildTarjetasResumen(stats, colorScheme),
                const SizedBox(height: 16),
                if (stats.categoriaMayorGastoId != null) ...[
                  _buildMayorCategoria(stats, colorScheme),
                  const SizedBox(height: 12),
                ],
                if (stats.top3Categorias.isNotEmpty) ...[
                  _buildTop3(stats, colorScheme),
                  const SizedBox(height: 12),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _mesAnterior,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            _nombreMes,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: esActual ? null : _mesSiguiente,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetasResumen(EstadisticasMensuales stats, ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: _TarjetaMetrica(
            titulo: 'Gastos',
            valor: Formatos.moneda(stats.totalGastos),
            color: cs.negativo,
            icono: Icons.arrow_downward_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TarjetaMetrica(
            titulo: 'Ingresos',
            valor: Formatos.moneda(stats.totalIngresos),
            color: cs.positivo,
            icono: Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TarjetaMetrica(
            titulo: 'Ahorro',
            valor: Formatos.moneda(stats.ahorroNeto),
            color: stats.ahorroNeto >= 0 ? cs.ahorro : cs.alerta,
            icono: stats.ahorroNeto >= 0 ? Icons.savings_rounded : Icons.warning_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMayorCategoria(EstadisticasMensuales stats, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.trending_up_rounded, color: cs.error, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mayor gasto', style: TextStyle(
                  fontSize: 12, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(_nombreCategoria(stats.categoriaMayorGastoId!),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
          ),
          Text(
            Formatos.moneda(stats.montoMayorCategoria),
            style: TextStyle(fontWeight: FontWeight.w700, color: cs.error, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTop3(EstadisticasMensuales stats, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top categorías',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: cs.onSurface),
          ),
          const SizedBox(height: 14),
          ...stats.top3Categorias.asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            final colores = [cs.primary, cs.ahorro, cs.alerta];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colores[i % 3].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colores[i % 3],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_nombreCategoria(cat.key),
                      style: const TextStyle(fontSize: 14))),
                  Text(
                    Formatos.moneda(cat.value),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGrafico(EstadisticasMensuales stats, ColorScheme cs) {
    final maxMonto = stats.gastosPorCategoria.values
        .fold(0.0, (a, b) => a > b ? a : b);
    if (maxMonto == 0) return const SizedBox.shrink();

    final colores = cs.chartColors;

    final entradas = stats.gastosPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gastos por categoría',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: cs.onSurface),
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
                      Text(_nombreCategoria(e.key),
                          style: const TextStyle(fontSize: 13)),
                      Text(
                        Formatos.moneda(e.value),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: porcentaje,
                      minHeight: 10,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
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
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

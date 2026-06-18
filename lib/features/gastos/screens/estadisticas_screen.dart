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
      '',
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${nombres[_mes]} $_anio';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final stats = _calculator.calcular(_gastos, _anio, _mes);

    return Scaffold(
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                // Header con gradiente — estilo Revolut
                _HeaderResumen(
                  stats: stats,
                  nombreMes: _nombreMes,
                  onAnterior: _mesAnterior,
                  onSiguiente: _mesSiguiente,
                  esMesActual: _anio == DateTime.now().year &&
                      _mes == DateTime.now().month,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      if (stats.categoriaMayorGastoId != null) ...[
                        _TarjetaMayorCategoria(
                          nombre: _nombreCategoria(stats.categoriaMayorGastoId!),
                          monto: stats.montoMayorCategoria,
                          cs: cs,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (stats.top3Categorias.isNotEmpty) ...[
                        _TarjetaTop3(
                          top3: stats.top3Categorias,
                          nombreCategoria: _nombreCategoria,
                          cs: cs,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (stats.gastosPorCategoria.isNotEmpty)
                        _GraficoBarras(
                          datos: stats.gastosPorCategoria,
                          nombreCategoria: _nombreCategoria,
                          cs: cs,
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ── HEADER GRADIENTE ─────────────────────────────────────────────────────────

class _HeaderResumen extends StatelessWidget {
  const _HeaderResumen({
    required this.stats,
    required this.nombreMes,
    required this.onAnterior,
    required this.onSiguiente,
    required this.esMesActual,
  });

  final EstadisticasMensuales stats;
  final String nombreMes;
  final VoidCallback onAnterior;
  final VoidCallback onSiguiente;
  final bool esMesActual;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: Theme.of(context).colorScheme.heroGradient,
        boxShadow: Theme.of(context).colorScheme.heroShadow,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.base, AppSpacing.base,
              AppSpacing.base, AppSpacing.xl),
          child: Column(
            children: [
              // Top bar — título + selector mes
              Row(
                children: [
                  // Botón atrás
                  Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () => Navigator.of(ctx).maybePop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Estadísticas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36), // balance
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Selector de mes — pill premium
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavBtn(icon: Icons.chevron_left_rounded, onTap: onAnterior),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      nombreMes,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _NavBtn(
                      icon: Icons.chevron_right_rounded,
                      onTap: esMesActual ? null : onSiguiente,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Tres métricas principales
              Row(
                children: [
                  _MetricaBlanca(
                      label: 'Gastos',
                      valor: Formatos.moneda(stats.totalGastos)),
                  _Divisor(),
                  _MetricaBlanca(
                      label: 'Ingresos',
                      valor: Formatos.moneda(stats.totalIngresos)),
                  _Divisor(),
                  _MetricaBlanca(
                      label: 'Ahorro',
                      valor: Formatos.moneda(stats.ahorroNeto),
                      esNegativo: stats.ahorroNeto < 0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: onTap == null ? 0.06 : 0.15),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon,
            color: Colors.white.withValues(alpha: onTap == null ? 0.3 : 1.0),
            size: 20),
      ),
    );
  }
}

class _MetricaBlanca extends StatelessWidget {
  const _MetricaBlanca(
      {required this.label, required this.valor, this.esNegativo = false});
  final String label;
  final String valor;
  final bool esNegativo;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.70),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: esNegativo
                    ? Theme.of(context).colorScheme.alerta
                    : Colors.white,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divisor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.20),
    );
  }
}

// ── MAYOR CATEGORÍA ───────────────────────────────────────────────────────────

class _TarjetaMayorCategoria extends StatelessWidget {
  const _TarjetaMayorCategoria(
      {required this.nombre, required this.monto, required this.cs});
  final String nombre;
  final double monto;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: cs.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.cardBorder),
        boxShadow: cs.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.error.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.trending_up_rounded, color: cs.error, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mayor gasto del mes',
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Text(nombre,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
          ),
          Text(
            Formatos.moneda(monto),
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: cs.error,
                fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ── TOP 3 ─────────────────────────────────────────────────────────────────────

class _TarjetaTop3 extends StatelessWidget {
  const _TarjetaTop3(
      {required this.top3,
      required this.nombreCategoria,
      required this.cs});
  final List<MapEntry<String, double>> top3;
  final String Function(String) nombreCategoria;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final colores = cs.chartColors.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: cs.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.cardBorder),
        boxShadow: cs.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top categorías',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: cs.onSurface)),
          const SizedBox(height: AppSpacing.md),
          ...top3.asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            final color = colores[i % 3];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.6)],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(nombreCategoria(cat.key),
                        style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurface,
                            fontWeight: FontWeight.w500)),
                  ),
                  Text(
                    Formatos.moneda(cat.value),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: color),
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

// ── GRÁFICO DE BARRAS ─────────────────────────────────────────────────────────

class _GraficoBarras extends StatelessWidget {
  const _GraficoBarras(
      {required this.datos,
      required this.nombreCategoria,
      required this.cs});

  final Map<String, double> datos;
  final String Function(String) nombreCategoria;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final maxMonto = datos.values.fold(0.0, (a, b) => a > b ? a : b);
    if (maxMonto == 0) return const SizedBox.shrink();

    final entradas = datos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colores = cs.chartColors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: cs.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.cardBorder),
        boxShadow: cs.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gastos por categoría',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: cs.onSurface)),
          const SizedBox(height: AppSpacing.base),
          ...entradas.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final porcentaje = e.value / maxMonto;
            final color = colores[i % colores.length];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(nombreCategoria(e.key),
                            style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatos.moneda(e.value),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Barra con gradiente
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: porcentaje,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color, color.withValues(alpha: 0.6)],
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.30),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

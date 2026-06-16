import 'package:flutter/material.dart';

import '../../../core/utils/formatos.dart';
import '../data/gasto_repository.dart';
import '../logic/insights_calculator.dart';
import '../models/categoria.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key, required this.repository});

  final GastoRepository repository;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  InsightResult? _insight;
  List<Categoria> _categorias = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final results = await Future.wait([
      widget.repository.obtenerGastos(),
      widget.repository.obtenerCategorias(),
    ]);
    final gastos = results[0] as List;
    _categorias = results[1] as List<Categoria>;
    final resultado = InsightsCalculator(
      nombreCategoria: _nombreCategoria,
    ).calcular(gastos.cast());
    if (mounted) setState(() { _insight = resultado; _cargando = false; });
  }

  String _nombreCategoria(String id) =>
      _categorias.where((c) => c.id == id).firstOrNull?.nombre ?? id;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        title: const Text('Insights'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: _buildContent(cs),
              ),
            ),
    );
  }

  List<Widget> _buildContent(ColorScheme cs) {
    final i = _insight!;

    return [
      // Mensajes principales
      for (final msg in i.mensajes)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: cs.onPrimaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      msg,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

      const SizedBox(height: 8),

      // Comparación semanal
      _buildCard(
        cs,
        titulo: 'Esta semana vs anterior',
        children: [
          _fila('Semana actual', Formatos.moneda(i.gastoSemanaActual)),
          _fila('Semana anterior', Formatos.moneda(i.gastoSemanaAnterior)),
          const Divider(),
          _fila(
            'Cambio',
            '${i.porcentajeCambio >= 0 ? '+' : ''}${i.porcentajeCambio.toStringAsFixed(1)}%',
            color: i.porcentajeCambio <= 0 ? Colors.green : Colors.red,
          ),
        ],
      ),

      const SizedBox(height: 8),

      // Promedio diario
      _buildCard(
        cs,
        titulo: 'Promedio diario',
        children: [
          Center(
            child: Text(
              Formatos.moneda(i.promedioDiario),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'por día esta semana',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),

      const SizedBox(height: 8),

      // Categoría mayor
      if (i.categoriaMayorId != null)
        _buildCard(
          cs,
          titulo: 'Categoría con más gasto',
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    _nombreCategoria(i.categoriaMayorId!),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatos.moneda(i.montoCategoriaMayor),
                    style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
    ];
  }

  Widget _buildCard(ColorScheme cs, {required String titulo, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _fila(String label, String valor, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(valor, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

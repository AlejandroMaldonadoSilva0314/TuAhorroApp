import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/bolsillo.dart';
import '../models/categoria.dart';
import '../models/gasto.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({
    super.key,
    required this.onGuardar,
    this.bolsillos = const [],
    this.categorias = const [],
  });

  final Future<void> Function(Gasto) onGuardar;
  final List<Bolsillo> bolsillos;
  final List<Categoria> categorias;

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _montoController = TextEditingController();

  late String _categoriaId;
  TipoTransaccion _tipo = TipoTransaccion.gasto;
  String? _bolsilloId;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _categoriaId = widget.categorias.isNotEmpty
        ? widget.categorias.firstWhere((c) => c.id == 'otros',
            orElse: () => widget.categorias.first).id
        : 'otros';
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  List<Categoria> get _categoriasFiltradas {
    return widget.categorias.where((c) {
      if (_tipo == TipoTransaccion.gasto) {
        return c.tipo == TipoCategoria.gasto || c.tipo == TipoCategoria.ambos;
      } else {
        return c.tipo == TipoCategoria.ingreso || c.tipo == TipoCategoria.ambos;
      }
    }).toList();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final transaccion = Gasto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text.trim(),
      monto: double.parse(_montoController.text.replaceAll(',', '.')),
      categoriaId: _categoriaId,
      tipo: _tipo,
      fecha: DateTime.now(),
      bolsilloId: _bolsilloId,
    );

    await widget.onGuardar(transaccion);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filtradas = _categoriasFiltradas;
    if (!filtradas.any((c) => c.id == _categoriaId) && filtradas.isNotEmpty) {
      _categoriaId = filtradas.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva transacción'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SelectorTipo(
              seleccionado: _tipo,
              onChanged: (t) => setState(() => _tipo = t),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Ej: Almuerzo, Arriendo, Salario...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'El título es obligatorio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _montoController,
              decoration: const InputDecoration(
                labelText: 'Monto (COP) *',
                hintText: 'Ej: 15000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                prefixText: '\$ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El monto es obligatorio';
                final parsed = double.tryParse(v.replaceAll(',', '.'));
                if (parsed == null) return 'Ingresa un número válido';
                if (parsed <= 0) return 'El monto debe ser mayor a \$0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categoriaId,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: filtradas
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Row(
                          children: [
                            Icon(c.icono, size: 20),
                            const SizedBox(width: 8),
                            Text(c.nombre),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _categoriaId = v);
              },
            ),
            if (widget.bolsillos.isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: _bolsilloId,
                decoration: const InputDecoration(
                  labelText: 'Bolsillo (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wallet_rounded),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Sin bolsillo')),
                  ...widget.bolsillos.map(
                    (b) => DropdownMenuItem(value: b.id, child: Text(b.nombre)),
                  ),
                ],
                onChanged: (v) => setState(() => _bolsilloId = v),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_guardando ? 'Guardando...' : 'Guardar transacción'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorTipo extends StatelessWidget {
  const _SelectorTipo({required this.seleccionado, required this.onChanged});

  final TipoTransaccion seleccionado;
  final void Function(TipoTransaccion) onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TipoTransaccion>(
      segments: const [
        ButtonSegment(
          value: TipoTransaccion.gasto,
          label: Text('Gasto'),
          icon: Icon(Icons.arrow_downward),
        ),
        ButtonSegment(
          value: TipoTransaccion.ingreso,
          label: Text('Ingreso'),
          icon: Icon(Icons.arrow_upward),
        ),
      ],
      selected: {seleccionado},
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}

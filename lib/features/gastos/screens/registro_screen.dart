import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_scope.dart';
import '../models/gasto.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key, required this.onGuardar});

  /// Callback async: permite que el caller persista la transacción antes de pop.
  final Future<void> Function(Gasto) onGuardar;

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _montoController = TextEditingController();

  CategoriaGasto _categoria = CategoriaGasto.otros;
  TipoTransaccion _tipo = TipoTransaccion.gasto;
  bool _guardando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final transaccion = Gasto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text.trim(),
      monto: double.parse(_montoController.text.replaceAll(',', '.')),
      categoria: _categoria,
      tipo: _tipo,
      fecha: DateTime.now(),
    );

    await widget.onGuardar(transaccion);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ThemeScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva transacción'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appTheme.gradient),
        ),
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
            DropdownButtonFormField<CategoriaGasto>(
              value: _categoria,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: CategoriaGasto.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.nombre)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _categoria = v);
              },
            ),
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

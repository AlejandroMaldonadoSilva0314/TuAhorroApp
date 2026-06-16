import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/formatos.dart';
import '../data/gasto_repository.dart';
import '../models/fiado.dart';

class FiadosScreen extends StatefulWidget {
  const FiadosScreen({super.key, required this.repository});

  final GastoRepository repository;

  @override
  State<FiadosScreen> createState() => _FiadosScreenState();
}

class _FiadosScreenState extends State<FiadosScreen> {
  List<Fiado> _fiados = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final fiados = await widget.repository.obtenerFiados();
    if (mounted) setState(() { _fiados = fiados; _cargando = false; });
  }

  List<Fiado> get _pendientes => _fiados.where((f) => !f.pagado).toList();
  List<Fiado> get _saldados => _fiados.where((f) => f.pagado).toList();

  double _total(TipoFiado tipo) => _pendientes
      .where((f) => f.tipo == tipo)
      .fold(0.0, (sum, f) => sum + f.monto);

  double get _porCobrar => _total(TipoFiado.porCobrar);
  double get _porPagar => _total(TipoFiado.porPagar);
  double get _balanceNeto => _porCobrar - _porPagar;

  Future<void> _marcarPagado(Fiado fiado) async {
    await widget.repository.actualizarFiado(fiado.copyWith(pagado: true));
    await _cargar();
  }

  Future<void> _eliminar(Fiado fiado) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: Text('¿Eliminar el fiado con ${fiado.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await widget.repository.eliminarFiado(fiado.id);
    await _cargar();
  }

  Future<void> _mostrarFormulario({Fiado? existente}) async {
    final nombreCtrl = TextEditingController(text: existente?.nombre ?? '');
    final montoCtrl = TextEditingController(
      text: existente != null ? existente.monto.toStringAsFixed(0) : '',
    );
    final notaCtrl = TextEditingController(text: existente?.nota ?? '');
    var tipo = existente?.tipo ?? TipoFiado.porCobrar;

    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existente != null ? 'Editar fiado' : 'Nuevo fiado'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<TipoFiado>(
                  segments: const [
                    ButtonSegment(value: TipoFiado.porCobrar, label: Text('Me deben')),
                    ButtonSegment(value: TipoFiado.porPagar, label: Text('Yo debo')),
                  ],
                  selected: {tipo},
                  onSelectionChanged: (s) => setDialogState(() => tipo = s.first),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nombreCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    hintText: 'Ej: Juan, María...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: montoCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  decoration: const InputDecoration(
                    labelText: 'Monto *',
                    prefixText: '\$ ',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notaCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nota (opcional)',
                    hintText: 'Ej: Para el almuerzo del viernes',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (nombreCtrl.text.trim().isEmpty) return;
                if (double.tryParse(montoCtrl.text.replaceAll(',', '.')) == null) return;
                Navigator.pop(ctx, true);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (resultado != true) return;

    final monto = double.parse(montoCtrl.text.replaceAll(',', '.'));
    final nota = notaCtrl.text.trim().isEmpty ? null : notaCtrl.text.trim();

    if (existente != null) {
      await widget.repository.actualizarFiado(Fiado(
        id: existente.id,
        nombre: nombreCtrl.text.trim(),
        monto: monto,
        fecha: existente.fecha,
        tipo: tipo,
        nota: nota,
        pagado: existente.pagado,
      ));
    } else {
      await widget.repository.agregarFiado(Fiado(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombreCtrl.text.trim(),
        monto: monto,
        fecha: DateTime.now(),
        tipo: tipo,
        nota: nota,
      ));
    }
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiados y Préstamos'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _fiados.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.handshake_outlined, size: 64, color: colorScheme.outlineVariant),
                      const SizedBox(height: 12),
                      const Text('No hay fiados registrados'),
                      const SizedBox(height: 8),
                      const Text('Registra quién te debe o a quién debes', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  children: [
                    _ResumenFiados(
                      porCobrar: _porCobrar,
                      porPagar: _porPagar,
                      balance: _balanceNeto,
                    ),
                    if (_pendientes.isNotEmpty) ...[
                      const _SeccionHeader(titulo: 'Pendientes'),
                      ..._pendientes.map((f) => _FiadoCard(
                            fiado: f,
                            onMarcarPagado: () => _marcarPagado(f),
                            onEditar: () => _mostrarFormulario(existente: f),
                            onEliminar: () => _eliminar(f),
                          )),
                    ],
                    if (_saldados.isNotEmpty) ...[
                      const _SeccionHeader(titulo: 'Saldados'),
                      ..._saldados.map((f) => _FiadoCard(
                            fiado: f,
                            onEditar: () => _mostrarFormulario(existente: f),
                            onEliminar: () => _eliminar(f),
                          )),
                    ],
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo fiado'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ResumenFiados extends StatelessWidget {
  const _ResumenFiados({
    required this.porCobrar,
    required this.porPagar,
    required this.balance,
  });

  final double porCobrar;
  final double porPagar;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final balancePositivo = balance >= 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('Balance neto', style: TextStyle(fontSize: 13, color: colorScheme.onPrimaryContainer)),
                const SizedBox(height: 4),
                Text(
                  Formatos.moneda(balance.abs()),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: balancePositivo ? Colors.green.shade700 : colorScheme.error,
                  ),
                ),
                Text(
                  balancePositivo ? 'Te deben más de lo que debes' : 'Debes más de lo que te deben',
                  style: TextStyle(fontSize: 11, color: colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniResumen(
                  label: 'Me deben',
                  monto: porCobrar,
                  color: Colors.green.shade700,
                  fondo: Colors.green.shade50,
                  icono: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniResumen(
                  label: 'Yo debo',
                  monto: porPagar,
                  color: colorScheme.error,
                  fondo: colorScheme.errorContainer.withValues(alpha: 0.3),
                  icono: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniResumen extends StatelessWidget {
  const _MiniResumen({
    required this.label,
    required this.monto,
    required this.color,
    required this.fondo,
    required this.icono,
  });

  final String label;
  final double monto;
  final Color color;
  final Color fondo;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            Formatos.moneda(monto),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _SeccionHeader extends StatelessWidget {
  const _SeccionHeader({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _FiadoCard extends StatelessWidget {
  const _FiadoCard({
    required this.fiado,
    this.onMarcarPagado,
    required this.onEditar,
    required this.onEliminar,
  });

  final Fiado fiado;
  final VoidCallback? onMarcarPagado;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final esCobrar = fiado.tipo == TipoFiado.porCobrar;
    final color = esCobrar ? Colors.green.shade700 : colorScheme.error;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: esCobrar ? Colors.green.shade50 : colorScheme.errorContainer,
          child: Icon(
            esCobrar ? Icons.call_received_rounded : Icons.call_made_rounded,
            color: color,
          ),
        ),
        title: Text(
          fiado.nombre,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: fiado.pagado ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${esCobrar ? "Me debe" : "Le debo"} ${Formatos.moneda(fiado.monto)}',
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
            if (fiado.nota != null)
              Text(fiado.nota!, style: const TextStyle(fontSize: 12)),
            Text(
              Formatos.fecha(fiado.fecha),
              style: TextStyle(fontSize: 11, color: colorScheme.outlineVariant),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'pagado') onMarcarPagado?.call();
            if (v == 'editar') onEditar();
            if (v == 'eliminar') onEliminar();
          },
          itemBuilder: (_) => [
            if (!fiado.pagado)
              const PopupMenuItem(value: 'pagado', child: Text('Marcar pagado')),
            const PopupMenuItem(value: 'editar', child: Text('Editar')),
            const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }
}

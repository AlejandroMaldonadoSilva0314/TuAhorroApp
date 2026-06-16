import 'package:flutter/material.dart';

import '../data/gasto_repository.dart';
import '../models/categoria.dart';
import '../models/gasto.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key, required this.repository});

  final GastoRepository repository;

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  List<Categoria> _categorias = [];
  List<Gasto> _gastos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final results = await Future.wait([
      widget.repository.obtenerCategorias(),
      widget.repository.obtenerGastos(),
    ]);
    if (mounted) {
      setState(() {
        _categorias = results[0] as List<Categoria>;
        _gastos = results[1] as List<Gasto>;
        _cargando = false;
      });
    }
  }

  bool _categoriaEnUso(String id) =>
      _gastos.any((g) => g.categoriaId == id);

  Future<void> _eliminar(Categoria cat) async {
    if (_categoriaEnUso(cat.id)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede eliminar: tiene transacciones asociadas.')),
      );
      return;
    }
    await widget.repository.eliminarCategoria(cat.id);
    await _cargar();
  }

  Future<void> _abrirFormulario({Categoria? editar}) async {
    final resultado = await Navigator.of(context).push<Categoria>(
      MaterialPageRoute(
        builder: (_) => _CategoriaFormScreen(
          editar: editar,
          nombresExistentes: _categorias
              .where((c) => c.id != editar?.id)
              .map((c) => c.nombre.toLowerCase())
              .toSet(),
        ),
      ),
    );
    if (resultado == null) return;

    if (editar != null) {
      await widget.repository.actualizarCategoria(resultado);
    } else {
      await widget.repository.agregarCategoria(resultado);
    }
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final cat = _categorias[index];
                final enUso = _categoriaEnUso(cat.id);
                return ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(cat.icono, color: colorScheme.primary, size: 20),
                  ),
                  title: Text(cat.nombre),
                  subtitle: Text(_tipoLabel(cat.tipo) +
                      (cat.esPredeterminada ? ' · Predeterminada' : '')),
                  trailing: cat.esPredeterminada
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => _abrirFormulario(editar: cat),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  size: 20,
                                  color: enUso ? colorScheme.outlineVariant : colorScheme.error),
                              onPressed: enUso ? null : () => _eliminar(cat),
                              tooltip: enUso
                                  ? 'Tiene transacciones asociadas'
                                  : 'Eliminar',
                            ),
                          ],
                        ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  String _tipoLabel(TipoCategoria tipo) => switch (tipo) {
        TipoCategoria.ingreso => 'Ingreso',
        TipoCategoria.gasto => 'Gasto',
        TipoCategoria.ambos => 'Ambos',
      };
}

class _CategoriaFormScreen extends StatefulWidget {
  const _CategoriaFormScreen({this.editar, required this.nombresExistentes});

  final Categoria? editar;
  final Set<String> nombresExistentes;

  @override
  State<_CategoriaFormScreen> createState() => _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends State<_CategoriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late TipoCategoria _tipo;
  late int _iconoCodePoint;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.editar?.nombre ?? '');
    _tipo = widget.editar?.tipo ?? TipoCategoria.gasto;
    _iconoCodePoint = widget.editar?.iconoCodePoint ?? Categoria.iconosDisponibles.first;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.editar?.id ??
        'custom_${DateTime.now().millisecondsSinceEpoch}';

    final categoria = Categoria(
      id: id,
      nombre: _nombreController.text.trim(),
      tipo: _tipo,
      iconoCodePoint: _iconoCodePoint,
    );

    Navigator.of(context).pop(categoria);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final esEdicion = widget.editar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar categoría' : 'Nueva categoría'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                hintText: 'Ej: Mascotas, Hogar...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El nombre es obligatorio';
                if (widget.nombresExistentes.contains(v.trim().toLowerCase())) {
                  return 'Ya existe una categoría con ese nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Tipo', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<TipoCategoria>(
              segments: const [
                ButtonSegment(value: TipoCategoria.gasto, label: Text('Gasto')),
                ButtonSegment(value: TipoCategoria.ingreso, label: Text('Ingreso')),
                ButtonSegment(value: TipoCategoria.ambos, label: Text('Ambos')),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),
            const SizedBox(height: 16),
            const Text('Icono', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Categoria.iconosDisponibles.map((cp) {
                final seleccionado = cp == _iconoCodePoint;
                return InkWell(
                  onTap: () => setState(() => _iconoCodePoint = cp),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: seleccionado
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: seleccionado
                          ? Border.all(color: colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Icon(
                      IconData(cp, fontFamily: 'MaterialIcons'),
                      color: seleccionado
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save_outlined),
              label: Text(esEdicion ? 'Guardar cambios' : 'Crear categoría'),
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

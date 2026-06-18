import 'package:flutter/material.dart';

import '../../../core/theme/theme_scope.dart';
import '../data/notificacion_repository.dart';
import '../models/notificacion.dart';
import '../widgets/notificacion_tile.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key, required this.repository});

  final NotificacionRepository repository;

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  List<NotificacionLocal> _lista = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final lista = await widget.repository.obtenerNotificaciones();
    if (mounted) setState(() { _lista = lista; _cargando = false; });
  }

  Future<void> _marcarLeida(String id) async {
    await widget.repository.marcarLeida(id);
    await _cargar();
  }

  Future<void> _eliminar(String id) async {
    await widget.repository.eliminarNotificacion(id);
    await _cargar();
  }

  Future<void> _leerTodas() async {
    for (final n in _lista.where((n) => !n.leida)) {
      await widget.repository.marcarLeida(n.id);
    }
    await _cargar();
  }

  int get _sinLeer => _lista.where((n) => !n.leida).length;

  @override
  Widget build(BuildContext context) {
    final appTheme = ThemeScope.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appTheme.gradient),
        ),
        actions: [
          if (_sinLeer > 0)
            TextButton(
              onPressed: _leerTodas,
              child: Text(
                'Leer todas',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _lista.isEmpty
              ? _buildVacio(cs)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _lista.length,
                  itemBuilder: (context, i) {
                    final n = _lista[i];
                    return NotificacionTile(
                      notificacion: n,
                      onTap: () => _marcarLeida(n.id),
                      onDismissed: () => _eliminar(n.id),
                    );
                  },
                ),
    );
  }

  Widget _buildVacio(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: cs.onSurfaceVariant.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin notificaciones',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aquí aparecerán tus avisos y consejos financieros.',
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurfaceVariant.withValues(alpha: 0.65),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

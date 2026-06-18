import 'package:flutter/material.dart';

import '../data/gasto_repository.dart';
import '../logic/backup_service.dart';
import '../logic/notificacion_service.dart';
import '../logic/settings_service.dart';
import '../models/app_settings.dart';
import '../models/notificacion_config.dart';
import 'acerca_de_screen.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({
    super.key,
    required this.repository,
    required this.onSettingsChanged,
  });

  final GastoRepository repository;
  final void Function(AppSettings) onSettingsChanged;

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final _settingsService = SettingsService();
  final _notifService = NotificacionService();
  AppSettings _settings = const AppSettings();
  bool _cargando = true;
  int _espacioBytes = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final results = await Future.wait([
      _settingsService.cargar(),
      _settingsService.espacioUtilizado(),
    ]);
    if (mounted) {
      setState(() {
        _settings = results[0] as AppSettings;
        _espacioBytes = results[1] as int;
        _cargando = false;
      });
    }
  }

  Future<void> _actualizar(AppSettings nueva) async {
    setState(() => _settings = nueva);
    await _settingsService.guardar(nueva);
    widget.onSettingsChanged(nueva);
  }

  Future<void> _sincNotificaciones() async {
    await _notifService.guardarConfig(NotificacionConfig(
      activado: _settings.notificacionesActivas,
      hora: _settings.horaRecordatorio,
      minuto: _settings.minutoRecordatorio,
    ));
  }

  String _formatearEspacio(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text('Ajustes')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 32),
              children: [
                _headerPerfil(cs),
                _seccion('General'),
                _buildGrupo(cs, [
                  _tileMoneda(cs),
                  _tileFormatoFecha(cs),
                  _tileTema(cs),
                  _tileReiniciarOnboarding(),
                ]),
                _seccion('Finanzas'),
                _buildGrupo(cs, [
                  _tilePresupuesto(cs),
                  _tileDiaInicio(cs),
                  _tileReiniciarDatos(cs),
                ]),
                _seccion('Notificaciones'),
                _buildGrupo(cs, [
                  _tileNotifActivas(),
                  _tileHoraRecordatorio(cs),
                ]),
                _seccion('Datos'),
                _buildGrupo(cs, [
                  _tileExportar(cs),
                  _tileImportar(cs),
                  _tileEspacio(cs),
                ]),
                _seccion('Información'),
                _buildGrupo(cs, [
                  _tileVersion(),
                  _tileEquipo(),
                  _tilePolitica(),
                  _tileTerminos(),
                ]),
              ],
            ),
    );
  }

  Widget _headerPerfil(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B1630), Color(0xFF241B3E)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5B18D4), Color(0xFF8B35F7), Color(0xFFC084FC)],
                stops: [0.0, 0.55, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B2FF7).withValues(alpha: 0.40),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.savings_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TuAhorro',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFFFFF),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Espacio: ${_formatearEspacio(_espacioBytes)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF7B2FF7).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF7B2FF7).withValues(alpha: 0.30),
              ),
            ),
            child: const Text(
              'v1.0.0',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFA855F7),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrupo(ColorScheme cs, List<Widget> tiles) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                tiles[i],
                if (i < tiles.length - 1)
                  Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 0,
                    color: cs.outlineVariant.withValues(alpha: 0.10),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 6),
      child: Text(
        titulo.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _tileMoneda(ColorScheme cs) {
    return ListTile(
      leading: _iconContainer(Icons.attach_money_rounded, cs),
      title: const Text('Moneda'),
      subtitle: Text(_settings.moneda),
      trailing: _chevron(cs),
      onTap: () async {
        final seleccion = await showDialog<String>(
          context: context,
          builder: (_) => SimpleDialog(
            title: const Text('Seleccionar moneda'),
            children: AppSettings.monedas
                .map((m) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, m),
                      child: Text(m, style: TextStyle(
                        fontWeight: m == _settings.moneda ? FontWeight.bold : FontWeight.normal,
                      )),
                    ))
                .toList(),
          ),
        );
        if (seleccion != null && seleccion != _settings.moneda) {
          await _actualizar(_settings.copyWith(moneda: seleccion));
        }
      },
    );
  }

  Widget _tileFormatoFecha(ColorScheme cs) {
    return ListTile(
      leading: _iconContainer(Icons.calendar_today_rounded, cs),
      title: const Text('Formato de fecha'),
      subtitle: Text(_settings.formatoFechaLabel),
      trailing: _chevron(cs),
      onTap: () async {
        final seleccion = await showDialog<FormatoFecha>(
          context: context,
          builder: (_) => SimpleDialog(
            title: const Text('Formato de fecha'),
            children: FormatoFecha.values
                .map((f) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, f),
                      child: Text(
                        AppSettings(formatoFecha: f).formatoFechaLabel,
                        style: TextStyle(
                          fontWeight: f == _settings.formatoFecha ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ))
                .toList(),
          ),
        );
        if (seleccion != null && seleccion != _settings.formatoFecha) {
          await _actualizar(_settings.copyWith(formatoFecha: seleccion));
        }
      },
    );
  }

  Widget _tileTema(ColorScheme cs) {
    return ListTile(
      leading: _iconContainer(Icons.palette_rounded, cs),
      title: const Text('Tema'),
      subtitle: Text(_settings.temaLabel),
      trailing: _chevron(cs),
      onTap: () async {
        final seleccion = await showDialog<TemaApp>(
          context: context,
          builder: (_) => SimpleDialog(
            title: const Text('Seleccionar tema'),
            children: TemaApp.values
                .map((t) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, t),
                      child: Text(
                        AppSettings(tema: t).temaLabel,
                        style: TextStyle(
                          fontWeight: t == _settings.tema ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ))
                .toList(),
          ),
        );
        if (seleccion != null && seleccion != _settings.tema) {
          await _actualizar(_settings.copyWith(tema: seleccion));
        }
      },
    );
  }

  Widget _tilePresupuesto(ColorScheme cs) {
    return ListTile(
      leading: _iconContainer(Icons.account_balance_wallet_rounded, cs),
      title: const Text('Presupuesto semanal'),
      subtitle: Text(_settings.presupuestoSemanal > 0
          ? '\$${_settings.presupuestoSemanal.toStringAsFixed(0)}'
          : 'Sin configurar'),
      trailing: _chevron(cs),
      onTap: () async {
        final controller = TextEditingController(
          text: _settings.presupuestoSemanal > 0
              ? _settings.presupuestoSemanal.toStringAsFixed(0)
              : '',
        );
        final monto = await showDialog<double>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Presupuesto semanal'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '\$ ',
                hintText: '0',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  final val = double.tryParse(controller.text) ?? 0;
                  Navigator.pop(context, val);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        );
        if (monto != null) {
          await _actualizar(_settings.copyWith(presupuestoSemanal: monto));
          await widget.repository.guardarPresupuestoSemanal(monto);
        }
      },
    );
  }

  Widget _tileDiaInicio(ColorScheme cs) {
    return ListTile(
      leading: _iconContainer(Icons.today_rounded, cs),
      title: const Text('Inicio de semana'),
      subtitle: Text(_settings.diaInicioSemanaLabel),
      trailing: _chevron(cs),
      onTap: () async {
        final seleccion = await showDialog<DiaSemana>(
          context: context,
          builder: (_) => SimpleDialog(
            title: const Text('Día de inicio'),
            children: DiaSemana.values
                .map((d) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, d),
                      child: Text(
                        AppSettings(diaInicioSemana: d).diaInicioSemanaLabel,
                        style: TextStyle(
                          fontWeight: d == _settings.diaInicioSemana ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ))
                .toList(),
          ),
        );
        if (seleccion != null && seleccion != _settings.diaInicioSemana) {
          await _actualizar(_settings.copyWith(diaInicioSemana: seleccion));
        }
      },
    );
  }

  Widget _tileReiniciarDatos(ColorScheme cs) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.restore_rounded, color: cs.error, size: 20),
      ),
      title: Text('Reiniciar datos', style: TextStyle(color: cs.error)),
      subtitle: const Text('Elimina todos los datos de demostración'),
      onTap: () async {
        final confirmar = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Reiniciar datos'),
            content: const Text(
              'Se eliminarán todos los gastos, bolsillos, fiados y metas. '
              'Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: cs.error),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Reiniciar'),
              ),
            ],
          ),
        );
        if (confirmar == true && mounted) {
          final gastos = await widget.repository.obtenerGastos();
          for (final g in gastos) {
            await widget.repository.eliminarGasto(g.id);
          }
          final bolsillos = await widget.repository.obtenerBolsillos();
          for (final b in bolsillos) {
            await widget.repository.eliminarBolsillo(b.id);
          }
          final fiados = await widget.repository.obtenerFiados();
          for (final f in fiados) {
            await widget.repository.eliminarFiado(f.id);
          }
          final metas = await widget.repository.obtenerMetas();
          for (final m in metas) {
            await widget.repository.eliminarMeta(m.id);
          }
          await widget.repository.guardarPresupuestoSemanal(0);
          await _actualizar(_settings.copyWith(presupuestoSemanal: 0));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Datos reiniciados')),
            );
          }
        }
      },
    );
  }

  Widget _tileNotifActivas() {
    final cs = Theme.of(context).colorScheme;
    return SwitchListTile(
      secondary: _iconContainer(Icons.notifications_outlined, cs),
      title: const Text('Recordatorios'),
      subtitle: const Text('Recibe un aviso para registrar gastos'),
      value: _settings.notificacionesActivas,
      onChanged: (v) async {
        await _actualizar(_settings.copyWith(notificacionesActivas: v));
        await _sincNotificaciones();
      },
    );
  }

  Widget _tileHoraRecordatorio(ColorScheme cs) {
    return ListTile(
      enabled: _settings.notificacionesActivas,
      leading: _iconContainer(Icons.access_time_rounded, cs),
      title: const Text('Hora del recordatorio'),
      subtitle: Text(
        TimeOfDay(hour: _settings.horaRecordatorio, minute: _settings.minutoRecordatorio)
            .format(context),
      ),
      trailing: _chevron(cs),
      onTap: _settings.notificacionesActivas
          ? () async {
              final hora = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: _settings.horaRecordatorio,
                  minute: _settings.minutoRecordatorio,
                ),
              );
              if (hora != null) {
                await _actualizar(_settings.copyWith(
                  horaRecordatorio: hora.hour,
                  minutoRecordatorio: hora.minute,
                ));
                await _sincNotificaciones();
              }
            }
          : null,
    );
  }

  Widget _tileExportar(ColorScheme cs) {
    return ListTile(
      leading: _iconContainer(Icons.upload_rounded, cs),
      title: const Text('Exportar respaldo'),
      subtitle: const Text('Guardar datos en archivo JSON'),
      onTap: () async {
        try {
          await BackupService(widget.repository).compartir();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al exportar: $e')),
            );
          }
        }
      },
    );
  }

  Widget _tileImportar(ColorScheme cs) {
    return ListTile(
      leading: _iconContainer(Icons.download_rounded, cs),
      title: const Text('Importar respaldo'),
      subtitle: const Text('Restaurar desde archivo JSON'),
      onTap: () async {
        final backup = BackupService(widget.repository);
        try {
          final datos = await backup.seleccionarArchivo();
          if (datos == null) return;
          final error = backup.validar(datos);
          if (error != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
            return;
          }
          await backup.importar(datos);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Respaldo importado')),
            );
            await _cargar();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al importar: $e')),
            );
          }
        }
      },
    );
  }

  Widget _tileEspacio(ColorScheme cs) {
    return ListTile(
      leading: _iconContainer(Icons.storage_rounded, cs),
      title: const Text('Espacio utilizado'),
      subtitle: Text(_formatearEspacio(_espacioBytes)),
    );
  }

  Widget _tileVersion() {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: _iconContainer(Icons.info_outline_rounded, cs),
      title: const Text('Versión'),
      subtitle: const Text('1.0.0'),
    );
  }

  Widget _tileEquipo() {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: _iconContainer(Icons.info_rounded, cs),
      title: const Text('Acerca de TuAhorro'),
      trailing: _chevron(cs),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AcercaDeScreen()),
      ),
    );
  }

  Widget _tilePolitica() {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: _iconContainer(Icons.privacy_tip_outlined, cs),
      title: const Text('Política de privacidad'),
      trailing: _chevron(cs),
      onTap: () => _mostrarTextoLegal(
        'Política de privacidad',
        'TuAhorro respeta tu privacidad.\n\n'
        '• Todos tus datos se almacenan localmente en tu dispositivo.\n'
        '• No recopilamos, transmitimos ni compartimos información personal.\n'
        '• No utilizamos servicios de análisis ni rastreo.\n'
        '• Al desinstalar la app, todos los datos se eliminan automáticamente.\n\n'
        'Última actualización: junio 2026.',
      ),
    );
  }

  Widget _tileTerminos() {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: _iconContainer(Icons.description_outlined, cs),
      title: const Text('Términos y condiciones'),
      trailing: _chevron(cs),
      onTap: () => _mostrarTextoLegal(
        'Términos y condiciones',
        'Al usar TuAhorro aceptas los siguientes términos:\n\n'
        '• La app se proporciona "tal cual", sin garantías.\n'
        '• TuAhorro es una herramienta de registro personal y no constituye asesoría financiera.\n'
        '• Eres responsable de la exactitud de los datos que ingreses.\n'
        '• No nos hacemos responsables por pérdida de datos debido a fallos del dispositivo.\n'
        '• Te recomendamos hacer respaldos periódicos desde Ajustes > Exportar respaldo.\n\n'
        'Última actualización: junio 2026.',
      ),
    );
  }

  Widget _tileReiniciarOnboarding() {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: _iconContainer(Icons.replay_rounded, cs),
      title: const Text('Repetir tutorial inicial'),
      subtitle: const Text('Volver a ver la guía de bienvenida'),
      trailing: _chevron(cs),
      onTap: () async {
        await _actualizar(_settings.copyWith(onboardingCompletado: false));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El tutorial se mostrará al reiniciar la app')),
          );
        }
      },
    );
  }

  Widget _iconContainer(IconData icon, ColorScheme cs, {Color? color}) {
    final c = color ?? cs.primary;
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: c, size: 20),
    );
  }

  Widget _chevron(ColorScheme cs) {
    return Icon(Icons.chevron_right_rounded, size: 22,
        color: cs.onSurfaceVariant.withValues(alpha: 0.5));
  }

  void _mostrarTextoLegal(String titulo, String contenido) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: SingleChildScrollView(child: Text(contenido)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

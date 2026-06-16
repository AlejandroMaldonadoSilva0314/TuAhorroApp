import 'package:flutter/material.dart';

import '../data/gasto_repository.dart';
import '../logic/backup_service.dart';
import '../logic/notificacion_service.dart';
import '../logic/settings_service.dart';
import '../models/app_settings.dart';
import '../models/notificacion_config.dart';

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
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        title: const Text('Ajustes'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _seccion('General'),
                _tileMoneda(cs),
                _tileFormatoFecha(cs),
                _tileTema(cs),
                _seccion('Finanzas'),
                _tilePresupuesto(cs),
                _tileDiaInicio(cs),
                _tileReiniciarDatos(cs),
                _seccion('Notificaciones'),
                _tileNotifActivas(),
                _tileHoraRecordatorio(cs),
                _seccion('Datos'),
                _tileExportar(cs),
                _tileImportar(cs),
                _tileEspacio(cs),
                _seccion('Onboarding'),
                _tileReiniciarOnboarding(),
                _seccion('Información'),
                _tileVersion(),
                _tileEquipo(),
                _tilePolitica(),
                _tileTerminos(),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _seccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // --- General ---

  Widget _tileMoneda(ColorScheme cs) {
    return ListTile(
      leading: const Icon(Icons.attach_money_rounded),
      title: const Text('Moneda'),
      subtitle: Text(_settings.moneda),
      trailing: const Icon(Icons.chevron_right),
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
      leading: const Icon(Icons.calendar_today_rounded),
      title: const Text('Formato de fecha'),
      subtitle: Text(_settings.formatoFechaLabel),
      trailing: const Icon(Icons.chevron_right),
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
      leading: const Icon(Icons.palette_rounded),
      title: const Text('Tema'),
      subtitle: Text(_settings.temaLabel),
      trailing: const Icon(Icons.chevron_right),
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

  // --- Finanzas ---

  Widget _tilePresupuesto(ColorScheme cs) {
    return ListTile(
      leading: const Icon(Icons.account_balance_wallet_rounded),
      title: const Text('Presupuesto semanal'),
      subtitle: Text(_settings.presupuestoSemanal > 0
          ? '\$${_settings.presupuestoSemanal.toStringAsFixed(0)}'
          : 'Sin configurar'),
      trailing: const Icon(Icons.chevron_right),
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
      leading: const Icon(Icons.today_rounded),
      title: const Text('Inicio de semana'),
      subtitle: Text(_settings.diaInicioSemanaLabel),
      trailing: const Icon(Icons.chevron_right),
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
      leading: Icon(Icons.restore_rounded, color: cs.error),
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

  // --- Notificaciones ---

  Widget _tileNotifActivas() {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications_outlined),
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
      leading: const Icon(Icons.access_time_rounded),
      title: const Text('Hora del recordatorio'),
      subtitle: Text(
        TimeOfDay(hour: _settings.horaRecordatorio, minute: _settings.minutoRecordatorio)
            .format(context),
      ),
      trailing: const Icon(Icons.chevron_right),
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

  // --- Datos ---

  Widget _tileExportar(ColorScheme cs) {
    return ListTile(
      leading: const Icon(Icons.upload_rounded),
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
      leading: const Icon(Icons.download_rounded),
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
      leading: const Icon(Icons.storage_rounded),
      title: const Text('Espacio utilizado'),
      subtitle: Text(_formatearEspacio(_espacioBytes)),
    );
  }

  // --- Información ---

  Widget _tileVersion() {
    return const ListTile(
      leading: Icon(Icons.info_outline_rounded),
      title: Text('Versión'),
      subtitle: Text('1.0.0'),
    );
  }

  Widget _tileEquipo() {
    return ListTile(
      leading: const Icon(Icons.group_rounded),
      title: const Text('Equipo desarrollador'),
      subtitle: const Text('TuAhorro Team'),
      onTap: () => showAboutDialog(
        context: context,
        applicationName: 'TuAhorro',
        applicationVersion: '1.0.0',
        children: [
          const Text('Desarrollado con Flutter.'),
        ],
      ),
    );
  }

  Widget _tilePolitica() {
    return ListTile(
      leading: const Icon(Icons.privacy_tip_outlined),
      title: const Text('Política de privacidad'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _mostrarPlaceholder('Política de privacidad'),
    );
  }

  Widget _tileTerminos() {
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: const Text('Términos y condiciones'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _mostrarPlaceholder('Términos y condiciones'),
    );
  }

  Widget _tileReiniciarOnboarding() {
    return ListTile(
      leading: const Icon(Icons.replay_rounded),
      title: const Text('Repetir tutorial inicial'),
      subtitle: const Text('Volver a ver la guía de bienvenida'),
      trailing: const Icon(Icons.chevron_right),
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

  void _mostrarPlaceholder(String titulo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: const Text('Próximamente.'),
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

import '../../../core/utils/formatos.dart';
import '../../gastos/data/gasto_repository.dart';
import '../../gastos/logic/plata_para_hoy.dart';
import '../../gastos/logic/presupuesto_semanal.dart';
import '../../gastos/models/gasto.dart';
import '../data/notificacion_repository.dart';
import '../models/notificacion.dart';
import '../models/notificacion_config.dart';

/// Evalúa condiciones financieras y genera notificaciones locales.
/// Respetar el límite de 1-2 por día y las preferencias del usuario.
class NotificacionService {
  NotificacionService({
    required this.gastoRepository,
    required this.notificacionRepository,
  });

  final GastoRepository gastoRepository;
  final NotificacionRepository notificacionRepository;

  static const _limitesDiario = 2;

  Future<List<NotificacionLocal>> evaluarYGenerarNotificaciones() async {
    final config = await notificacionRepository.obtenerConfig();
    if (!config.activadas) return [];
    if (!_dentroDeHorario(config)) return [];

    final yaHoy = await _totalEnviadasHoy();
    if (yaHoy >= _limitesDiario) return [];

    final gastos = await gastoRepository.obtenerGastos();
    final presupuesto = await gastoRepository.obtenerPresupuestoSemanal();
    final nuevas = <NotificacionLocal>[];

    // Orden de prioridad: presupuesto (urgente) → plata para hoy → registro → insight
    nuevas.addAll(await _presupuestoSemanal(config, gastos, presupuesto));
    if (nuevas.length + yaHoy >= _limitesDiario) {
      await _persistir(nuevas);
      return nuevas;
    }

    nuevas.addAll(await _plataParaHoy(config, gastos, presupuesto));
    if (nuevas.length + yaHoy >= _limitesDiario) {
      await _persistir(nuevas);
      return nuevas;
    }

    nuevas.addAll(await _registroDiario(config, gastos));
    if (nuevas.length + yaHoy >= _limitesDiario) {
      await _persistir(nuevas);
      return nuevas;
    }

    nuevas.addAll(await _insight(config, gastos));
    await _persistir(nuevas);
    return nuevas;
  }

  Future<void> _persistir(List<NotificacionLocal> nuevas) async {
    for (final n in nuevas) {
      await notificacionRepository.guardarNotificacion(n);
    }
  }

  Future<int> _totalEnviadasHoy() async {
    final lista = await notificacionRepository.obtenerNotificaciones();
    final hoy = DateTime.now();
    return lista
        .where((n) =>
            n.fecha.year == hoy.year &&
            n.fecha.month == hoy.month &&
            n.fecha.day == hoy.day)
        .length;
  }

  bool _dentroDeHorario(NotificacionConfig config) {
    final hora = DateTime.now().hour;
    return hora >= config.horaInicio && hora < config.horaFin;
  }

  Future<bool> _yaEnviadaHoy(TipoNotificacion tipo) async {
    final ultima = await notificacionRepository.ultimaEnviadaDeTipo(tipo);
    if (ultima == null) return false;
    final hoy = DateTime.now();
    return ultima.year == hoy.year &&
        ultima.month == hoy.month &&
        ultima.day == hoy.day;
  }

  // ── Trigger: presupuesto semanal ──────────────────────────────────────────

  Future<List<NotificacionLocal>> _presupuestoSemanal(
    NotificacionConfig config,
    List<Gasto> gastos,
    double presupuesto,
  ) async {
    if (config.silenciadas.contains(TipoNotificacion.presupuestoSemanal)) return [];
    if (presupuesto <= 0) return [];
    if (await _yaEnviadaHoy(TipoNotificacion.presupuestoSemanal)) return [];

    final gastado = PresupuestoSemanal().gastadoEstaSemana(gastos);
    final pct = gastado / presupuesto;
    if (pct < 0.8) return [];

    final pctStr = (pct * 100).toStringAsFixed(0);
    return [
      NotificacionLocal.nueva(
        tipo: TipoNotificacion.presupuestoSemanal,
        titulo: 'Presupuesto al $pctStr%',
        mensaje: 'Ya usaste el $pctStr% de tu presupuesto semanal. ¡Cuida los gastos que quedan!',
      ),
    ];
  }

  // ── Trigger: plata para hoy ───────────────────────────────────────────────

  Future<List<NotificacionLocal>> _plataParaHoy(
    NotificacionConfig config,
    List<Gasto> gastos,
    double presupuesto,
  ) async {
    if (config.silenciadas.contains(TipoNotificacion.plataParaHoy)) return [];
    if (await _yaEnviadaHoy(TipoNotificacion.plataParaHoy)) return [];

    final hora = DateTime.now().hour;
    if (hora < 7 || hora >= 11) return [];

    final ingresos = gastos
        .where((g) => g.tipo == TipoTransaccion.ingreso)
        .fold(0.0, (s, g) => s + g.monto);
    final egresos = gastos
        .where((g) => g.tipo == TipoTransaccion.gasto)
        .fold(0.0, (s, g) => s + g.monto);
    final saldo = ingresos - egresos;

    final disponible = presupuesto > 0
        ? PresupuestoSemanal().disponible(presupuesto: presupuesto, gastos: gastos)
        : null;
    final plata = PlataParaHoy().calcular(saldo: saldo, disponibleSemanal: disponible);

    if (plata <= 0) return [];

    return [
      NotificacionLocal.nueva(
        tipo: TipoNotificacion.plataParaHoy,
        titulo: 'Tu plata para hoy 💰',
        mensaje:
            'Hoy puedes gastar aproximadamente ${Formatos.moneda(plata)} sin descuadrar tu semana.',
      ),
    ];
  }

  // ── Trigger: registro diario ──────────────────────────────────────────────

  Future<List<NotificacionLocal>> _registroDiario(
    NotificacionConfig config,
    List<Gasto> gastos,
  ) async {
    if (config.silenciadas.contains(TipoNotificacion.registroDiario)) return [];
    if (await _yaEnviadaHoy(TipoNotificacion.registroDiario)) return [];

    final hora = DateTime.now().hour;
    if (hora < 14) return []; // Solo recordar en la tarde

    final hoy = DateTime.now();
    final tieneHoy = gastos.any((g) =>
        g.fecha.year == hoy.year &&
        g.fecha.month == hoy.month &&
        g.fecha.day == hoy.day);
    if (tieneHoy) return [];

    return [
      NotificacionLocal.nueva(
        tipo: TipoNotificacion.registroDiario,
        titulo: '¿Registraste tus gastos de hoy?',
        mensaje:
            'Llevar un registro diario te ayuda a tomar mejores decisiones con tu dinero.',
      ),
    ];
  }

  // ── Trigger: insight semanal ──────────────────────────────────────────────

  Future<List<NotificacionLocal>> _insight(
    NotificacionConfig config,
    List<Gasto> gastos,
  ) async {
    if (config.silenciadas.contains(TipoNotificacion.insight)) return [];
    if (await _yaEnviadaHoy(TipoNotificacion.insight)) return [];

    // Solo los lunes
    if (DateTime.now().weekday != DateTime.monday) return [];

    final mensaje = _detectarCambioCategoria(gastos);
    if (mensaje == null) return [];

    return [
      NotificacionLocal.nueva(
        tipo: TipoNotificacion.insight,
        titulo: 'Resumen de la semana 📊',
        mensaje: mensaje,
      ),
    ];
  }

  String? _detectarCambioCategoria(List<Gasto> gastos) {
    final ahora = DateTime.now();
    final inicioEsta = _inicioSemana(ahora);
    final inicioAnterior = inicioEsta.subtract(const Duration(days: 7));

    CategoriaGasto? categoriaDestacada;
    double mayorIncremento = 0;

    for (final cat in CategoriaGasto.values) {
      final esta = _gastosPorCategoria(gastos, cat, inicioEsta, inicioEsta.add(const Duration(days: 7)));
      final anterior = _gastosPorCategoria(gastos, cat, inicioAnterior, inicioEsta);
      if (anterior > 0 && esta > anterior) {
        final delta = esta - anterior;
        if (delta > mayorIncremento) {
          mayorIncremento = delta;
          categoriaDestacada = cat;
        }
      }
    }

    if (categoriaDestacada == null || mayorIncremento < 5000) return null;
    return 'Esta semana gastaste más en ${categoriaDestacada.nombre.toLowerCase()} que la anterior (${Formatos.moneda(mayorIncremento)} más). ¿Cómo lo ves?';
  }

  double _gastosPorCategoria(
    List<Gasto> gastos,
    CategoriaGasto cat,
    DateTime desde,
    DateTime hasta,
  ) {
    return gastos
        .where((g) =>
            g.tipo == TipoTransaccion.gasto &&
            g.categoria == cat &&
            !g.fecha.isBefore(desde) &&
            g.fecha.isBefore(hasta))
        .fold(0.0, (s, g) => s + g.monto);
  }

  DateTime _inicioSemana(DateTime fecha) {
    final d = DateTime(fecha.year, fecha.month, fecha.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }
}

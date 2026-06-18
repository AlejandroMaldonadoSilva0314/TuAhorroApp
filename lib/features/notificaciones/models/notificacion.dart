import 'package:uuid/uuid.dart';

enum TipoNotificacion {
  registroDiario,
  plataParaHoy,
  presupuestoSemanal,
  metaAhorro,
  prestamos,
  insight;

  String get nombre {
    const nombres = {
      TipoNotificacion.registroDiario: 'Registro diario',
      TipoNotificacion.plataParaHoy: 'Plata para Hoy',
      TipoNotificacion.presupuestoSemanal: 'Presupuesto',
      TipoNotificacion.metaAhorro: 'Metas de ahorro',
      TipoNotificacion.prestamos: 'Préstamos',
      TipoNotificacion.insight: 'Insights',
    };
    return nombres[this]!;
  }
}

class NotificacionLocal {
  final String id;
  final TipoNotificacion tipo;
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  final bool leida;

  const NotificacionLocal({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    this.leida = false,
  });

  factory NotificacionLocal.nueva({
    required TipoNotificacion tipo,
    required String titulo,
    required String mensaje,
  }) {
    return NotificacionLocal(
      id: const Uuid().v4(),
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      fecha: DateTime.now(),
    );
  }

  NotificacionLocal copyWith({bool? leida}) {
    return NotificacionLocal(
      id: id,
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      fecha: fecha,
      leida: leida ?? this.leida,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'tipo': tipo.name,
        'titulo': titulo,
        'mensaje': mensaje,
        'fecha': fecha.toIso8601String(),
        'leida': leida,
      };

  factory NotificacionLocal.fromMap(Map<String, dynamic> map) {
    return NotificacionLocal(
      id: map['id'] as String,
      tipo: TipoNotificacion.values.byName(map['tipo'] as String),
      titulo: map['titulo'] as String,
      mensaje: map['mensaje'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      leida: map['leida'] as bool? ?? false,
    );
  }
}

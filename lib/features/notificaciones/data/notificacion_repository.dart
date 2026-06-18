import '../models/notificacion.dart';
import '../models/notificacion_config.dart';

abstract class NotificacionRepository {
  Future<List<NotificacionLocal>> obtenerNotificaciones();
  Future<void> guardarNotificacion(NotificacionLocal notificacion);
  Future<void> marcarLeida(String id);
  Future<void> eliminarNotificacion(String id);
  Future<NotificacionConfig> obtenerConfig();
  Future<void> guardarConfig(NotificacionConfig config);
  Future<DateTime?> ultimaEnviadaDeTipo(TipoNotificacion tipo);
}

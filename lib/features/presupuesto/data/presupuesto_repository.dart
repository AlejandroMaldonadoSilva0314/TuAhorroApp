import 'package:shared_preferences/shared_preferences.dart';

class PresupuestoRepository {
  static const _clave = 'presupuesto_semanal';

  Future<double> obtener() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_clave) ?? 0;
  }

  Future<void> guardar(double monto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_clave, monto);
  }
}

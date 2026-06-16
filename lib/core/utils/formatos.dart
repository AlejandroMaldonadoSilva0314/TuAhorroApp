import 'package:intl/intl.dart';

/// Utilidades de formateo para el mercado colombiano.
class Formatos {
  Formatos._();

  static final _monedaFormatter = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  static final _fechaFormatter = DateFormat("d 'de' MMMM, y", 'es_CO');

  /// Formatea un monto en COP. Ej: 15000 → "$ 15.000"
  static String moneda(double monto) => _monedaFormatter.format(monto);

  /// Formatea una fecha en español colombiano. Ej: "14 de junio, 2026"
  static String fecha(DateTime dt) => _fechaFormatter.format(dt);
}

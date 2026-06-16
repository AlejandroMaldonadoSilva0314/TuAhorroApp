import '../models/bolsillo.dart';
import '../models/categoria.dart';
import '../models/fiado.dart';
import '../models/gasto.dart';
import '../models/meta_ahorro.dart';

abstract class GastoRepository {
  Future<List<Gasto>> obtenerGastos();
  Future<void> agregarGasto(Gasto gasto);
  Future<void> eliminarGasto(String id);

  Future<double> obtenerPresupuestoSemanal();
  Future<void> guardarPresupuestoSemanal(double monto);

  Future<List<Bolsillo>> obtenerBolsillos();
  Future<void> agregarBolsillo(Bolsillo bolsillo);
  Future<void> actualizarBolsillo(Bolsillo bolsillo);
  Future<void> eliminarBolsillo(String id);

  Future<List<Fiado>> obtenerFiados();
  Future<void> agregarFiado(Fiado fiado);
  Future<void> actualizarFiado(Fiado fiado);
  Future<void> eliminarFiado(String id);

  Future<List<MetaAhorro>> obtenerMetas();
  Future<void> agregarMeta(MetaAhorro meta);
  Future<void> actualizarMeta(MetaAhorro meta);
  Future<void> eliminarMeta(String id);

  Future<List<Categoria>> obtenerCategorias();
  Future<void> agregarCategoria(Categoria categoria);
  Future<void> actualizarCategoria(Categoria categoria);
  Future<void> eliminarCategoria(String id);
}

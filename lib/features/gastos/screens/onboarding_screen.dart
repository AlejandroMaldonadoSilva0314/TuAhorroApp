import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../data/gasto_repository.dart';
import '../logic/settings_service.dart';
import '../models/app_settings.dart';
import '../models/bolsillo.dart';
import '../models/categoria.dart';
import '../models/gasto.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.repository,
    required this.onCompleted,
  });

  final GastoRepository repository;
  final void Function(AppSettings) onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _settingsService = SettingsService();
  int _paginaActual = 0;

  final _presupuestoController = TextEditingController();
  final _bolsilloNombreController = TextEditingController();
  final _bolsilloMontoController = TextEditingController();
  final _txTituloController = TextEditingController();
  final _txMontoController = TextEditingController();
  String _txCategoriaId = 'comida';

  bool _txRegistrada = false;

  double _presupuestoFinal = 0;
  String? _bolsilloNombre;
  String? _txTitulo;
  double? _txMonto;

  @override
  void dispose() {
    _pageController.dispose();
    _presupuestoController.dispose();
    _bolsilloNombreController.dispose();
    _bolsilloMontoController.dispose();
    _txTituloController.dispose();
    _txMontoController.dispose();
    super.dispose();
  }

  void _siguiente() {
    if (_paginaActual < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _omitir() async {
    await _completarOnboarding();
  }

  Future<void> _completarOnboarding() async {
    final settings = (await _settingsService.cargar()).copyWith(
      onboardingCompletado: true,
      presupuestoSemanal: _presupuestoFinal,
    );
    await _settingsService.guardar(settings);
    if (_presupuestoFinal > 0) {
      await widget.repository.guardarPresupuestoSemanal(_presupuestoFinal);
    }
    widget.onCompleted(settings);
  }

  Future<void> _guardarPresupuesto() async {
    final monto = double.tryParse(
          _presupuestoController.text.replaceAll(',', '.'),
        ) ??
        0;
    _presupuestoFinal = monto;
    _siguiente();
  }

  Future<void> _guardarBolsillo() async {
    final nombre = _bolsilloNombreController.text.trim();
    if (nombre.isNotEmpty) {
      final saldo = double.tryParse(
            _bolsilloMontoController.text.replaceAll(',', '.'),
          ) ??
          0;
      await widget.repository.agregarBolsillo(Bolsillo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre,
        saldoInicial: saldo,
      ));
      _bolsilloNombre = nombre;
    }
    _siguiente();
  }

  Future<void> _guardarTransaccion() async {
    final titulo = _txTituloController.text.trim();
    final monto = double.tryParse(
          _txMontoController.text.replaceAll(',', '.'),
        ) ??
        0;
    if (titulo.isNotEmpty && monto > 0) {
      await widget.repository.agregarGasto(Gasto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: titulo,
        monto: monto,
        categoriaId: _txCategoriaId,
        fecha: DateTime.now(),
      ));
      _txTitulo = titulo;
      _txMonto = monto;
      setState(() => _txRegistrada = true);
    }
    _siguiente();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(child: _buildIndicador(cs)),
                  TextButton(
                    onPressed: _omitir,
                    child: Text('Omitir',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _paginaActual = i),
                children: [
                  _paso1Bienvenida(cs),
                  _paso2Presupuesto(cs),
                  _paso3Bolsillo(cs),
                  _paso4Transaccion(cs),
                  _paso5Resumen(cs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicador(ColorScheme cs) {
    return Row(
      children: List.generate(5, (i) {
        return Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i <= _paginaActual
                  ? cs.primary
                  : cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _paso1Bienvenida(ColorScheme cs) {
    return _pasoBase(
      icono: Icons.savings_rounded,
      titulo: 'Bienvenido a TuAhorro',
      descripcion:
          'Tu app de finanzas personales.\n\n'
          '"Plata para Hoy" te muestra cuánto puedes gastar hoy '
          'basado en tu presupuesto semanal y lo que ya gastaste. '
          'Así siempre sabes si vas bien o te estás pasando.',
      cs: cs,
      boton: 'Comenzar',
      onBoton: _siguiente,
    );
  }

  Widget _paso2Presupuesto(ColorScheme cs) {
    return _pasoBase(
      icono: Icons.account_balance_wallet_rounded,
      titulo: 'Tu presupuesto semanal',
      descripcion:
          '¿Cuánto quieres gastar por semana?\n'
          'Esto calcula tu "Plata para Hoy" automáticamente.',
      cs: cs,
      contenidoExtra: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: TextField(
          controller: _presupuestoController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: cs.primary,
            letterSpacing: -0.5,
          ),
          decoration: const InputDecoration(
            prefixText: '\$ ',
            hintText: '150000',
          ),
        ),
      ),
      boton: 'Siguiente',
      onBoton: _guardarPresupuesto,
    );
  }

  Widget _paso3Bolsillo(ColorScheme cs) {
    return _pasoBase(
      icono: Icons.wallet_rounded,
      titulo: 'Crea un bolsillo',
      descripcion:
          'Los bolsillos separan tu plata por propósito.\n'
          'Ejemplo: "Arriendo", "Mercado", "Ahorros".\n'
          'Este paso es opcional.',
      cs: cs,
      contenidoExtra: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _bolsilloNombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del bolsillo',
                hintText: 'Ej: Mercado',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bolsilloMontoController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
              decoration: const InputDecoration(
                prefixText: '\$ ',
                labelText: 'Saldo inicial (opcional)',
                hintText: '0',
              ),
            ),
          ],
        ),
      ),
      boton: 'Siguiente',
      onBoton: _guardarBolsillo,
    );
  }

  Widget _paso4Transaccion(ColorScheme cs) {
    return _pasoBase(
      icono: Icons.receipt_long_rounded,
      titulo: 'Registra tu primer gasto',
      descripcion: '¿En qué gastaste hoy?',
      cs: cs,
      contenidoExtra: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _txTituloController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej: Almuerzo',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _txMontoController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
              decoration: const InputDecoration(
                prefixText: '\$ ',
                labelText: 'Monto',
                hintText: '12000',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _txCategoriaId,
              decoration: const InputDecoration(
                labelText: 'Categoría',
              ),
              items: Categoria.predeterminadas
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.nombre),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _txCategoriaId = v);
              },
            ),
          ],
        ),
      ),
      boton: 'Registrar',
      onBoton: _guardarTransaccion,
    );
  }

  Widget _paso5Resumen(ColorScheme cs) {
    return _pasoBase(
      icono: Icons.check_circle_rounded,
      titulo: '¡Todo listo!',
      descripcion: 'Tu app está configurada.',
      cs: cs,
      contenidoExtra: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.cardSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.cardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_presupuestoFinal > 0)
                _resumenItem(
                  Icons.account_balance_wallet_rounded,
                  'Presupuesto semanal',
                  '\$${_presupuestoFinal.toStringAsFixed(0)}',
                  cs,
                ),
              if (_presupuestoFinal > 0)
                _resumenItem(
                  Icons.today_rounded,
                  'Plata para Hoy',
                  '\$${(_presupuestoFinal / 7).toStringAsFixed(0)}',
                  cs,
                ),
              if (_bolsilloNombre != null)
                _resumenItem(
                  Icons.wallet_rounded,
                  'Bolsillo creado',
                  _bolsilloNombre!,
                  cs,
                ),
              if (_txRegistrada && _txTitulo != null)
                _resumenItem(
                  Icons.receipt_long_rounded,
                  'Primer gasto',
                  '$_txTitulo - \$${_txMonto?.toStringAsFixed(0) ?? '0'}',
                  cs,
                ),
              if (_presupuestoFinal == 0 &&
                  _bolsilloNombre == null &&
                  !_txRegistrada)
                Text('Puedes configurar todo desde Ajustes.',
                    style: TextStyle(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ),
      boton: 'Ir al Dashboard',
      onBoton: _completarOnboarding,
    );
  }

  Widget _resumenItem(IconData icono, String label, String valor, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, size: 18, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                Text(valor,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pasoBase({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required ColorScheme cs,
    required String boton,
    required VoidCallback onBoton,
    Widget? contenidoExtra,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(flex: 1),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 56, color: cs.primary),
          ),
          const SizedBox(height: 28),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            descripcion,
            style: TextStyle(fontSize: 15, color: cs.onSurfaceVariant, height: 1.5),
            textAlign: TextAlign.center,
          ),
          if (contenidoExtra != null) ...[
            const SizedBox(height: 28),
            contenidoExtra,
          ],
          const Spacer(flex: 2),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onBoton,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(boton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

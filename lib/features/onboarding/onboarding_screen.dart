import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onCompleto});

  final VoidCallback onCompleto;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _pagina = 0;

  static const _slides = [
    _Slide(
      emoji: '👋',
      gradientColors: [Color(0xFF4C1D95), Color(0xFF7B2FF7)],
      titulo: 'Bienvenido a TuAhorro',
      descripcion:
          'La app para estudiantes colombianos que quieren controlar su plata y construir buenos hábitos financieros.',
    ),
    _Slide(
      emoji: '☀️',
      gradientColors: [Color(0xFF1E40AF), Color(0xFF7C3AED)],
      titulo: 'Plata para Hoy',
      descripcion:
          'Cada mañana sabrás exactamente cuánto puedes gastar sin afectar tu semana. Sin cálculos, sin estrés.',
    ),
    _Slide(
      emoji: '💰',
      gradientColors: [Color(0xFF065F46), Color(0xFF059669)],
      titulo: 'Bolsillos virtuales',
      descripcion:
          'Organiza tu dinero en sobres digitales: arriendo, comida, salidas... cada peso en su lugar.',
    ),
    _Slide(
      emoji: '🎯',
      gradientColors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
      titulo: 'Metas de ahorro',
      descripcion:
          'Fija objetivos y ve cómo crece tu ahorro semana a semana. Ese viaje, ese computador, esa independencia.',
    ),
  ];

  void _siguiente() {
    if (_pagina < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _terminar();
    }
  }

  void _terminar() {
    widget.onCompleto();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_pagina];
    final esUltima = _pagina == _slides.length - 1;

    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Fondo con gradiente animado
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  slide.gradientColors[0].withValues(alpha: 0.6),
                  colorScheme.surface,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Botón saltar
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _terminar,
                    child: Text(
                      'Saltar',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _pagina = i),
                    itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
                  ),
                ),

                // Dots + botón
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.base,
                    AppSpacing.xl,
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    children: [
                      // Indicadores de página
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _pagina == i ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _pagina == i
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Botón principal
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: colorScheme.heroGradient,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.45),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _siguiente,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: Center(
                              child: Text(
                                esUltima ? 'Comenzar' : 'Siguiente',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── SLIDE ─────────────────────────────────────────────────────────────────────

class _Slide {
  const _Slide({
    required this.emoji,
    required this.gradientColors,
    required this.titulo,
    required this.descripcion,
  });

  final String emoji;
  final List<Color> gradientColors;
  final String titulo;
  final String descripcion;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono central
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: slide.gradientColors,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              boxShadow: [
                BoxShadow(
                  color: slide.gradientColors[1].withValues(alpha: 0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Center(
              child: Text(
                slide.emoji,
                style: const TextStyle(fontSize: 52),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            slide.titulo,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.8,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            slide.descripcion,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

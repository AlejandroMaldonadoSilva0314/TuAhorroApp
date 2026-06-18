import 'package:flutter/material.dart';

import '../../../core/theme/app_themes.dart';
import '../../../core/theme/theme_scope.dart';
import '../../notificaciones/widgets/notificaciones_ajustes_section.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  String _selectedId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedId = ThemeScope.of(context).id;
  }

  void _selectTheme(AppTheme theme) {
    setState(() => _selectedId = theme.id);
    ThemeScope.controllerOf(context).setTheme(theme);
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ThemeScope.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalización'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appTheme.gradient),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          Text(
            'Tema de la aplicación',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Elige la identidad visual de TuAhorro',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 24,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: AppThemes.all.length,
            itemBuilder: (context, i) {
              final theme = AppThemes.all[i];
              final isSelected = theme.id == _selectedId;
              return _ThemeSphere(
                theme: theme,
                isSelected: isSelected,
                onTap: () => _selectTheme(theme),
              );
            },
          ),
          const SizedBox(height: 36),
          _ThemePreview(appTheme: appTheme),
          const SizedBox(height: 36),
          const Divider(),
          const SizedBox(height: 24),
          const NotificacionesAjustesSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ThemeSphere extends StatelessWidget {
  const _ThemeSphere({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  final AppTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: isSelected ? 60 : 54,
            height: isSelected ? 60 : 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: theme.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2.5)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.gradientColors[1].withValues(alpha: 0.55),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                : null,
          ),
          const SizedBox(height: 7),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            child: Text(
              theme.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.appTheme});

  final AppTheme appTheme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: appTheme.gradient,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Vista previa · ${appTheme.name}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // AppBar mock
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 46,
              decoration: BoxDecoration(gradient: appTheme.gradient),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'TuAhorro',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Icon(Icons.palette_outlined,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Card mock
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 52,
              decoration: BoxDecoration(gradient: appTheme.gradientCard),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.today_rounded,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Plata para Hoy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Text(
                    '\$45.000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Progress bar mock
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Presupuesto semanal',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 0.62,
                  minHeight: 8,
                  backgroundColor:
                      colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

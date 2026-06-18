import 'package:flutter/material.dart';
import 'app_themes.dart';
import 'theme_controller.dart';

class ThemeScope extends InheritedWidget {
  const ThemeScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final ThemeController controller;

  static AppTheme of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ThemeScope>()!
      .controller
      .current;

  static ThemeController controllerOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ThemeScope>()!
      .controller;

  @override
  bool updateShouldNotify(ThemeScope old) =>
      controller.current.id != old.controller.current.id;
}

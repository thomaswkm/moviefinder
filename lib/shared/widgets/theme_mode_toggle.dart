import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_controller.dart';

class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({super.key, required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final themeMode = controller.themeMode;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Semantics(
          button: true,
          label: 'Cambiar tema',
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: controller.cycleThemeMode,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.18),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  _iconFor(themeMode),
                  key: ValueKey(themeMode),
                  color: themeMode == ThemeMode.system
                      ? Theme.of(context).colorScheme.onSurface
                      : AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _iconFor(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.system => Icons.brightness_auto,
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
    };
  }
}

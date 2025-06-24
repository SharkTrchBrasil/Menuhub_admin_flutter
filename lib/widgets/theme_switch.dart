import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/core/theme/theme_provider.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return IconButton(
      icon: Icon(
        isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
        color: Theme.of(context).iconTheme.color,
      ),
      tooltip: isDark ? 'Modo Claro' : 'Modo Escuro',
      onPressed: () {
        final newTheme = isDark ? ThemeMode.light : ThemeMode.dark;
        themeProvider.setTheme(newTheme);
      },
    );
  }
}

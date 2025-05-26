import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/core/theme/theme_provider.dart';


class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width, // Use MediaQuery para obter a largura
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF1D1D1) : Colors.white, // Substitua notifire.darkmaincontain
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  if (themeProvider.isDarkMode) {
                    Provider.of<ThemeProvider>(context, listen: false).setTheme(ThemeMode.light);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: !themeProvider.isDarkMode ? const Color(0xFFE0E0E0) : Colors.transparent, // Substitua notifire.getsecoundcontain
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        Text('Light', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black)), // Substitua context.theme.textcolore
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/images/sun.png',
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black, // Substitua notifire.textcolore
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  if (!themeProvider.isDarkMode) {
                    Provider.of<ThemeProvider>(context, listen: false).setTheme(ThemeMode.dark);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode ? const Color(0xFFE0E0E0) : Colors.transparent, // Substitua notifire.getsecoundcontain
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        Text('Dark', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black)), // Substitua notifire.textcolore
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/images/moon.png',
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black, // Substitua notifire.textcolore
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
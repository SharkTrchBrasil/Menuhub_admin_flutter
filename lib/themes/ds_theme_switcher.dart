import 'package:flutter/material.dart';

import 'ds_theme.dart';


class DsThemeSwitcher extends ChangeNotifier {
  DsTheme theme = DsTheme(
    primaryColor: Color(0xFFff0502),
    mode: DsThemeMode.light,
    fontFamily: DsThemeFontFamily.roboto,
    themeName: DsThemeName.classic,
  );

  void changeTheme(DsTheme newTheme) {
    theme = newTheme;
    notifyListeners();
  }

  void updatePrimaryColor(Color color) {
    theme = theme.copyWith(primaryColor: color);
    notifyListeners();
  }

  void toggleThemeMode() {
    theme = theme.copyWith(
      mode: theme.mode == DsThemeMode.light
          ? DsThemeMode.dark
          : DsThemeMode.light,
    );
    notifyListeners();
  }

  void changeFontFamily(DsThemeFontFamily fontFamily) {
    theme = theme.copyWith(fontFamily: fontFamily);
    notifyListeners();
  }

  void changeThemeName(DsThemeName themeName) {
    theme = theme.copyWith(themeName: themeName);
    notifyListeners();
  }
}
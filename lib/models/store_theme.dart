import 'package:flutter/material.dart';

enum DsThemeFontFamily {
  roboto,
  montserrat,
  lato,
  openSans,
  poppins;

  String get nameGoogle {
    switch (this) {
      case DsThemeFontFamily.roboto:
        return 'Roboto';
      case DsThemeFontFamily.montserrat:
        return 'Montserrat';
      case DsThemeFontFamily.lato:
        return 'Lato';
      case DsThemeFontFamily.openSans:
        return 'Open Sans';
      case DsThemeFontFamily.poppins:
        return 'Poppins';
    }
  }
}

enum DsThemeMode { light, dark }

enum DsThemeName {
  classic('Classic'),
  fancy('Fancy'),
  minimal('Minimal'),
  modern('Modern'),
  street('Street'),
  custom('Custom');

  final String title;
  const DsThemeName(this.title);

  String get name => title.toLowerCase();
}

class StoreTheme {
  StoreTheme({
    required this.primaryColor,
    required this.mode,
    required this.fontFamily,
    required this.themeName,
  });

  final Color primaryColor;
  final DsThemeMode  mode;
  final DsThemeFontFamily fontFamily;
  final DsThemeName themeName;

  static int hexToInteger(String hex) => int.parse(hex, radix: 16);

  factory StoreTheme.fromJson(Map<String, dynamic> map) {
    return StoreTheme(
      primaryColor: Color(hexToInteger(map['primary_color'])),
      mode: DsThemeMode.values.firstWhere((e) => e.name == map['mode']),
      fontFamily: DsThemeFontFamily.values.byName(map['font_family']),
      themeName: DsThemeName.values.firstWhere(
            (e) => e.name == map['theme_name'],
        orElse: () => DsThemeName.custom,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_color': primaryColor.value.toRadixString(16),
      'mode': mode.name,
      'font_family': fontFamily.name,
      'theme_name': themeName.name,
    };
  }

  StoreTheme copyWith({
    Color? primaryColor,
    DsThemeMode ? mode,
    DsThemeFontFamily? fontFamily,
    DsThemeName? themeName,
  }) {
    return StoreTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      mode: mode ?? this.mode,
      fontFamily: fontFamily ?? this.fontFamily,
      themeName: themeName ?? this.themeName,
    );
  }

  // Método para gerar cores derivadas baseadas no tema
  Color get secondaryColor {
    // Lógica para gerar cor secundária baseada na primária
    final hsl = HSLColor.fromColor(primaryColor);
    return hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor();
  }

  Color get backgroundColor {
    return mode == ThemeMode.light ? Colors.white : Colors.black;
  }

  Color get onPrimaryColor {
    // Retorna cor contrastante com a primária
    return primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

// Adicione outros métodos para cores derivadas conforme necessário
}
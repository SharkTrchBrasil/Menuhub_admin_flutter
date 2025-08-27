import 'package:flutter/material.dart';

enum DsThemeFontFamily {
  roboto('Roboto'),
  montserrat('Montserrat'),
  lato('Lato'),
  openSans('Open Sans'),
  poppins('Poppins');

  final String title;

  const DsThemeFontFamily(this.title);
}

enum DsThemeMode {
  light,
  dark;
}

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

class DsTheme {
  DsTheme({
    required this.primaryColor,
    required this.mode,
    required this.fontFamily,
    required this.themeName,
  });

  final Color primaryColor;
  final DsThemeMode mode;
  final DsThemeFontFamily fontFamily;
  final DsThemeName themeName;

  // Cores derivadas calculadas
  Color get secondaryColor {
    final hsl = HSLColor.fromColor(primaryColor);
    return hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor();
  }

  Color get backgroundColor {
    return mode == DsThemeMode.light ? Colors.white : Colors.black;
  }

  Color get cardColor {
    return mode == DsThemeMode.light ? Colors.white : Colors.grey[900]!;
  }

  Color get inactiveColor {
    return mode == DsThemeMode.light ? Colors.grey[300]! : Colors.grey[700]!;
  }

  Color get onPrimaryColor {
    return primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Color get onSecondaryColor {
    return secondaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Color get onBackgroundColor {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Color get onCardColor {
    return cardColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Color get onInactiveColor {
    return inactiveColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  // Métodos de serialização
  static int hexToInteger(String hex) => int.parse(hex, radix: 16);

  factory DsTheme.fromJson(Map<String, dynamic> map) {
    return DsTheme(
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

  DsTheme copyWith({
    Color? primaryColor,
    DsThemeMode? mode,
    DsThemeFontFamily? fontFamily,
    DsThemeName? themeName,
  }) {
    return DsTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      mode: mode ?? this.mode,
      fontFamily: fontFamily ?? this.fontFamily,
      themeName: themeName ?? this.themeName,
    );
  }

  // Estilos de texto
  TextStyle get displayExtraLargeTextStyle => TextStyle(
    fontSize: 32,
    color: onBackgroundColor,
    fontFamily: fontFamily.title,
    fontWeight: FontWeight.bold,
  );

  TextStyle get displayLargeTextStyle => TextStyle(
    fontSize: 24,
    color: onBackgroundColor,
    fontFamily: fontFamily.title,
    fontWeight: FontWeight.bold,
  );

  TextStyle get displayMediumTextStyle => TextStyle(
    fontSize: 20,
    color: onBackgroundColor,
    fontFamily: fontFamily.title,
    fontWeight: FontWeight.w600,
  );

  TextStyle get headingTextStyle => TextStyle(
    fontSize: 18,
    color: onBackgroundColor,
    fontFamily: fontFamily.title,
    fontWeight: FontWeight.w600,
  );

  TextStyle get bodyTextStyle => TextStyle(
    fontSize: 16,
    color: onBackgroundColor,
    fontFamily: fontFamily.title,
  );

  TextStyle get paragraphTextStyle => TextStyle(
    fontSize: 14,
    color: onBackgroundColor,
    fontFamily: fontFamily.title,
  );

  TextStyle get smallTextStyle => TextStyle(
    fontSize: 12,
    color: onBackgroundColor,
    fontFamily: fontFamily.title,
  );

  TextStyle get extraSmallTextStyle => TextStyle(
    fontSize: 10,
    color: onBackgroundColor,
    fontFamily: fontFamily.title,
  );
}

extension TextStyleX on TextStyle {
  TextStyle colored(Color color) => copyWith(color: color);
  TextStyle weighted(FontWeight weight) => copyWith(fontWeight: weight);
}
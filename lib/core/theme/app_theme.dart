import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../themes/ds_theme.dart';

class AppTheme {
  AppTheme._();

  // Método para criar ThemeData a partir de DsTheme
  static ThemeData fromDsTheme(DsTheme dsTheme) {
    final bool isLight = dsTheme.mode == DsThemeMode.light;

    return ThemeData(
      useMaterial3: true,
      brightness: isLight ? Brightness.light : Brightness.dark,
      primaryColor: dsTheme.primaryColor,
      scaffoldBackgroundColor: dsTheme.backgroundColor,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,

      colorScheme: ColorScheme.fromSeed(
        seedColor: dsTheme.primaryColor,
        primary: dsTheme.primaryColor,
        secondary: dsTheme.secondaryColor,
        background: dsTheme.backgroundColor,
        surface: dsTheme.cardColor,
        onPrimary: dsTheme.onPrimaryColor,
        onSecondary: dsTheme.onSecondaryColor,
        onBackground: dsTheme.onBackgroundColor,
        onSurface: dsTheme.onCardColor,
        error: Colors.deepOrange,
        brightness: isLight ? Brightness.light : Brightness.dark,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: dsTheme.cardColor,
        foregroundColor: dsTheme.onCardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
      ),

      // TEMA DA TABBAR ADICIONADO AQUI
      tabBarTheme: TabBarThemeData(
        labelColor: dsTheme.primaryColor,
        unselectedLabelColor: isLight ? Colors.grey[600] : Colors.grey[400],
        indicatorColor: dsTheme.primaryColor,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: dsTheme.fontFamily.title,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16,
          fontFamily: dsTheme.fontFamily.title,
        ),
        // Remove efeitos de overlay (hover e splash)
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        // Remove a margem padrão das tabs
       // labelPadding: EdgeInsets.zero,
        // Alinha as tabs ao início
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: dsTheme.primaryColor,
              width: 2.0,
            ),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: dsTheme.cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: dsTheme.inactiveColor),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dsTheme.cardColor,
        hintStyle: TextStyle(
          fontFamily: dsTheme.fontFamily.title,
          color: dsTheme.inactiveColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dsTheme.inactiveColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dsTheme.inactiveColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dsTheme.primaryColor, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dsTheme.primaryColor,
          foregroundColor: dsTheme.onPrimaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          overlayColor: Colors.transparent,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: dsTheme.primaryColor,
          overlayColor: Colors.transparent,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        checkColor: MaterialStateProperty.all(dsTheme.onPrimaryColor),
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return dsTheme.primaryColor;
          }
          return Colors.white;
        }),
        side: const BorderSide(color: Colors.black, width: 1.5),
      ),

      textTheme: _buildTextTheme(dsTheme),
    );
  }

  // Método para construir text theme baseado no DsTheme
  static TextTheme _buildTextTheme(DsTheme dsTheme) {
    final baseTextStyle = TextStyle(
      fontFamily: dsTheme.fontFamily.title,
      color: dsTheme.onBackgroundColor,
    );

    return TextTheme(
      displayLarge: baseTextStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: baseTextStyle.copyWith(
        fontSize: 16,
      ),
      titleLarge: baseTextStyle.copyWith(
        fontSize: 14,
      ),
      bodyLarge: baseTextStyle.copyWith(
        fontSize: 16,
      ),
      bodyMedium: baseTextStyle.copyWith(
        fontSize: 14,
      ),
      labelLarge: baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: baseTextStyle.copyWith(
        fontSize: 12,
      ),
      labelSmall: baseTextStyle.copyWith(
        fontSize: 10,
      ),
    );
  }

  // ===================================================================
  // --- TEMA CLARO PADRÃO (LIGHT THEME) ---
  // ===================================================================
  static final ThemeData lightTheme = fromDsTheme(
    DsTheme(
      primaryColor: const Color(0xFFff0502),
      mode: DsThemeMode.light,
      fontFamily: DsThemeFontFamily.roboto,
      themeName: DsThemeName.classic,
    ),
  );

  // ===================================================================
  // --- TEMA ESCURO PADRÃO (DARK THEME) ---
  // ===================================================================
  static final ThemeData darkTheme = fromDsTheme(
    DsTheme(
      primaryColor: const Color(0xFFff0502),
      mode: DsThemeMode.dark,
      fontFamily: DsThemeFontFamily.roboto,
      themeName: DsThemeName.classic,
    ),
  );
}
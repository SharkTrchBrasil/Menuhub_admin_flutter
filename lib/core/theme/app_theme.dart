import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../extensions/colors.dart';

class AppTheme {
  AppTheme._();


  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    splashColor: Color(0xFF020B12),
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,

    scaffoldBackgroundColor: Color(0xFF020B12),

    primaryColor: Color(0xFFA347FF),

    colorScheme: ColorScheme.dark(
      primary: Color(0xFFA347FF),
      secondary: Color(0xFF73E325),
      error: Color(0xFFFC871D),
      background: Color(0xFF020B12),
      surface: Color(0xFF060e19),
      onPrimary: Colors.white,
      onBackground: Color(0xFFEBEBEB),
      onSurface: Colors.white, // aqui é a cor do texto sobre surface
    ),

    disabledColor: Color(0xFF818795),
    dividerColor: Color(0xFFB5B5B5),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      hintStyle: GoogleFonts.inter(
        color: Color(0xFF818795), // textSecondaryColor
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(color: Color(0xFF818795)),
      hoverColor: Colors.transparent,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF060e19), // mais escuro que scaffold
      foregroundColor: Colors.white,
      surfaceTintColor: Color(0xFF060e19),
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
    ),


    tabBarTheme: TabBarThemeData(
      splashFactory: NoSplash.splashFactory,
      overlayColor: MaterialStateProperty.all(Colors.transparent), // Remove efeito de clique
      mouseCursor: MaterialStateProperty.all(MouseCursor.defer), // Remove mudança de cursor
      indicatorColor: primaryColor,
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey,
      dividerColor: Colors.transparent,
    ),


    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF060e19), // mais escuro que scaffold (personalizado)
      surfaceTintColor: Color(0xFF060e19),
      shadowColor: Colors.transparent,
    ),

    cardTheme:  CardThemeData(
      color: Color(0xFF060e19), // levemente mais claro que drawer
      elevation: 0,
      shadowColor: Colors.transparent,
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: Colors.white,
      textColor: Colors.white,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFA85BF7),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFB5B5B5)), // textPrimaryColor
        bodyMedium: TextStyle(color: Color(0xFFB5B5B5)),

        titleLarge: TextStyle(
          color: Color(0xFFB5B5B5),
          fontWeight: FontWeight.bold,
          fontSize: 14,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF020B12),
      selectedItemColor: Color(0xff194BFB),
      unselectedItemColor: Colors.white,
      showUnselectedLabels: true,
    ),

    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      checkColor: MaterialStateProperty.all(Colors.white),
      fillColor: MaterialStateProperty.all(Color(0xFFA85BF7)),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );























  static final ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: primaryColor,
    iconTheme: const IconThemeData(color: Colors.black),
    dividerColor: viewLineColor,
    cardColor: cardLightColor,

    listTileTheme: ListTileThemeData(
      iconColor: Colors.black, // Cor dos ícones (leading e trailing)
      textColor: Colors.black, // Cor do texto (opcional)
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor:  Color(0xffFfffff),
      shadowColor: Colors.transparent,
      foregroundColor: Colors.black,
    ),

    tabBarTheme: TabBarThemeData(
      splashFactory: NoSplash.splashFactory,
      indicatorColor: primaryColor,
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey,
      dividerColor: Colors.transparent,
    ),


    cardTheme: CardThemeData(
      color: const Color(0xffFFFFFF),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),// Cor branca

    ),

    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xffFAFAFA),
      shadowColor: Colors.transparent,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true, // <- necessário para `fillColor` funcionar
      fillColor: Colors.transparent, // <- deixa o fundo transparente
      hintStyle: GoogleFonts.inter(
        color: Colors.grey, // ou notifire.getGry600_500Color
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hoverColor: Colors.transparent, // 🚫 Remove efeito cinza no hover
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey),
      ),
      labelStyle: TextStyle(color: Colors.black), // Cor da label (ex: "Nome")
      // Cor do hintText, se usado

      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey), // Borda quando foca
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey), // Borda padrão
      ),

    ),




    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:  Color(0xffffffff),

      selectedItemColor: Color(0xff194BFB),

      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
    ),

    colorScheme: const ColorScheme(
      primary: primaryColor,
      secondary: primaryColor,
      surface: Colors.white,
      background: whiteColor,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.redAccent,
      brightness: Brightness.light,
    ),

    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      checkColor: MaterialStateProperty.all(Colors.white),
      fillColor: MaterialStateProperty.all(primaryColor),
    ),

    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Colors.black,),
        bodyMedium: TextStyle(color: Colors.black),
        titleLarge: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
      ),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );



}



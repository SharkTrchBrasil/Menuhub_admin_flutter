import 'package:flutter/material.dart';

enum StoreThemeFontFamily {
  roboto('Roboto'),
  montserrat('Montserrat'),
  lato('Lato'),
  openSans('Open Sans');

  final String title;

  const StoreThemeFontFamily(this.title);
}

class StoreTheme {
  StoreTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.onPrimaryColor,
    required this.onSecondaryColor,
    required this.onBackgroundColor,
    required this.onCardColor,
    required this.inactiveColor,
    required this.onInactiveColor,
    required this.fontFamily,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color inactiveColor;

  final Color onPrimaryColor;
  final Color onSecondaryColor;
  final Color onBackgroundColor;
  final Color onCardColor;
  final Color onInactiveColor;
  final StoreThemeFontFamily fontFamily;

  static int hexToInteger(String hex) => int.parse(hex, radix: 16);

  factory StoreTheme.fromJson(Map<String, dynamic> map) {
    return StoreTheme(
      primaryColor: Color(hexToInteger(map['primary_color'])),
      secondaryColor: Color(hexToInteger(map['secondary_color'])),
      backgroundColor: Color(hexToInteger(map['background_color'])),
      cardColor: Color(hexToInteger(map['card_color'])),
      onPrimaryColor: Color(hexToInteger(map['on_primary_color'])),
      onSecondaryColor: Color(hexToInteger(map['on_secondary_color'])),
      onBackgroundColor: Color(hexToInteger(map['on_background_color'])),
      onCardColor: Color(hexToInteger(map['on_card_color'])),
      inactiveColor: Color(hexToInteger(map['inactive_color'])),
      onInactiveColor: Color(hexToInteger(map['on_inactive_color'])),
      fontFamily: StoreThemeFontFamily.values.byName(map['font_family']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_color': primaryColor.toARGB32().toRadixString(16),
      'secondary_color': secondaryColor.toARGB32().toRadixString(16),
      'background_color': backgroundColor.toARGB32().toRadixString(16),
      'card_color': cardColor.toARGB32().toRadixString(16),
      'on_primary_color': onPrimaryColor.toARGB32().toRadixString(16),
      'on_secondary_color': onSecondaryColor.toARGB32().toRadixString(16),
      'on_background_color': onBackgroundColor.toARGB32().toRadixString(16),
      'on_card_color': onCardColor.toARGB32().toRadixString(16),
      'inactive_color': inactiveColor.toARGB32().toRadixString(16),
      'on_inactive_color': onInactiveColor.toARGB32().toRadixString(16),
      'font_family': fontFamily.name,
    };
  }

  StoreTheme copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? cardColor,
    Color? inactiveColor,
    Color? onPrimaryColor,
    Color? onSecondaryColor,
    Color? onBackgroundColor,
    Color? onCardColor,
    Color? onInactiveColor,
    StoreThemeFontFamily? fontFamily,
  }) {
    return StoreTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardColor: cardColor ?? this.cardColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      onPrimaryColor: onPrimaryColor ?? this.onPrimaryColor,
      onSecondaryColor: onSecondaryColor ?? this.onSecondaryColor,
      onBackgroundColor: onBackgroundColor ?? this.onBackgroundColor,
      onCardColor: onCardColor ?? this.onCardColor,
      onInactiveColor: onInactiveColor ?? this.onInactiveColor,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}
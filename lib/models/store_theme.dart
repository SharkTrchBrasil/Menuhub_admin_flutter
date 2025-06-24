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

enum DsCategoryLayout {
  verticalWithSideProducts('vertical'),
  horizontalWithBelowProducts('horizontal'),
  allInOneList('all');

  final String name;
  const DsCategoryLayout(this.name);
}

enum DsProductLayout {
  grid('grid'),
  list('list');

  final String name;
  const DsProductLayout(this.name);
}

enum DsThemeName {
  classic('Classic'),
  fancy('Fancy'),
  minimal('Minimal'),
  modern('Modern'),
  street('Street');

  final String title;
  const DsThemeName(this.title);

  String get name => title.toLowerCase();
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
    required this.sidebarBackgroundColor,
    required this.sidebarTextColor,
    required this.sidebarIconColor,
    required this.categoryBackgroundColor,
    required this.categoryTextColor,
    required this.productBackgroundColor,
    required this.productTextColor,
    required this.priceTextColor,
    required this.cartBackgroundColor,
    required this.cartTextColor,
    required this.fontFamily,
    required this.themeName,
    required this.categoryLayout,
    required this.productLayout,





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

  // Novas cores
  final Color sidebarBackgroundColor;
  final Color sidebarTextColor;
  final Color sidebarIconColor;
  final Color categoryBackgroundColor;
  final Color categoryTextColor;
  final Color productBackgroundColor;
  final Color productTextColor;
  final Color priceTextColor;
  final Color cartBackgroundColor;
  final Color cartTextColor;

  final DsThemeName themeName;
  final DsThemeFontFamily fontFamily;
  final DsCategoryLayout categoryLayout;
  final DsProductLayout productLayout;

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
      sidebarBackgroundColor: Color(hexToInteger(map['sidebar_background_color'])),
      sidebarTextColor: Color(hexToInteger(map['sidebar_text_color'])),
      sidebarIconColor: Color(hexToInteger(map['sidebar_icon_color'])),
      categoryBackgroundColor: Color(hexToInteger(map['category_background_color'])),
      categoryTextColor: Color(hexToInteger(map['category_text_color'])),
      productBackgroundColor: Color(hexToInteger(map['product_background_color'])),
      productTextColor: Color(hexToInteger(map['product_text_color'])),
      priceTextColor: Color(hexToInteger(map['price_text_color'])),
      cartBackgroundColor: Color(hexToInteger(map['cart_background_color'])),
      cartTextColor: Color(hexToInteger(map['cart_text_color'])),

      themeName: DsThemeName.values.firstWhere((e) => e.name == map['theme_name']),
      fontFamily: DsThemeFontFamily.values.byName(map['font_family']),
      categoryLayout: DsCategoryLayout.values.firstWhere((e) => e.name == map['category_layout']),
      productLayout: DsProductLayout.values.firstWhere((e) => e.name == map['product_layout']),



    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_color': primaryColor.value.toRadixString(16),
      'secondary_color': secondaryColor.value.toRadixString(16),
      'background_color': backgroundColor.value.toRadixString(16),
      'card_color': cardColor.value.toRadixString(16),
      'on_primary_color': onPrimaryColor.value.toRadixString(16),
      'on_secondary_color': onSecondaryColor.value.toRadixString(16),
      'on_background_color': onBackgroundColor.value.toRadixString(16),
      'on_card_color': onCardColor.value.toRadixString(16),
      'inactive_color': inactiveColor.value.toRadixString(16),
      'on_inactive_color': onInactiveColor.value.toRadixString(16),
      'sidebar_background_color': sidebarBackgroundColor.value.toRadixString(16),
      'sidebar_text_color': sidebarTextColor.value.toRadixString(16),
      'sidebar_icon_color': sidebarIconColor.value.toRadixString(16),
      'category_background_color': categoryBackgroundColor.value.toRadixString(16),
      'category_text_color': categoryTextColor.value.toRadixString(16),
      'product_background_color': productBackgroundColor.value.toRadixString(16),
      'product_text_color': productTextColor.value.toRadixString(16),
      'price_text_color': priceTextColor.value.toRadixString(16),
      'cart_background_color': cartBackgroundColor.value.toRadixString(16),
      'cart_text_color': cartTextColor.value.toRadixString(16),
      'theme_name': themeName.name,
      'font_family': fontFamily.name,
      'category_layout': categoryLayout.name,
      'product_layout': productLayout.name,
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
    Color? sidebarBackgroundColor,
    Color? sidebarTextColor,
    Color? sidebarIconColor,
    Color? categoryBackgroundColor,
    Color? categoryTextColor,
    Color? productBackgroundColor,
    Color? productTextColor,
    Color? priceTextColor,
    Color? cartBackgroundColor,
    Color? cartTextColor,
    DsThemeFontFamily? fontFamily,
    DsThemeName? themeName,
    DsCategoryLayout? categoryLayout,
    DsProductLayout? productLayout,
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
      sidebarBackgroundColor: sidebarBackgroundColor ?? this.sidebarBackgroundColor,
      sidebarTextColor: sidebarTextColor ?? this.sidebarTextColor,
      sidebarIconColor: sidebarIconColor ?? this.sidebarIconColor,
      categoryBackgroundColor: categoryBackgroundColor ?? this.categoryBackgroundColor,
      categoryTextColor: categoryTextColor ?? this.categoryTextColor,
      productBackgroundColor: productBackgroundColor ?? this.productBackgroundColor,
      productTextColor: productTextColor ?? this.productTextColor,
      priceTextColor: priceTextColor ?? this.priceTextColor,
      cartBackgroundColor: cartBackgroundColor ?? this.cartBackgroundColor,
      cartTextColor: cartTextColor ?? this.cartTextColor,
      fontFamily: fontFamily ?? this.fontFamily,
      themeName: themeName ?? this.themeName,
      categoryLayout: categoryLayout ?? this.categoryLayout,
      productLayout: productLayout ?? this.productLayout,
    );
  }
}

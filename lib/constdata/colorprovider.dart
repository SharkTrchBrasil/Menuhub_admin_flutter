
import 'package:flutter/material.dart';

import 'colorfile.dart';

class ColorNotifire with ChangeNotifier {

  get getIsDark => isDark;
  get getTextColor => isDark ? darkTitleColor : titleColor;
  get getIconColor => isDark ? darkIconColor : iconColor;
  get getBgColor => isDark ? darkBgColor : bgColor;
  get getTextGryColor => isDark ? darkGryColor : gryColor;
  get getContainerColor => isDark ? darkContainerColor : containerColor;
  get getContainerColor2 => isDark ? darkContainerColor2 : containerColor2;
  get getBorderColor => isDark ? darkBorderColor : borderColor;
  get getWhitAndBlack => isDark ?  whiteColor : blackColor;
  get getDrawerColor => isDark ? darkDrawerColor : drawerColor;
  get getAppBarColor => isDark ? darkAppbarColor : appbarColor;
  get getGry500_600Color => isDark ? greyscale500 : greyscale600;
  get getGry600_500Color => isDark ? greyscale600 : greyscale500;
  get getGry700_300Color => isDark ? greyscale700 : greyscale300;
  get getGry100_300Color => isDark ? newcolor : greyscale300;
  get getGry50_800Color => isDark ? greyscale800 : greyscale50;
  get getGry700_800Color => isDark ? greyscale700 : greyscale200;


  bool _isDark = false;
  bool get isDark => _isDark;

  void isavalable(bool value) {
    _isDark = value;
    notifyListeners();
  }

}

import 'package:flutter/cupertino.dart';

import 'colorprovider.dart';



ColorNotifire notifire = ColorNotifire();

class Typographyy with ChangeNotifier {

  //Heading
  static TextStyle heading1 = TextStyle(fontWeight: FontWeight.w700,fontSize: 48,fontFamily: "Gilroy-ExtraBold",color: notifire.getTextColor);
  static TextStyle heading2 = TextStyle(fontWeight: FontWeight.w700,fontSize: 40,fontFamily: "Gilroy-ExtraBold",color: notifire.getTextColor);
  static TextStyle heading3 = TextStyle(fontWeight: FontWeight.w700,fontSize: 32,fontFamily: "Gilroy-ExtraBold",color: notifire.getTextColor);
  static TextStyle heading4 = TextStyle(fontWeight: FontWeight.w700,fontSize: 24,fontFamily: "Gilroy-ExtraBold",color: notifire.getTextColor);
  static TextStyle heading5 = TextStyle(fontWeight: FontWeight.w700,fontSize: 20,fontFamily: "Gilroy-ExtraBold",color: notifire.getTextColor);
  static TextStyle heading6 = TextStyle(fontWeight: FontWeight.w700,fontSize: 18,fontFamily: "Gilroy-ExtraBold",color: notifire.getTextColor);

  //Body

  //...............bodyXLarge.............
  static TextStyle bodyXLargeExtraBold =  TextStyle(fontSize: 18,fontWeight: FontWeight.w600,fontFamily: "Gilroy-ExtraBold",color: notifire.getTextColor);
  static TextStyle bodyXLargeSemiBold =  TextStyle(fontSize: 18,fontWeight: FontWeight.w500,fontFamily: "Gilroy-SemiBold",color: notifire.getTextColor);
  static TextStyle bodyXLargeMedium =  TextStyle(fontSize: 18,fontWeight: FontWeight.w400,fontFamily: "Gilroy-Medium",color: notifire.getTextColor);
  static TextStyle bodyXLargeRegular =  TextStyle(fontSize: 18,fontWeight: FontWeight.w300,fontFamily: "Gilroy-Regular",color: notifire.getTextColor);

  //...............bodyLarge.............
  static TextStyle bodyLargeExtraBold =  TextStyle(fontSize: 16,fontWeight: FontWeight.w600,fontFamily: "Gilroy-ExtraBold",color: notifire.getTextColor);
  static TextStyle bodyLargeSemiBold =  TextStyle(fontSize: 16,fontWeight: FontWeight.w500,fontFamily: "Gilroy-SemiBold",color: notifire.getTextColor);
  static TextStyle bodyLargeMedium =  TextStyle(fontSize: 16,fontWeight: FontWeight.w400,fontFamily: "Gilroy-Medium",color: notifire.getTextColor);
  static TextStyle bodyLargeRegular =  TextStyle(fontSize: 16,fontWeight: FontWeight.w300,fontFamily: "Gilroy-Regular",color: notifire.getTextColor);

  //................bodyMedium................
  static TextStyle bodyMediumExtraBold =  TextStyle(fontSize: 14,fontWeight: FontWeight.w600,fontFamily: "Gilroy-ExtraBold",color: notifire.getTextColor);
  static TextStyle bodyMediumSemiBold =  TextStyle(fontSize: 14,fontWeight: FontWeight.w500,fontFamily: "Gilroy-SemiBold",color: notifire.getTextColor);
  static TextStyle bodyMediumMedium =  TextStyle(fontSize: 14,fontWeight: FontWeight.w400,fontFamily: "Gilroy-Medium",color: notifire.getTextColor);
  static TextStyle bodyMediumRegular =  TextStyle(fontSize: 14,fontWeight: FontWeight.w300,fontFamily: "Gilroy-Regular",color: notifire.getTextColor);

  //................bodySmall.................
  static TextStyle bodySmallExtraBold =  TextStyle(fontSize: 12,fontWeight: FontWeight.w600,fontFamily: "Gilroy-ExtraBold",color: notifire.getTextColor);
  static TextStyle bodySmallSemiBold =  TextStyle(fontSize: 12,fontWeight: FontWeight.w400,fontFamily: "Gilroy-SemiBold",color: notifire.getTextColor);
  static TextStyle bodySmallMedium =  TextStyle(fontSize: 12,fontWeight: FontWeight.w400,fontFamily: "Gilroy-Medium",color: notifire.getTextColor);
  static TextStyle bodySmallRegular =  TextStyle(fontSize: 12,fontWeight: FontWeight.w300,fontFamily: "Gilroy-Regular",color: notifire.getTextColor);

  //...............bodyXSmall....................
  static TextStyle bodyXSmallExtraBold =  TextStyle(fontSize: 10,fontWeight: FontWeight.w600,fontFamily: "Gilroy-ExtraBold",color: notifire.getTextColor);
  static TextStyle bodyXSmallSemiBold =  TextStyle(fontSize: 10,fontWeight: FontWeight.w500,fontFamily: "Gilroy-SemiBold",color: notifire.getTextColor);
  static TextStyle bodyXSmallMedium =  TextStyle(fontSize: 10,fontWeight: FontWeight.w400,fontFamily: "Gilroy-Medium",color: notifire.getTextColor);
  static TextStyle bodyXSmallRegular =  TextStyle(fontSize: 10,fontWeight: FontWeight.w300,fontFamily: "Gilroy-Regular",color: notifire.getTextColor);

}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';



class MyWalletsController extends GetxController implements GetxService{

  bool isMoonIn = true;
  bool isMoonOut = false;
  bool isMenuOpen = false;
  bool isMenuOpen1 = false;
  bool isMenuOpen2 = false;
  bool isCheckBox = false;
  bool isCheckBox1 = false;
  bool isCheckBox2 = false;
  bool isCheckBox3 = false;
  bool isCheckBox4 = false;
  bool isCheckBox5 = false;
  bool isCurrencyMenu = false;
  bool isLoading = false;
  List currencyLogo = [
    "assets/images/in.svg",
    "assets/images/pt.svg",
    "assets/images/us.svg",
  ];
  List currencyName = [
    "Rupee",
    "Euro",
    "Dollar",
  ];
  int selectCurrency = 0;
  offIsLoading(context,double width){
    isLoading = true;
    update();
    Timer(const Duration(seconds: 2), () {
      isLoading = false;
      update();
      Get.back();
   //   complete1(context, width: width);
    });
  }
  setSelectCurrency(value){
    selectCurrency = value;
    update();
  }
  int selectPayment = 0;
  setIsCurrencyMenu(value){
    isCurrencyMenu = value;
    update();
  }
  setPayment(value){
    selectPayment = value;
    update();
  }
  List paymentList = [
    "assets/images/visa.png",
    "assets/images/mastercarde.png",
    "assets/images/payaneer.png",
  ];
  List paymentName = [
    "Visa",
    "Master Card",
    "Payaneer",
  ];
  ScrollController scrollController = ScrollController();
  List usersProfile = [
    "assets/images/add.png",
    "assets/images/05.png",
    "assets/images/01.png",
    "assets/images/02.png",
    "assets/images/03.png",
    "assets/images/04.png",
    "assets/images/02.png",
    "assets/images/05.png",
    "assets/images/01.png",
    "assets/images/02.png",
    "assets/images/03.png",
    "assets/images/04.png",
    "assets/images/05.png",
  ];
  List usersName = [
    "Add",
    "Hugo First",
    "Percy Vere",
    "Jack Aranda",
    "Olive Tree",
    "John Quil",
    "Glad I. Oli",
    "Hugo First",
    "Percy Vere",
    "Jack Aranda",
    "Olive Tree",
    "John Quil",
    "Glad I. Oli",
  ];
  List listOfMonths = [
    "This Month",
    "Last Month",
    "This Year",
  ];
  List menuIteam = [
    "IND",
    "USD",
    "GBP",
    "EUR"
  ];
  int selectMenuIteam = 0;
  int selectMenuIteam1 = 1;
  int selectListIteam = 0;
  setListValue(value){
    selectListIteam = value;
    update();
  }
  setSelectMenuIteam(value){
    selectMenuIteam = value;
    update();
  }
  setSelectMenuIteam1(value){
    selectMenuIteam1 = value;
    update();
  }
  setIsMoonIn(value){
    isMoonIn = value;
    update();
  }
  setIsCheckBox(value){
    isCheckBox = value;
    update();
  }
  setIsCheckBox1(value){
    isCheckBox1 = value;
    update();
  }
  setIsCheckBox2(value){
    isCheckBox2 = value;
    update();
  }
  setIsCheckBox3(value){
    isCheckBox3 = value;
    update();
  }
  setIsCheckBox4(value){
    isCheckBox4 = value;
    update();
  }
  setIsCheckBox5(value){
    isCheckBox5 = value;
    update();
  }
  setMenuOpen(value){
    isMenuOpen = value;
    update();
  }
  setMenuOpen1(value){
    isMenuOpen1 = value;
    update();
  }
  setMenuOpen2(value){
    isMenuOpen2 = value;
    update();
  }
  setIsMoonOut(value){
    isMoonOut = value;
    update();
  }


}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';





class DrawerControllerr extends GetxController implements GetxService{

  int currentIndex = -1;
  int currentcolor = 0;
  RxInt index = 0.obs;
  // RxInt pageSelecter = 0.obs;
  RxBool istrue = false.obs;
  int selectedTile = -1.obs;


  bool isRtl = false;

  setRTL(bool value){
    isRtl = value;
    update();
  }
  bool isLoading = false;

  offIsLoading(context,double width){
    isLoading = true;
    update();
    Timer(const Duration(seconds: 2), () {
      isLoading = false;
      update();

      Get.back();
      Navigator.pushNamed(context, '/dashboard');
      function(value: -1);
      colorSelecter(value: 0);

    });
  }


  List page = [

  ].obs;


  List pageTitle = [
    'Dashboard',
    'Invoices',
    'Messages',
    'My Wallets',
    'Dashboard',
    'Credit Card',
    'BankDeposit',
    'Sell Crypto',
    'Sign In',
    'Sign up',
    'Authentication',
    'ForgetPassword',
    'Reason',
    'Transactions',
    'Recipients',
    'Analytics',
    'GetHelp',
    'Settings',
  ];


  bool isTransfer = false;
  setIsTransfer(value){
    isTransfer = value;
    update();
   }


   bool isFrom = false;

   setIsFrom(value){
     isFrom = value;
     update();
   }

  bool isto = false;

  setIsTo(value){
    isto = value;
    update();
  }

bool isCoin = false;
  setIsCoin(value){
    isCoin = value;
    update();
  }

 int selectFrom = 0;
  setSelectFrom(value){
    selectFrom = value;
    update();
  }
  List from = [
    "Spot",
    "Margin",
    "Fiat",
    "P2P",
    "Convert",
  ];

  int selectTo = 0;
  setSelectTo(value){
    selectTo = value;
    update();
  }
  List to = [
    "COIN-M Futures",
    "USD-M Futures",
    "Options",
    "Spot Wallet",
  ];

  int selectCoins = 0;
  setSelectCoin(value){
    selectCoins = value;
    update();
  }
  List coins = [
    "Bitcoin",
    "Binance Coin",
    "Dogecoin",
    "Cardano",
    "Ethereum",
  ];



  function({required int value}){
    currentIndex = value;
    update();
  }

  colorSelecter({required int value}){
    currentcolor = value;
    update();
  }
}
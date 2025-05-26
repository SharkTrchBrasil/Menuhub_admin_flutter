import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/columcard.dart';
import '../widgets/comuncard2.dart';


class DashBordeController extends GetxController implements GetxService {
  int iteamcount = 4;
  int coinselecter = 0;
  int coinselecter1 = 2;

  bool istextishide = true;
  bool ismenuopen = false;
  bool ismenuopen1 = false;


  setistextishide(bool value){
    istextishide = value;
    update();
  }

  ismenu(bool value){
  ismenuopen = value;
  update();
}
  ismenu1(bool value){
    ismenuopen1 = value;
    update();
  }

  selectcoin(int value){
    coinselecter = value;
    update();
  }

  selectcoin1(int value){
    coinselecter1 = value;
    update();
  }

  setiteamcount(int value){
    iteamcount = value;
    update();
  }

List cards1 =[
  const ComunCard(price: "1,077.3 USD", color1: Color(0xff0CAF60), color2: Color(0xff4ADE80), subtitle: "Main Account", pr: 0.4),
  const ComunCard(price: "3,233.3 USD", color1: Color(0xff26A17B), color2: Color(0xff2DD4BF), subtitle: "Trading Account", pr: 0.7),
  const ComunCard(price: "423.3 USD", color1: Color(0xffFB774A), color2: Color(0xffFFC837), subtitle: "Margin Account", pr: 0.3),
  const ComunCard(price: "1,563.3 USD", color1: Color(0xffED6167), color2: Color(0xffDD3333), subtitle: "Futures Account", pr: 0.6),

];

  List cards2 =[
    const ComunCard2(title: "35%", color: Color(0xffFFAA35), coin: "Bitcoin", price: '\$14,522',pr: 35,),
    const ComunCard2(title: "10%", color: Color(0xff4464EE), coin: "Waves", price: '\$250',pr: 10,),
    const ComunCard2(title: "50%", color: Color(0xffFB774A), coin: "Avax", price: '\$26',pr: 50,),
    const ComunCard2(title: "70%", color: Color(0xffDD3333), coin: "Ethereum", price: '\$1326',pr: 70,),
  ];

  List listOfCoin = [
    "assets/images/btc.png",
    "assets/images/eth.png",
    "assets/images/eth-1.png",
    "assets/images/trx.png",
  ];

  List coinsName = [
    "Btc",
    "Eth",
    "Pol",
    "Trx",

  ];

}

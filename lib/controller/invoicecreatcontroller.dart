import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoiceCreatController extends GetxController implements GetxService {

  int currencySelect = 0;
  bool menuopen = false;
  bool payment = false;
  bool fees = false;
  bool notice = false;

  TextEditingController itemController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController hoursController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController totalController = TextEditingController();

bool isDropDown = false;

setIsDropDown(value){
  isDropDown = value;
  update();
}

int selectDrop = 0;

setSelectDrop(value){
  selectDrop = value;
  update();
}
  List dropdown1 = [
    "CoinDash Enterprise",
    "Earthx Enterprise",
    "GodL Enterprise",
    "S8ul Enterprise",
  ];

  List dropdown1value = [
    "A53f22s3",
    "Am29ee95t",
    "G64df3421",
    "S4Q0xdfs5",
  ];

  List items = [
    "Desing System",
  ];
  List qty = [
    "5",
  ];
  List hours = [
    "50",
  ];
  List rate = [
    "\$10"
  ];
  List total = [
    "\$292"
  ];

 setIteamAdd(){

   if(itemController.text.isNotEmpty && qtyController.text.isNotEmpty && hoursController.text.isNotEmpty && rateController.text.isNotEmpty && totalController.text.isNotEmpty){

   items.add(itemController.text);
   qty.add(qtyController.text);
   hours.add(hoursController.text);
   rate.add(rateController.text);
   total.add(totalController.text);


   itemController.text = "";
   qtyController.text = "";
   hoursController.text = "";
   rateController.text = "";
   totalController.text = "";
   update();

 }else{

 }


 }


  bool isAddItem = false;

  setIsAddItem(value){
    isAddItem =! isAddItem;
    update();
  }




  setpayment(value){
    payment = value;
    update();
  }
  setfees(value){
    fees = value;
    update();
  }
  setnotice(value){
    notice = value;
    update();
  }

  setmenu(value){
    menuopen = value;
    update();
  }


  setCurrency(value){
    currencySelect = value;
    update();
  }


  List currencyName = [
    "IND (india rupee)",
    "AE (Arab Dirham)",
    "CAD (Canadian Dollar)",
  ];

  List currencyLogo = [
    "assets/images/in.svg",
    "assets/images/ae.svg",
    "assets/images/cn.svg",
  ];


}
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoiceController extends GetxController implements GetxService{
  var checkBoxs = [];
  var popupcolorchack = [];
  bool  checkboxis = false;
  bool ismenuopen = false;
  int selectpage = 0;
  int loadmore = 7;

  ScrollController scrollController = ScrollController();

  setloadmore(value){
    loadmore = value;
    update();
  }

  setpage(value){
    selectpage = value;
    update();
  }


  List listtiletitle = [
    "New Design Project",
    "Crypto Project",
    "Sarimun Design",
    "Abstergo Development",
    "Barone Website",
    "Biffco Mobile App",
    "Biffco Mobile App",
    "Crypto Project",
    "Barone Website",
    "New Design Project",
    "Crypto Project",
    "Sarimun Design",
    "Abstergo Development",
    "Barone Website",
    "Biffco Mobile App",
    "Biffco Mobile App",
    "Crypto Project",
    "Barone Website",
  ];
  List date = [
    "January 05, 2022",
    "January 06, 2022",
    "January 08, 2022",
    "January 15, 2022",
    "January 29, 2022",
    "December 05, 2022",
    "December 12, 2022",
    "December 25, 2022",
    "December 30, 2022",
    "January 05, 2022",
    "January 06, 2022",
    "January 08, 2022",
    "January 15, 2022",
    "January 29, 2022",
    "December 05, 2022",
    "December 12, 2022",
    "December 25, 2022",
    "December 30, 2022",
  ];
  List clint = [
    "Biffco Enterprises",
    "Acme Co.",
    "Big Kahuna Burger",
    "Abstergo Ltd.",
    "Barone LLC.",
    "Biffco Enterprises",
    "Biffco Enterprises",
    "Acme Co.",
    "Big Kahuna Burger",
    "Biffco Enterprises",
    "Acme Co.",
    "Big Kahuna Burger",
    "Abstergo Ltd.",
    "Barone LLC.",
    "Biffco Enterprises",
    "Biffco Enterprises",
    "Acme Co.",
    "Big Kahuna Burger",
  ];
  List price = [
    "\$1,200",
    "\$2,700",
    "\$1,400",
    "\$4,240",
    "\$1,221",
    "\$3,250",
    "\$4,750",
    "\$3,350",
    "\$1,756",
    "\$1,200",
    "\$2,700",
    "\$1,400",
    "\$4,240",
    "\$1,221",
    "\$3,250",
    "\$4,750",
    "\$3,350",
    "\$1,756",
  ];
  List status = [
    "Unpaid",
    "Pending",
    "Pending",
    "Pending",
    "Unpaid",
    "Refund",
    "Paid",
    "Paid",
    "Paid",
    "Unpaid",
    "Pending",
    "Pending",
    "Pending",
    "Unpaid",
    "Refund",
    "Paid",
    "Paid",
    "Paid",
  ];
  List iteamcolor = [
    const Color(0xff936DFF),
    const Color(0xffFF784B),
    const Color(0xffFF784B),
    const Color(0xffFF784B),
    const Color(0xff936DFF),
    const Color(0xffFACC15),
    const Color(0xff22C55E),
    const Color(0xff22C55E),
    const Color(0xff22C55E),
    const Color(0xff936DFF),
    const Color(0xffFF784B),
    const Color(0xffFF784B),
    const Color(0xffFF784B),
    const Color(0xff936DFF),
    const Color(0xffFACC15),
    const Color(0xff22C55E),
    const Color(0xff22C55E),
    const Color(0xff22C55E),
  ];

  setmenuu(value){
    ismenuopen = value;
    update();
  }

  int selectindex = 10;

  setindexforitem(value){
    selectindex = value;
    update();
  }

  setchekboxis(value){
    checkboxis = value;
    update();
  }

  selcetcheckbox(index){
    if(checkBoxs.contains(index)){
      checkBoxs.remove(index);
      update();
    }else{
      checkBoxs.add(index);
      update();
    }
  }
}
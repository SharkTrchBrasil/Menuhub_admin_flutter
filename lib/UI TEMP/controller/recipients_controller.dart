import 'package:get/get.dart';

class RecipientsController extends GetxController implements GetxService {

  bool isCurrency = false;

  setIsCurrency(bool value){
    isCurrency = value;
    update();
  }


  bool isRecipientsType = false;

  setIsRecipientsType(bool value){
    isRecipientsType = value;
    update();
  }


  int currencySelect = 0;

  setCurrencySelect(int value){
    currencySelect = value;
    update();
  }
  List currency =[
    "IND",
    "US",
    "CND",
    "PTR"
  ];
  List currencyLogo = [
    "assets/images/in.svg",
    "assets/images/us.svg",
    "assets/images/cn.svg",
    "assets/images/pt.svg",
  ];

  int typeSelect = 0;
  setTypeSelect(int value){
    typeSelect = value;
    update();
  }

  List type = [
    "Business",
    "Personal",
  ];

}
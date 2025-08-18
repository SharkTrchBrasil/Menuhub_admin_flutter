import 'package:get/get.dart';

class AppBarController extends GetxController implements GetxService{

  bool isnotification = false;
  bool isAccount = false;
  bool isLanguage = false;
  bool isSearch = false;
  int lenguageselcet = 0;

  List lanuage = [
    "India",
    "Arab",
    "China",
    "Spain",
    "France",
    "Portugal",
  ];

  List countryLogo = [
    "assets/images/in.svg",
    "assets/images/ae.svg",
    "assets/images/cn.svg",
    "assets/images/es.svg",
    "assets/images/fr.svg",
    "assets/images/pt.svg",
  ];

  selectlanguage(int value){
    lenguageselcet = value;
    update();
  }

  selectisSearch(bool value){
    isSearch = value;
    update();
  }

  setisnotification(bool value){
    isnotification = value;
    update();
  }
  setisAccount(bool value){
    isAccount = value;
    update();
  }
  setisLanguage(bool value){
    isLanguage = value;
    update();
  }
}
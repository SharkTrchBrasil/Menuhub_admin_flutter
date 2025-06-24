

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


import '../../UI TEMP/controller/get_code.dart';

import '../../widgets/appbarcode.dart';
import '../../widgets/drawercode.dart';
import '../base/BasePage.dart';
import 'package:totem_pro_admin/core/helpers/navigation.dart';


class HomePage extends StatefulWidget {
  final Widget shell;
  final int storeId;

  const HomePage({super.key, required this.shell, required this.storeId});

  @override
  State<HomePage> createState() => _HomePageState();





}




class _HomePageState extends State<HomePage> {
  InboxController inboxController = Get.put(InboxController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final StoreNavigationHelper navHelper;


  @override
  void initState() {
    super.initState();
    navHelper = StoreNavigationHelper(widget.storeId);
  }


  @override
  Widget build(BuildContext context) {





    final String currentUrl = GoRouterState.of(context).uri.toString();
    final String currentTitle = navHelper.getCurrentTitle(currentUrl);



    return BasePage(

      mobileBuilder: (BuildContext context) {
        return Column(
          children: [
            // laout(),
            // Inbox()
            Expanded(child: widget.shell)
          ],
        );

      },
      desktopBuilder: (BuildContext context) {
        return     Container(
          height: MediaQuery.of(context).size.height,
          width:  MediaQuery.of(context).size.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrawerCode(storeId: widget.storeId,),

              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [


                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,

                        child: appber(storeId: widget.storeId,),
                      ),




                      Expanded(
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: widget.shell
                          // Inbox(),
                          //  laout(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },

      mobileBottomNavigationBar:


      navHelper.shouldShowBottomBar(currentUrl)
          ? navHelper.buildBottomNavigationBar(
        context,
        currentUrl,
        scaffoldKey,
      )
          : null,

     // mobileAppBar:   navHelper.shouldShowAppBarCode(currentUrl) ? appber( storeId: widget.storeId, ) : null,



    );
  }
}

  
  











// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:totem_pro_admin/pages/base/BasePage.dart';
// import 'package:totem_pro_admin/core/helpers/navigation.dart'; // seu helper
//
// import '../../ConstData/colorprovider.dart';
// import '../../ConstData/typography.dart';
// import '../../UI TEMP/controller/drawercontroller.dart';
// import '../../widgets/drawercode.dart';
// import '../../widgets/appbarcode.dart';
//
// class HomePage extends StatefulWidget {
//   final Widget shell;
//   final int storeId;
//
//   const HomePage({super.key, required this.shell, required this.storeId});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   late final StoreNavigationHelper navHelper;
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//     navHelper = StoreNavigationHelper(widget.storeId);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final String currentUrl = GoRouterState.of(context).uri.toString();
//     final String currentTitle = navHelper.getCurrentTitle(currentUrl);
//     // final bool showDrawer = !(isDesktop() && currentRoute == '/storespedidos');
//
//     return BasePage(
//       mobileBuilder: (BuildContext context) {
//         return Scaffold(
//           body: Container(
//             width: double.infinity,
//             height: double.infinity,
//             color: notifire.getBgColor,
//             child: Column(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 15.0),
//                     child: widget.shell,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//       desktopBuilder: (BuildContext context) {
//         return Row(
//           children: [
//         DrawerCode(size: 12,),//storeId: widget.storeId),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   AppBarCode(title: currentTitle),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 15.0),
//                       child: widget.shell,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//
//
//
//       mobileBottomNavigationBar:
//           navHelper.shouldShowBottomBar(currentUrl)
//               ? navHelper.buildBottomNavigationBar(
//                 context,
//                 currentUrl,
//                 scaffoldKey,
//               )
//               : null,
//     );
//   }
// }

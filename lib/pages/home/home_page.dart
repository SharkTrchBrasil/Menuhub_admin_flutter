

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


import '../../UI TEMP/controller/get_code.dart';

import '../../cubits/store_manager_cubit.dart';
import '../../cubits/store_manager_state.dart';
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


    return BlocListener<StoresManagerCubit, StoresManagerState>(
      // Ouve as mudanças no estado do StoresManagerCubit
      listenWhen: (previous, current) {
        // Só executa o listener se o ID da loja ativa realmente mudou
        if (previous is StoresManagerLoaded && current is StoresManagerLoaded) {
          return previous.activeStoreId != current.activeStoreId;
        }
        return false;
      },
      listener: (context, state) {
        // A mágica da navegação acontece aqui!
        if (state is StoresManagerLoaded) {
          final newStoreId = state.activeStoreId;
          final currentPath = GoRouterState.of(context).uri.toString();

          final parts = currentPath.split('/');
          String newPath;
          if (parts.length > 3 && parts[1] == 'stores') {
            // Recria a URL: /stores/NOVO_ID/subrota_atual
            parts[2] = newStoreId.toString();
            newPath = parts.join('/');
          } else {
            // Se não conseguir encontrar o padrão, vai para a página padrão de pedidos
            newPath = '/stores/$newStoreId/orders';
          }

          print("✅ BLOCLISTENER: Navegando para a nova rota: $newPath");
          context.go(newPath);
        }
      },
      child: BasePage(
        // O resto do seu widget BasePage e suas propriedades continuam aqui,
        // exatamente como estavam antes.
        mobileBuilder: (BuildContext context) {
          return Column(
            children: [
              Expanded(child: widget.shell)
            ],
          );
        },
        desktopBuilder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
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
                        Expanded(
                          child: SizedBox(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: widget.shell
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
        mobileBottomNavigationBar: navHelper.shouldShowBottomBar(currentUrl)
            ? navHelper.buildBottomNavigationBar(context, currentUrl, scaffoldKey)
            : null,
      ),
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

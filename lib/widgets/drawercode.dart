// ignore_for_file: non_constant_identifier_names, camel_case_types, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/widgets/theme_switch.dart';
import 'package:totem_pro_admin/widgets/select_store.dart';



import '../UI TEMP/controller/get_code.dart';

import '../core/di.dart';
import '../models/store.dart';
import '../repositories/store_repository.dart';
import 'appbarcode.dart';
import '../core/extensions/extensions.dart';




class DrawerCode extends StatefulWidget {

  final int storeId;

  const DrawerCode({super.key, required this.storeId});

  @override
  State<DrawerCode> createState() => _DrawerCodeState();
}

class _DrawerCodeState extends State<DrawerCode> {
  InboxController inboxController = Get.put(InboxController());

  @override
  void initState() {
    super.initState();
  }



  final StoreRepository storeRepository = getIt();

  @override
  Widget build(BuildContext context) {

    return GetBuilder<InboxController>(
      builder: (inboxController) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: 280,
              child: Drawer(

                child: Column(
                  children: [
                  //  SizedBox(height: widget.size < 700 ? 30 : 20),
                    Row(
                      children: [
                        const SizedBox(width: 20),

                        InkWell(
                          onTap: () {
                            inboxController.setTextIsTrue(0);
                          },
                          child: const Image(
                            image: AssetImage('assets/images/Symbol.png'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            inboxController.setTextIsTrue(0);
                          },
                          child: Text(
                            'PDVix',
                            style: TextStyle(
                              fontFamily: 'Jost-SemiBold',
                              fontSize: 20,

                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            // === DASHBOARD ===
                            _buildSectionTitle('Dashboard', selected: inboxController.pageselecter >= 0 && inboxController.pageselecter <= 3),
                            buildMenuItem(
                              context: context,
                              title: 'Meus Pedidos',
                              route: '/stores/${widget.storeId}/orders',
                              index: 0,
                              iconPath: 'assets/images/package.png',
                            ),
                            buildMenuItem(
                              context: context,
                              title: 'Pedidos Balcão (PDV)',
                              route: '/stores/${widget.storeId}/pdv-orders',
                              index: 1,
                              iconPath: 'assets/images/package.png',
                            ),
                            buildMenuItem(
                              context: context,
                              title: 'Mesas',
                              route: '/stores/${widget.storeId}/tables',
                              index: 2,
                              iconPath: 'assets/images/package.png',
                            ),

                            const SizedBox(height: 30),
                            // === LOJA ===
                            _buildSectionTitle('Loja', selected: inboxController.pageselecter >= 4 && inboxController.pageselecter <= 8),
                            buildMenuItem(
                              context: context,
                              title: 'Clientes',
                              route: '/stores/${widget.storeId}/users',
                              index: 4,
                              iconPath: 'assets/images/user.png',
                            ),
                            buildMenuItem(
                              context: context,
                              title: 'Produtos',
                              route: '/stores/${widget.storeId}/products',
                              index: 5,
                              iconPath: 'assets/images/package.png',
                            ),
                            buildMenuItem(
                              context: context,
                              title: 'Adicionais',
                              route: '/stores/${widget.storeId}/variants',
                              index: 6,
                              iconPath: 'assets/images/4.png',
                            ),
                            buildMenuItem(
                              context: context,
                              title: 'Cupons',
                              route: '/stores/${widget.storeId}/coupons',
                              index: 7,
                              iconPath: 'assets/images/6.png',
                            ),
                            buildMenuItem(
                              context: context,
                              title: 'Catálogo Online',
                              route: '/stores/${widget.storeId}/catalog',
                              index: 8,
                              iconPath: 'assets/images/package.png',
                            ),
                            buildMenuItem(
                              context: context,
                              title: 'Totem',
                              route: '/stores/${widget.storeId}/totems',
                              index: 9,
                              iconPath: 'assets/images/package.png',
                            ),

                            const SizedBox(height: 30),
                            // === CONFIGURAÇÃO DA LOJA ===
                            _buildSectionTitle('Configuração da Loja', selected: inboxController.pageselecter >= 10 && inboxController.pageselecter <= 14),
                            buildMenuItem(
                              context: context,
                              title: 'Informações Gerais',
                              route: '/stores/${widget.storeId}/settings',
                              index: 10,
                              iconPath: 'assets/images/33.png',
                            ),
                            buildMenuItem(
                              context: context,
                              title: 'Horários de Atendimento',
                              route: '/stores/${widget.storeId}/settings/hours',
                              index: 11,
                              iconPath: 'assets/images/calendar-edit.png',
                            ),
                            buildMenuItem(
                              context: context,
                              title: 'Métodos de Pagamento',
                              route: '/stores/${widget.storeId}/payment-methods',
                              index: 12,
                              iconPath: 'assets/images/coins.png',
                            ),
                            buildMenuItem(
                              context: context,
                              title: 'Formas de Entrega',
                              route: '/stores/${widget.storeId}/settings/shipping',
                              index: 13,
                              iconPath: 'assets/images/box.png',
                            ),
                            buildMenuItem(
                              context: context,
                              title: 'Locais de Entrega',
                              route: '/stores/${widget.storeId}/settings/locations',
                              index: 14,
                              iconPath: 'assets/images/location-pin.png',
                            ),

                            buildMenuItem(
                              context: context,
                              title: 'Chatbot',
                              route: '/stores/${widget.storeId}/chatbot',
                              index: 15,
                              iconPath: 'assets/images/location-pin.png',
                            ),

                            const SizedBox(height: 30),
                            // === ESTOQUE ===
                            _buildSectionTitle('Estoque', selected: inboxController.pageselecter == 15),
                            buildMenuItem(
                              context: context,
                              title: 'Estoque',
                              route: '/stores/${widget.storeId}/inventory',
                              index: 16,
                              iconPath: 'assets/images/database.png',
                            ),

                            const SizedBox(height: 30),
                            // === FINANCEIRO ===
                            _buildSectionTitle('Financeiro', selected: inboxController.pageselecter >= 16 && inboxController.pageselecter <= 18),
                            buildMenuItem(
                              context: context,
                              title: 'Contas a pagar',
                              route: '/stores/${widget.storeId}/payables',
                              index: 17,
                              iconPath: 'assets/images/dollar-circle.png',
                            ),
                            buildMenuItem(
                              context: context,
                              title: 'Caixa',
                              route: '/stores/${widget.storeId}/cash',
                              index: 18,
                              iconPath: 'assets/images/hard-drive.png',
                            ),
                            buildMenuItem(
                              context: context,
                              title: 'Relatórios',
                              route: '/stores/${widget.storeId}/reports',
                              index: 19,
                              iconPath: 'assets/images/chart-trend-up1.png',
                            ),

                            const SizedBox(height: 30),
                            // === SISTEMA ===
                            _buildSectionTitle('Sistema', selected: inboxController.pageselecter >= 19),

                            buildMenuItem(
                              context: context,
                              title: 'Equipe',
                              route: '/stores/${widget.storeId}/accesses',
                              index: 20,
                              iconPath: 'assets/images/user.png',
                            ),
                            buildMenuItem(
                              context: context,
                              title: 'Planos',
                              route: '/stores/${widget.storeId}/plans',
                              index: 21,
                              iconPath: 'assets/images/rocket-launch.png',
                            ),
                          ],
                        ),
                      ),
                    ),

                   ThemeSwitcher(),


                    const SizedBox(height: 10,),




                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, {required bool selected}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,

          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }


  Widget buildMenuItem({
    required BuildContext context,
    required String title,
    required String route,
    required int index,
    required String iconPath,
  }) {
    final isSelected = inboxController.pageselecter == index;
    return Container(
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: () {
          inboxController.setTextIsTrue(index);
          context.go(route);
        },

        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
             color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).listTileTheme.textColor
          ),
        ),
        leading: Image.asset(
          iconPath,
          height: 20,
          width: 20,
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).listTileTheme.iconColor
        ),
      ),
    );
  }

  Widget buildSubItem(String title, int index, String route) {
    final isSelected = inboxController.pageselecter == index;
    return InkWell(
      onTap: () {
        inboxController.setTextIsTrue(index);
        if (route.isNotEmpty) {
          context.go(route);
          Get.back();
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 15, top: 8, bottom: 8),
        child: Row(
          children: [
            Container(
              height: 7,
              width: 7,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
              //  color: isSelected ? notifire.drwetextcode : notifire.textcolore,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle drawerSectionStyle(bool isSelected) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
     // color: isSelected ? notifire.drwetextcode : notifire.textcolore,
    );
  }
}

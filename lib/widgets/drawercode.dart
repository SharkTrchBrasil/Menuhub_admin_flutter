import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controller/inbox_controller.dart';
import '../core/menu_app_controller.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
import '../cubits/store_manager_cubit.dart';
import '../cubits/store_manager_state.dart'; // This is your DrawerControllerProvider

class DrawerCode extends StatefulWidget {
  final int storeId;

  const DrawerCode({super.key, required this.storeId});

  @override
  State<DrawerCode> createState() => _DrawerCodeState();
}

class _DrawerCodeState extends State<DrawerCode> {
  InboxController inboxController = Get.put(InboxController());

  final double _collapsedWidth = 72.0; // Largura do mini-drawer (ícone + texto)
  final double _expandedWidth = 260.0; // Largura do drawer expandido




  @override
  Widget build(BuildContext context) {
    // 1. A lógica do estado de expansão do drawer continua a mesma.
    final drawerController = context.watch<DrawerControllerProvider>();
    final bool isExpanded = drawerController.isExpanded;

    // 2. ✅ AQUI COMEÇA A GRANDE MUDANÇA: Usamos o BlocBuilder para obter os dados da loja.
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, storesState) {
        // 3. Mostra um estado de carregamento enquanto os dados da loja não chegam.
        if (storesState is! StoresManagerLoaded) {
          return Drawer(child: const Center(child: CircularProgressIndicator()));
        }
        final activeStore = storesState.activeStore;
        if (activeStore == null) {
          return Drawer(child: const Center(child: Text('Erro: Loja não encontrada.')));
        }

        // 4. ✅ A FONTE DA VERDADE CORRETA para o status da loja.
        final isSetupComplete = activeStore.core.isSetupComplete;

        // 5. O resto da sua UI é construído DENTRO do builder, agora com os dados corretos.
        return GetBuilder<InboxController>(
          builder: (inboxController) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isExpanded ? _expandedWidth : _collapsedWidth,
              child: Drawer(
                child: Column(
                  children: [
                    // ✅ CABEÇALHO: Adicionado aqui para garantir que sempre apareça.
                    Padding(
                      padding: isExpanded
                          ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0)
                          : const EdgeInsets.symmetric(vertical: 20.0),
                      child: InkWell(
                        onTap: () => drawerController.toggle(),
                        child: Row(
                          mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/Symbol.png', height: 30, width: 30),
                            if (isExpanded) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'PDVix',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontFamily: 'Jost-SemiBold',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // ✅ LISTA DE ITENS: Agora dentro de um Expanded para evitar overflow.
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isSetupComplete && isExpanded) ...[
                              _buildSetupWarning(context),
                              const Divider(),
                            ],
                            ..._buildMenuItemsFromData(
                              isSetupComplete: isSetupComplete,
                              isExpanded: isExpanded,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  // --- AUXILIARY METHODS ---
// Adicione este método dentro da sua classe _DrawerCodeState




  final List<Map<String, dynamic>> _menuData = [
    {'type': 'section', 'title': 'Dashboard', 'requiresSetup': true, 'index': 0},
    {
      'type': 'item',
      'title': 'Inicio',
      'route': '/dashboard',
      'index': 0,
      'iconPath': 'assets/images/package.png',
      'requiresSetup': true,
    },
    {
      'type': 'item',
      'title': 'Meus Pedidos',
      'route': '/orders',
      'index': 1,
      'iconPath': 'assets/images/package.png',
      'requiresSetup': true,
    },
    // Descomente se precisar
    // {
    //   'type': 'item',
    //   'title': 'Pedidos Balcão (PDV)',
    //   'route': '/pdv-orders',
    //   'index': 2,
    //   'iconPath': 'assets/images/package.png',
    //   'requiresSetup': true,
    // },
    // {
    //   'type': 'item',
    //   'title': 'Mesas',
    //   'route': '/tables',
    //   'index': 3,
    //   'iconPath': 'assets/images/package.png',
    //   'requiresSetup': true,
    // },

    {'type': 'spacer'},


    {
      'type': 'item',
      'title': 'Produtos',
      'route': '/products',
      'index': 4,
      'iconPath': 'assets/images/package.png',
      'requiresSetup': true,
    },

    {
      'type': 'item',
      'title': 'Cupons',
      'route': '/coupons',
      'index': 5,
      'iconPath': 'assets/images/6.png',
      'requiresSetup': true,
    },
    // Descomente se precisar
    // {
    //   'type': 'item',
    //   'title': 'Banners',
    //   'route': '/banners',
    //   'index': 6,
    //   'iconPath': 'assets/images/6.png',
    //   'requiresSetup': true,
    // },
    // {
    //   'type': 'item',
    //   'title': 'Catálogo Online',
    //   'route': '/catalog',
    //   'index': 7,
    //   'iconPath': 'assets/images/package.png',
    //   'requiresSetup': true,
    // },
    // {
    //   'type': 'item',
    //   'title': 'Totem',
    //   'route': '/totems',
    //   'index': 8,
    //   'iconPath': 'assets/images/package.png',
    //   'requiresSetup': true,
    // },

    {'type': 'spacer'},

    {'type': 'section', 'title': 'Configuração da Loja', 'requiresSetup': false, 'index': 10},
    {
      'type': 'item',
      'title': 'Informações Gerais',
      'route': '/settings',
      'index': 9,
      'iconPath': 'assets/images/33.png',
      'requiresSetup': false,
    },
    {
      'type': 'item',
      'title': 'Horários',
      'route': '/settings/hours',
      'index': 10,
      'iconPath': 'assets/images/calendar-edit.png',
      'requiresSetup': false,
    },
    {
      'type': 'item',
      'title': 'Métodos de Pagamento',
      'route': '/payment-methods',
      'index': 11,
      'iconPath': 'assets/images/coins.png',
      'requiresSetup': false,
    },
    {
      'type': 'item',
      'title': 'Formas de Entrega',
      'route': '/settings/shipping',
      'index': 12,
      'iconPath': 'assets/images/box.png',
      'requiresSetup': false,
    },
    {
      'type': 'item',
      'title': 'Cidades e Bairros',
      'route': '/settings/locations',
      'index': 13,
      'iconPath': 'assets/images/location-pin.png',
      'requiresSetup': false,
    },
    // Descomente se precisar
    // {
    //   'type': 'item',
    //   'title': 'Chatbot',
    //   'route': '/chatbot',
    //   'index': 14,
    //   'iconPath': 'assets/images/location-pin.png',
    //   'requiresSetup': false,
    // },

    {'type': 'spacer'},

    {'type': 'section', 'title': 'Estoque', 'requiresSetup': true, 'index': 17},
    {
      'type': 'item',
      'title': 'Estoque',
      'route': '/inventory',
      'index': 15,
      'iconPath': 'assets/images/database.png',
      'requiresSetup': true,
    },

    {'type': 'spacer'},

    {'type': 'section', 'title': 'Financeiro', 'requiresSetup': true, 'index': 18},
    {
      'type': 'item',
      'title': 'Contas a pagar',
      'route': '/payables',
      'index': 16,
      'iconPath': 'assets/images/dollar-circle.png',
      'requiresSetup': true,
    },

    {
      'type': 'item',
      'title': 'Relatórios',
      'route': '/reports',
      'index': 17,
      'iconPath': 'assets/images/chart-trend-up1.png',
      'requiresSetup': true,
    },

    {'type': 'spacer'},

    {'type': 'section', 'title': 'Sistema', 'requiresSetup': true, 'index': 21},

    {
      'type': 'item',
      'title': 'Analise',
      'route': '/analytics',
      'index': 18,
      'iconPath': 'assets/images/user.png',
      'requiresSetup': false,
    },
    {
      'type': 'item',
      'title': 'Planos',
      'route': '/plans',
      'index': 19,
      'iconPath': 'assets/images/rocket-launch.png',
      'requiresSetup': true,
    },
  ];


  List<Widget> _buildMenuItemsFromData({
    required bool isSetupComplete,
    required bool isExpanded,
  }) {
    final List<Widget> menuWidgets = [];

    for (final itemData in _menuData) {
      // MUDANÇA 1: Lemos o tipo do item PRIMEIRO.
      final String type = itemData['type'] as String;

      // MUDANÇA 2: Se for um 'spacer', nós o adicionamos e pulamos para a próxima iteração do loop.
      // Isso evita que o código tente ler 'requiresSetup' para um spacer.
      if (type == 'spacer') {
        menuWidgets.add(const SizedBox(height: 20));
        continue;
      }

      // MUDANÇA 3: Agora que sabemos que não é um spacer, podemos ler 'requiresSetup' com segurança.
      final bool isRequired = itemData['requiresSetup'] as bool;

      // A LÓGICA PRINCIPAL: Pula o item se ele requer setup e o setup não está completo.
      if (isRequired && !isSetupComplete) {
        continue;
      }

      // A lógica do switch permanece a mesma, mas agora não precisa mais do case 'spacer'.
      switch (type) {
        case 'section':
          if (isExpanded) {
            menuWidgets.add(_buildSectionTitle(
              itemData['title'] as String,
              // A lógica de 'selected' precisa ser ajustada se você quiser que os títulos se destaquem
              selected: false,
            ));
          }
          break;
        case 'item':
          menuWidgets.add(_buildMenuItem(
            context: context,
            title: itemData['title'] as String,
            route: '/stores/${widget.storeId}${itemData['route']}',
            index: itemData['index'] as int,
            iconPath: itemData['iconPath'] as String,
            isExpanded: isExpanded,
          ));
          break;
      }
    }
    return menuWidgets;
  }

  Widget _buildSetupWarning(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: const Text(
        'Conclua a configuração para liberar todas as funções da sua loja.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required bool selected}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color:
              selected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required String route,
    required int index,
    required String iconPath,
    required bool isExpanded,
  }) {
    final isSelected = inboxController.pageselecter == index;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color defaultIconColor =
        Theme.of(context).listTileTheme.iconColor ??
        Theme.of(context).iconTheme.color!;
    final Color defaultTextColor =
        Theme.of(context).textTheme.bodyLarge!.color!;

    final Color iconColor = isSelected ? primaryColor : defaultIconColor;
    final Color textColor = isSelected ? primaryColor : defaultTextColor;
    final Color backgroundColor =
        isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent;
    final Border? border =
        isSelected
            ? Border.all(color: primaryColor.withOpacity(0.3), width: 1.0)
            : null;

    return InkWell(
      onTap: () {
        inboxController.setTextIsTrue(index);
        context.go(route);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: isExpanded ? 48 : 55,
        width: isExpanded ? double.infinity : 60,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isExpanded ? null : border,
        ),
        child:
            isExpanded
                ? Row(
                  children: [
                    const SizedBox(width: 8),
                    Image.asset(
                      iconPath,
                      height: 20,
                      width: 20,
                      color: iconColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color:
                              defaultTextColor, // Consider using textColor here for consistency
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
                : Stack(
                  children: [
                    if (isSelected)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 2.0,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              iconPath,
                              height: 20,
                              width: 20,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (!isSelected) // Only show text if not selected in collapsed view (as selected has the bar)
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    defaultTextColor, // Consider using textColor here for consistency
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}


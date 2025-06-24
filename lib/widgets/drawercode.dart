import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// Certifique-se de que este import está correto
import '../UI TEMP/controller/get_code.dart';
import '../core/menu_app_controller.dart'; // This is your DrawerControllerProvider

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

    final drawerController = context.watch<DrawerControllerProvider>();
    final bool isExpanded = drawerController.isExpanded;



    return GetBuilder<InboxController>(
      builder: (inboxController) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200), // Duração da animação
          width: isExpanded ? _expandedWidth : _collapsedWidth, // Use isExpanded from provider
          child: Drawer(
            child: Column(
              children: [

                Padding(
                  padding: isExpanded
                      ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0)
                      : const EdgeInsets.symmetric(vertical: 20.0),
                  child: InkWell(
                    onTap: () {
                      // Toggle the state of the drawer using the provider
                      drawerController.toggle();
                    },
                    child: Row(
                      mainAxisAlignment: isExpanded
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/Symbol.png',
                          height: 30, // Tamanho do ícone
                          width: 30,
                        ),
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

                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20), // Espaço inicial

                          // === DASHBOARD ===
                          if (isExpanded) // Títulos de seção apenas no modo expandido
                            _buildSectionTitle(
                              'Dashboard',
                              selected: inboxController.pageselecter >= 0 && inboxController.pageselecter <= 3,
                            ),
                          _buildMenuItem(
                            context: context,
                            title: 'Meus Pedidos',
                            route: '/stores/${widget.storeId}/orders',
                            index: 0,
                            iconPath: 'assets/images/package.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Pedidos Balcão (PDV)',
                            route: '/stores/${widget.storeId}/pdv-orders',
                            index: 1,
                            iconPath: 'assets/images/package.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Mesas',
                            route: '/stores/${widget.storeId}/tables',
                            index: 2,
                            iconPath: 'assets/images/package.png',
                            isExpanded: isExpanded,
                          ),

                          const SizedBox(height: 20),
                          // === LOJA ===
                          if (isExpanded)
                            _buildSectionTitle(
                              'Loja',
                              selected: inboxController.pageselecter >= 4 && inboxController.pageselecter <= 8,
                            ),
                          _buildMenuItem(
                            context: context,
                            title: 'Clientes',
                            route: '/stores/${widget.storeId}/customers',
                            index: 4,
                            iconPath: 'assets/images/user.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Produtos',
                            route: '/stores/${widget.storeId}/products',
                            index: 5,
                            iconPath: 'assets/images/package.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Adicionais',
                            route: '/stores/${widget.storeId}/variants',
                            index: 6,
                            iconPath: 'assets/images/4.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Cupons',
                            route: '/stores/${widget.storeId}/coupons',
                            index: 7,
                            iconPath: 'assets/images/6.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Banners',
                            route: '/stores/${widget.storeId}/banners',
                            index: 8,
                            iconPath: 'assets/images/6.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Catálogo Online',
                            route: '/stores/${widget.storeId}/catalog',
                            index: 9,
                            iconPath: 'assets/images/package.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Totem',
                            route: '/stores/${widget.storeId}/totems',
                            index: 10,
                            iconPath: 'assets/images/package.png',
                            isExpanded: isExpanded,
                          ),

                          const SizedBox(height: 20),
                          // === CONFIGURAÇÃO DA LOJA ===
                          if (isExpanded)
                            _buildSectionTitle(
                              'Configuração da Loja',
                              selected: inboxController.pageselecter >= 10 && inboxController.pageselecter <= 14,
                            ),
                          _buildMenuItem(
                            context: context,
                            title: 'Informações Gerais',
                            route: '/stores/${widget.storeId}/settings',
                            index: 11,
                            iconPath: 'assets/images/33.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Horários de Atendimento',
                            route: '/stores/${widget.storeId}/settings/hours',
                            index: 12,
                            iconPath: 'assets/images/calendar-edit.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Métodos de Pagamento',
                            route: '/stores/${widget.storeId}/payment-methods',
                            index: 13,
                            iconPath: 'assets/images/coins.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Formas de Entrega',
                            route: '/stores/${widget.storeId}/settings/shipping',
                            index: 14,
                            iconPath: 'assets/images/box.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Cidades e Bairros',
                            route: '/stores/${widget.storeId}/settings/locations',
                            index: 15,
                            iconPath: 'assets/images/location-pin.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Chatbot',
                            route: '/stores/${widget.storeId}/chatbot',
                            index: 16,
                            iconPath: 'assets/images/location-pin.png',
                            isExpanded: isExpanded,
                          ),

                          const SizedBox(height: 20),
                          // === ESTOQUE ===
                          if (isExpanded)
                            _buildSectionTitle(
                              'Estoque',
                              selected: inboxController.pageselecter == 15,
                            ),
                          _buildMenuItem(
                            context: context,
                            title: 'Estoque',
                            route: '/stores/${widget.storeId}/inventory',
                            index: 17,
                            iconPath: 'assets/images/database.png',
                            isExpanded: isExpanded,
                          ),

                          const SizedBox(height: 20),
                          // === FINANCEIRO ===
                          if (isExpanded)
                            _buildSectionTitle(
                              'Financeiro',
                              selected: inboxController.pageselecter >= 16 && inboxController.pageselecter <= 18,
                            ),
                          _buildMenuItem(
                            context: context,
                            title: 'Contas a pagar',
                            route: '/stores/${widget.storeId}/payables',
                            index: 18,
                            iconPath: 'assets/images/dollar-circle.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Caixa',
                            route: '/stores/${widget.storeId}/cash',
                            index: 19,
                            iconPath: 'assets/images/hard-drive.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Relatórios',
                            route: '/stores/${widget.storeId}/reports',
                            index: 20,
                            iconPath: 'assets/images/chart-trend-up1.png',
                            isExpanded: isExpanded,
                          ),

                          const SizedBox(height: 20),
                          // === SISTEMA ===
                          if (isExpanded)
                            _buildSectionTitle(
                              'Sistema',
                              selected: inboxController.pageselecter >= 19,
                            ),
                          _buildMenuItem(
                            context: context,
                            title: 'Equipe',
                            route: '/stores/${widget.storeId}/accesses',
                            index: 21,
                            iconPath: 'assets/images/user.png',
                            isExpanded: isExpanded,
                          ),
                          _buildMenuItem(
                            context: context,
                            title: 'Planos',
                            route: '/stores/${widget.storeId}/plans',
                            index: 22,
                            iconPath: 'assets/images/rocket-launch.png',
                            isExpanded: isExpanded,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                // ThemeSwitcher always visible
                //   ThemeSwitcher(), // Uncomment if you want to include this
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- AUXILIARY METHODS ---

  Widget _buildSectionTitle(String title, {required bool selected}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: selected
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
    final Color defaultIconColor = Theme.of(context).listTileTheme.iconColor ?? Theme.of(context).iconTheme.color!;
    final Color defaultTextColor = Theme.of(context).textTheme.bodyLarge!.color!;

    final Color iconColor = isSelected ? primaryColor : defaultIconColor;
    final Color textColor = isSelected ? primaryColor : defaultTextColor;
    final Color backgroundColor = isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent;
    final Border? border = isSelected
        ? Border.all(
      color: primaryColor.withOpacity(0.3),
      width: 1.0,
    )
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
        child: isExpanded
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
                  color: defaultTextColor, // Consider using textColor here for consistency
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
                mainAxisAlignment: MainAxisAlignment.center,
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
                        color: defaultTextColor, // Consider using textColor here for consistency
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

// Your DrawerControllerProvider (menu_app_controller.dart)
// This file remains the same.
/*
import 'package:flutter/material.dart';

class DrawerControllerProvider with ChangeNotifier {
  bool _isExpanded = true;

  bool get isExpanded => _isExpanded;

  void toggle() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void expand() {
    _isExpanded = true;
    notifyListeners();
  }

  void collapse() {
    _isExpanded = false;
    notifyListeners();
  }

  void set(bool value) {
    _isExpanded = value;
    notifyListeners();
  }
}
*/
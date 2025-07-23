import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StoreNavigationHelper {
  final int storeId;

  StoreNavigationHelper(this.storeId);

  static final List<MapEntry<RegExp, String>> _routePatterns = [
    MapEntry(RegExp(r'^/stores/.*/home$'), 'Dashboard'),
    MapEntry(RegExp(r'^/stores/.*/management'), 'Gestão'),
    MapEntry(RegExp(r'^/stores/.*/sell'), 'Vendas'),
    MapEntry(RegExp(r'^/stores/.*/suppliers'), 'Fornecedores'),
    MapEntry(RegExp(r'^/stores/.*/orders'), 'Pedidos'),
    MapEntry(RegExp(r'^/stores/.*/products/new$'), 'Criar produto'),
    MapEntry(RegExp(r'^/stores/.*/products/[^/]+$'), 'Editar produto'),
    MapEntry(RegExp(r'^/stores/.*/products$'), 'Produtos'),
    MapEntry(RegExp(r'^/stores/.*/categories'), 'Categorias'),
  ];

  /// Nome da página atual
  String getCurrentTitle(String location) {
    for (final entry in _routePatterns) {
      if (entry.key.hasMatch(location)) {
        return entry.value;
      }
    }
    return 'Página';
  }

  /// Índice atual da BottomNavigationBar
  int getCurrentIndex(String location) {
    if (location.startsWith('/stores/$storeId/orders')) return 0;
    if (location.startsWith('/stores/$storeId/sell')) return 1;
    if (location.startsWith('/stores/$storeId/products')) return 2;
    if (location.startsWith('/stores/$storeId/users')) return 3;
 //   if (location.startsWith('/stores/$storeId/orders')) return 4;
    return 4;
  }

  /// Deve mostrar BottomNavigationBar?
  bool shouldShowBottomBar(String location) {
    final hidePatterns = [
      RegExp(r'/coupons'),
      RegExp(r'/categories'),
      RegExp(r'/suppliers'),
      RegExp(r'/settings'),
      RegExp(r'/variants'),
      RegExp(r'/integrations'),
      RegExp(r'/new$'),
      RegExp(r'/edit'),
      RegExp(r'/payment-methods'),
      RegExp(r'/cash'),
      RegExp(r'/orders/'),


    ];

    return !hidePatterns.any((pattern) => pattern.hasMatch(location));
  }

  bool shouldShowAppBarCode(String location) {
    final hideAppBarPatterns = [
      RegExp(r'/more'),
      RegExp(r'/categories'),
      RegExp(r'/suppliers'),
      RegExp(r'/settings'),
      RegExp(r'/new$'),
      RegExp(r'/edit'),
    ];

    return !hideAppBarPatterns.any((pattern) => pattern.hasMatch(location));
  }



  /// Construtor da BottomNavigationBar
  Widget buildBottomNavigationBar(BuildContext context, String location, GlobalKey<ScaffoldState> scaffoldKey) {

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: getCurrentIndex(location),
      selectedItemColor: Theme.of(context).primaryColor,

      showUnselectedLabels: true,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/stores/$storeId/orders');
            break;
          case 1:
            context.go('/stores/$storeId/sell');
            break;
          case 2:
            context.go('/stores/$storeId/products');
            break;
          case 3:
            context.go('/stores/$storeId/users');
            break;
          case 4:
            context.go('/stores/$storeId/more');
            break;
        }
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.package), // 📦 Pedidos
          label: 'Pedidos',
        ),
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.shoppingBag), // 💵 Vender
          label: 'Vender',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.shoppingCart), // 🛒 Produtos
          label: 'Produtos',
        ),
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.users), // 👥 Clientes
          label: 'Clientes',
        ),
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.menu), // ☰ Mais
          label: 'Mais',
        ),

      ],
    );
  }
}

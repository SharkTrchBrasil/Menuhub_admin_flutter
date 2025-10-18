import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Usei os ícones do Material para consistência, mas você pode usar Lucide se preferir.
// import 'package:lucide_icons_flutter/lucide_icons.dart';

class StoreNavigationHelper {
  final int storeId;

  StoreNavigationHelper(this.storeId);

  // Mapeamento centralizado de rotas para seus títulos e índices.
  // Facilita a manutenção!
  static final Map<String, ({int index, String title})> _routeConfig = {
    '/dashboard': (index: 0, title: 'Início'),
    '/orders': (index: 1, title: 'Pedidos'),
    '/products': (index: 2, title: 'Cardápio'),
    '/more': (index: 3, title: 'Mais Opções'),
    // Adicione outras rotas principais aqui se necessário
  };

  /// Retorna o título da página com base na rota atual.
  String getTitleForPath(String path) {
    // Procura por uma correspondência exata primeiro.
    for (var route in _routeConfig.keys) {
      if (path.endsWith(route)) {
        return _routeConfig[route]!.title;
      }
    }

    // Fallback para títulos de páginas de detalhes.
    if (path.contains('/products/')) return 'Detalhes do Produto';
    if (path.contains('/orders/')) return 'Detalhes do Pedido';
    if (path.contains('/settings')) return 'Ajustes da Loja';
    if (path.contains('/coupons')) return 'Promoções';

    return 'PDVix'; // Título padrão.
  }

  /// Pega o índice do item ativo na BottomNavigationBar.
  int getCurrentIndex(String location) {
    for (var route in _routeConfig.keys) {
      // Usamos `startsWith` para que sub-rotas (ex: /orders/123) ainda selecionem o item pai.
      if (location.startsWith('/stores/$storeId$route')) {
        return _routeConfig[route]!.index;
      }
    }
    // Se nenhuma rota principal corresponder, significa que estamos em uma sub-página
    // de uma das seções. Vamos tentar encontrar a seção pai.
    if (location.contains('/orders')) return 1;
    if (location.contains('/products')) return 2;

    // Se não encontrar, não seleciona nenhum item.
    return 0; // Padrão para 'Início'
  }

  /// Decide se a BottomNavigationBar deve ser exibida.
  /// A lógica é: mostrar nas rotas principais e esconder nas de detalhes/configuração.
  bool shouldShowBottomBar(String location) {
    // Rotas onde a barra DEVE aparecer.
    final showPatterns = [
      '/stores/$storeId/dashboard',
      '/stores/$storeId/orders',
      '/stores/$storeId/products',
      '/stores/$storeId/more',
    ];

    // A barra aparece se a localização corresponder exatamente a uma das rotas acima.
    return showPatterns.any((pattern) => location == pattern);
  }

  /// Constrói a BottomNavigationBar com a nova estrutura focada.
  Widget buildBottomNavigationBar(BuildContext context, String location) {
    return BottomNavigationBar(
      currentIndex: getCurrentIndex(location),
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey.shade600, // Cor para itens não selecionados
      type: BottomNavigationBarType.fixed, // Garante que todos os itens apareçam
      showUnselectedLabels: true,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/stores/$storeId/dashboard');
            break;
          case 1:
            context.go('/stores/$storeId/coupons');
            break;
          case 2:
            context.go('/stores/$storeId/products');
            break;
          case 3:
          // A aba "Mais" simplesmente abre o Drawer que você já tem!
          // Para isso, seu AppShell precisa de uma GlobalKey<ScaffoldState>.
          // Ex: scaffoldKey.currentState?.openEndDrawer(); ou openDrawer();
            context.go('/stores/$storeId/more'); // Navega para a página "More"
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer_outlined),
          label: 'Promoções',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_rounded),
          label: 'Cardápio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_rounded),
          label: 'Mais',
        ),
      ],
    );
  }
}
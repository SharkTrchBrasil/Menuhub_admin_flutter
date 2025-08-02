import 'package:flutter/material.dart';

import '../../../models/store.dart';
import '../orders_page.dart';
import '../../../services/print/printer_settings.dart';
import '../store_settings.dart';



class DesktopToolbar extends StatelessWidget {
  final Store? activeStore;

  const DesktopToolbar({super.key, required this.activeStore});

  // Função para exibir o painel com animação
  void _showSidePanel(BuildContext context, Widget panel) {
    Navigator.of(context).push(
      PageRouteBuilder(
        // A página que será construída (nosso painel)
        pageBuilder: (context, animation, secondaryAnimation) => panel,
        // Define que a rota não é opaca, para vermos a tela anterior atrás
        opaque: false,
        // Cor do "scrim" ou cortina que escurece o fundo
        barrierColor: Colors.transparent,
        // Permite fechar o painel clicando fora dele
        barrierDismissible: true,
        // Duração da animação
        transitionDuration: const Duration(milliseconds: 300),
        // Construtor da animação
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Usamos um Tween para definir o início e o fim da animação
          // begin: Offset(1.0, 0.0) -> Começa 100% fora da tela, à direita
          // end: Offset.zero -> Termina na posição 0,0 (visível)
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          // Usamos uma curva para suavizar a animação
          final curve = CurveTween(curve: Curves.easeOut);
          final tween = Tween(begin: begin, end: end).chain(curve);
          final offsetAnimation = animation.drive(tween);

          // Retornamos o painel dentro de um SlideTransition
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Desabilita os botões se nenhuma loja estiver ativa
    final bool isStoreActive = activeStore != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,

      ),
      child: Row(
        children: [

          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Configurações de Impressão',
            // Desabilita se não houver loja ativa
            onPressed: isStoreActive
                ? () {
              // Chama a função para mostrar o painel da impressora
              _showSidePanel(
                context,
                // Criaremos este widget de placeholder abaixo
                PrinterSettingsSidePanel(storeId: activeStore!.id!),
              );
            }
                : null,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações da Loja',
            // Desabilita se não houver loja ativa
            onPressed: isStoreActive
                ? () {
              // Chama a função para mostrar o painel de configurações
              _showSidePanel(
                context,
                // Usa o seu painel já pronto
                StoreSettingsSidePanel(storeId: activeStore!.id!),
              );
            }
                : null,
          ),
        ],
      ),
    );
  }
}

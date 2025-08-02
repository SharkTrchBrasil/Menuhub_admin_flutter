import 'package:flutter/material.dart';

/// Exibe um painel de forma responsiva.
/// - Em telas largas (desktop), mostra um painel lateral deslizando da direita.
/// - Em telas estreitas (mobile), mostra um modal de tela cheia deslizando de baixo.
void showResponsiveSidePanel(BuildContext context, Widget panel) {
  // Pega a largura da tela para decidir qual layout usar
  final screenWidth = MediaQuery.of(context).size.width;
  const double mobileBreakpoint = 700.0; // Ponto de quebra entre os layouts
  final bool isMobile = screenWidth < mobileBreakpoint;

  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 350),

      pageBuilder: (context, animation, secondaryAnimation) {
        if (isMobile) {
          // No mobile, envolve o painel com o wrapper de tela cheia
          return _FullScreenMobileWrapper(child: panel);
        } else {
          // No desktop, usa o container de painel lateral
          return _SidePanelContainer(child: panel);
        }
      },

      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Define a animação com base no tipo de dispositivo
        final begin = isMobile ? const Offset(0.0, 1.0) : const Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ),
  );
}


/// Helper para o layout de PAINEL LATERAL (Desktop)
class _SidePanelContainer extends StatelessWidget {
  final Widget child;
  final double width;

  const _SidePanelContainer({
    required this.child,
    this.width = 450, // Largura padrão do painel
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        elevation: 16.0,
        child: SizedBox(
          width: width,
          height: double.infinity,
          child: child,
        ),
      ),
    );
  }
}

/// Helper para o layout de TELA CHEIA (Mobile)
class _FullScreenMobileWrapper extends StatelessWidget {
  final Widget child;

  const _FullScreenMobileWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco padrão para o painel
      body: Stack(
        children: [
          // O seu painel ocupa todo o espaço
          Positioned.fill(
            child: child,
          ),

          // Botão 'X' para fechar no canto superior direito
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black54, size: 28),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Fechar',
            ),
          ),
        ],
      ),
    );
  }
}
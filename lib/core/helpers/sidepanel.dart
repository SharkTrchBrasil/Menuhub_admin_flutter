import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Exibe um painel de forma responsiva e retorna um valor quando fechado.
/// - Em telas largas (desktop), mostra um painel lateral deslizando da direita.
/// - Em telas estreitas (mobile), mostra um modal de tela cheia deslizando de baixo.
Future<T?> showResponsiveSidePanel<T>(BuildContext context, Widget panel) {
  final screenWidth = MediaQuery.of(context).size.width;
  const double mobileBreakpoint = 700.0;
  final bool isMobile = screenWidth < mobileBreakpoint;

  return Navigator.of(context).push<T>(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 350),

      pageBuilder: (context, animation, secondaryAnimation) {
        if (isMobile) {
          return _FullScreenMobileWrapper(child: panel);
        } else {
          return _SidePanelContainer(child: panel);
        }
      },

      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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

  const _SidePanelContainer({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calcula a largura como 50% da tela, com limites mínimos e máximos
    double calculatedWidth = screenWidth * 0.5;
    const double minWidth = 400.0;
    const double maxWidth = 800.0;
    double width = calculatedWidth.clamp(minWidth, maxWidth);

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        elevation: 16.0,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        child: SizedBox(
          width: width,
          height: double.infinity,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false, // Remove a seta de voltar
              title: const Text(
                'Editar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Fechar',
                ),
              ],
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            body: child, // Conteúdo passado como parâmetro
          ),
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
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false, // Remove a seta de voltar
          title: const Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, size: 24, color: Colors.red,),
              onPressed: () => context.pop(),
              tooltip: 'Fechar',
            ),
          ],
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: child, // Conteúdo passado como parâmetro
      ),
    );
  }
}
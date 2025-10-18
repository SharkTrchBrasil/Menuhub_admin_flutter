import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Exibe um painel de forma responsiva e retorna um valor quando fechado.
/// - Em telas largas (desktop), mostra um painel lateral deslizando da direita.
/// - Em telas estreitas (mobile), mostra um modal de tela cheia deslizando de baixo.
Future<T?> showResponsiveSidePanel<T>(
    BuildContext context,
    Widget panel, {
      bool useHalfScreenOnDesktop = true, // ✅ ALTERADO PARA true
    }) {
  final screenWidth = MediaQuery.of(context).size.width;
  const double mobileBreakpoint = 700.0;
  final bool isMobile = screenWidth < mobileBreakpoint;

  if (isMobile) {
    // ✅ NO MOBILE: USA Navigator.push (BottomSheet deslizando)
    return Navigator.of(context, rootNavigator: true).push<T>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.5),
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 350),

        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenMobileWrapper(child: panel);
        },

        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeOutCubic));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  } else {
    // ✅ NO DESKTOP: USA showGeneralDialog (painel lateral)
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      transitionDuration: const Duration(milliseconds: 350),

      pageBuilder: (context, anim1, anim2) {
        return _SidePanelContainer(
          child: panel,
          useHalfScreen: useHalfScreenOnDesktop,
        );
      },

      transitionBuilder: (context, anim1, anim2, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: tween.animate(anim1),
          child: Align(
            alignment: Alignment.centerRight,
            child: child,
          ),
        );
      },
    );
  }
}

class _SidePanelContainer extends StatelessWidget {
  final Widget child;
  final bool useHalfScreen;

  const _SidePanelContainer({
    required this.child,
    this.useHalfScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ CALCULA A LARGURA CORRETA
    double width;
    if (useHalfScreen) {
      width = screenWidth * 0.5;
    } else {
      double calculatedWidth = screenWidth * 0.4;
      const double minWidth = 400.0;
      const double maxWidth = 600.0;
      width = calculatedWidth.clamp(minWidth, maxWidth);
    }

    return SizedBox(
      width: width,
      height: double.infinity,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: IconButton(
                icon: const Icon(Icons.close, size: 24, color: Colors.red),
                onPressed: () => context.pop(),
                tooltip: 'Fechar',
              ),
            ),
          ],
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: child,
        ),
      ),
    );
  }
}

class _FullScreenMobileWrapper extends StatelessWidget {
  final Widget child;

  const _FullScreenMobileWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          '',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: IconButton(
              icon: const Icon(Icons.close, size: 24, color: Colors.red),
              onPressed: () => context.pop(),
              tooltip: 'Fechar',
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: child,
      ),
    );
  }
}

/// Versão alternativa que permite passar um título personalizado
Future<T?> showResponsiveSidePanelWithTitle<T>(
    BuildContext context,
    Widget panel, {
      String title = '',
      bool useHalfScreenOnDesktop = false,
    }) {
  final screenWidth = MediaQuery.of(context).size.width;
  const double mobileBreakpoint = 700.0;
  final bool isMobile = screenWidth < mobileBreakpoint;

  if (isMobile) {
    // ✅ NO MOBILE: USA Navigator.push
    return Navigator.of(context, rootNavigator: true).push<T>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.5),
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 350),

        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenMobileWrapperWithTitle(
            child: panel,
            title: title,
          );
        },

        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeOutCubic));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  } else {
    // ✅ NO DESKTOP: USA showGeneralDialog
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      transitionDuration: const Duration(milliseconds: 350),

      pageBuilder: (context, anim1, anim2) {
        return _SidePanelContainerWithTitle(
          child: panel,
          title: title,
          useHalfScreen: useHalfScreenOnDesktop,
        );
      },

      transitionBuilder: (context, anim1, anim2, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: tween.animate(anim1),
          child: Align(
            alignment: Alignment.centerRight,
            child: child,
          ),
        );
      },
    );
  }
}

class _SidePanelContainerWithTitle extends StatelessWidget {
  final Widget child;
  final String title;
  final bool useHalfScreen;

  const _SidePanelContainerWithTitle({
    required this.child,
    required this.title,
    this.useHalfScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ CALCULA A LARGURA CORRETA
    double width;
    if (useHalfScreen) {
      width = screenWidth * 0.5;
    } else {
      double calculatedWidth = screenWidth * 0.4;
      const double minWidth = 400.0;
      const double maxWidth = 600.0;
      width = calculatedWidth.clamp(minWidth, maxWidth);
    }

    return SizedBox(
      width: width,
      height: double.infinity,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: IconButton(
                icon: const Icon(Icons.close, size: 24, color: Colors.red),
                onPressed: () => context.pop(),
                tooltip: 'Fechar',
              ),
            ),
          ],
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: SafeArea(
          child: child,
        ),
      ),
    );
  }
}

class _FullScreenMobileWrapperWithTitle extends StatelessWidget {
  final Widget child;
  final String title;

  const _FullScreenMobileWrapperWithTitle({
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: IconButton(
              icon: const Icon(Icons.close, size: 24, color: Colors.red),
              onPressed: () => context.pop(),
              tooltip: 'Fechar',
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: child,
      ),
    );
  }
}
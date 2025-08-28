import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';

/// Exibe um painel de forma responsiva.
///
/// No Desktop, abre como um painel lateral que desliza da direita.
/// No Mobile, abre como um BottomSheet que ocupa a tela inteira.
Future<T?> showResponsiveSidePanelGroup<T>(
    BuildContext context, {
      required Widget panel,
    }) {
  if (ResponsiveBuilder.isDesktop(context)) {
    // --- LÓGICA PARA DESKTOP ---
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => panel,
      transitionBuilder: (context, anim1, anim2, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero);
        return SlideTransition(
          position: tween.animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: Align(
            alignment: Alignment.centerRight, // Alinha à direita
            child: Material(
              elevation: 8,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2, // Ocupa metade da tela
                height: double.infinity, // Ocupa toda a altura
                child: child,
              ),
            ),
          ),
        );
      },
    );
  } else {
    // --- LÓGICA PARA MOBILE ---
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true, // Permite ocupar a tela inteira
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95, // Começa com 95% da tela
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (_, controller) => ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          child: panel,
        ),
      ),
    );
  }
}
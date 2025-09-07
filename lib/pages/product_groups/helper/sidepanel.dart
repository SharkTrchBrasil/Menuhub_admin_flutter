import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di.dart';
import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';
import '../../../repositories/product_repository.dart';
import '../cubit/create_complement_cubit.dart';

void showResponsiveSidePanelComplement(BuildContext context, {
  required Widget panel,
  required int productId,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  const double mobileBreakpoint = 700.0;
  final bool isMobile = screenWidth < mobileBreakpoint;

  // Pega o estado da loja e o repositório a partir do contexto
  final storesState = context.read<StoresManagerCubit>().state;

  final createComplementCubit = context.read<CreateComplementGroupCubit>();


  if (storesState is! StoresManagerLoaded || storesState.activeStore == null) {
    print("Erro: A loja não está carregada ou não foi encontrada.");
    return;
  }


  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 350),

      pageBuilder: (context, animation, secondaryAnimation) {

        final panelWithExistingCubit = BlocProvider.value(
          value: createComplementCubit,
          child: panel, // O 'panel' aqui é o seu MultiStepPanelContainer
        );

        if (isMobile) {
          return _FullScreenMobileWrapper(child: panelWithExistingCubit);
        } else {
          return _SidePanelContainer(child: panelWithExistingCubit);
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




class _SidePanelContainer extends StatelessWidget {
  final Widget child;


  const _SidePanelContainer({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {


    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        elevation: 16.0,
        child: SizedBox(
          width: screenWidth * 0.5, // Ocupa metade da tela
          height: double.infinity,
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
      backgroundColor: Colors.white, // Fundo branco padrão para o painel
      body: Stack(
        children: [


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
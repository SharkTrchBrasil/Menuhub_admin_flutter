import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/helpers/navigation.dart'; // ✅ Importe seu helper
import 'package:totem_pro_admin/cubits/scaffold_ui_cubit.dart';
import 'package:totem_pro_admin/widgets/appbarcode.dart'; // Seu AppBar customizado
import 'package:totem_pro_admin/widgets/drawercode.dart';

import '../core/responsive_builder.dart';
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final int storeId;

  const AppShell({
    super.key,
    required this.navigationShell,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    // Provê o cubit de UI para que as páginas filhas possam usá-lo.
    return BlocProvider(
      create: (context) => ScaffoldUiCubit(),
      child: ResponsiveBuilder(
        mobileBuilder: (context, constraints) => _buildMobileLayout(context),
        desktopBuilder: (context, constraints) => _buildDesktopLayout(context),
        // O tabletBuilder pode usar o mesmo layout do mobile,
        // o ResponsiveBuilder já faz isso por padrão se for nulo.
      ),
    );
  }

  // Layout para telas grandes (Desktop/Web)
  Widget _buildDesktopLayout(BuildContext context) {
    final navHelper = StoreNavigationHelper(storeId);


    return Scaffold(
      body: Row(
        children: [
          DrawerCode(storeId: storeId), // Menu lateral fixo
          Expanded(
            child: Column(
              children: [

                AppBarCode(),

                // O conteúdo da página (shell) ocupa o resto do espaço
                Expanded(child: navigationShell),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Layout para telas pequenas (Mobile/Tablet)
  Widget _buildMobileLayout(BuildContext context) {
    final navHelper = StoreNavigationHelper(storeId);
    final currentPath = GoRouterState.of(context).uri.toString();

    return BlocBuilder<ScaffoldUiCubit, ScaffoldUiState>(
      builder: (context, uiState) {
        return Scaffold(
          // Se a página filha definiu uma AppBar, usa ela.
          // Senão, usa uma AppBar padrão com o título do helper.
          appBar: uiState.appBar ?? AppBar(title: Text('')),

          drawer:  DrawerCode(storeId: storeId), // Adicionando o drawer para mobile também

          body: navigationShell, // Conteúdo da página

          floatingActionButton: uiState.fab, // FAB definido pela página filha

          bottomNavigationBar: navHelper.shouldShowBottomBar(currentPath)
              ? navHelper.buildBottomNavigationBar(context, currentPath, GlobalKey<ScaffoldState>())
              : null,
        );
      },
    );
  }
}
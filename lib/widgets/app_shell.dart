import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/helpers/navigation.dart';

import 'package:totem_pro_admin/widgets/appbarcode.dart';
import 'package:totem_pro_admin/widgets/drawercode.dart';

import '../core/enums/connectivity_status.dart';
import '../core/responsive_builder.dart';
import '../cubits/store_manager_cubit.dart';
import '../cubits/store_manager_state.dart';
import 'connectivity_banner.dart';

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
    return ResponsiveBuilder(
      mobileBuilder: (context, constraints) => _buildMobileLayout(context),
      desktopBuilder: (context, constraints) => _buildDesktopLayout(context),
    );
  }

  // Layout para telas grandes (Desktop/Web)
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Column( // ✅ Envolve tudo em uma Column para posicionar o banner
        children: [
          Expanded(
            child: Row( // ✅ Usa uma Row para o layout principal
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
          ),
          // O banner agora fica fora do layout principal,
          // aparecendo no rodapé sem empurrar o conteúdo.
          _buildConnectivityBanner(),
        ],
      ),
    );
  }

  // Layout para telas pequenas (Mobile/Tablet)
  Widget _buildMobileLayout(BuildContext context) {
    final navHelper = StoreNavigationHelper(storeId);
    final currentPath = GoRouterState.of(context).uri.toString();

    return Scaffold(
      // ✅ CORREÇÃO: A AppBar padrão agora é visível e funcional
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // Uma leve sombra para separar do conteúdo
        title: Text(
          navHelper.getTitleForPath(currentPath), // Título dinâmico
          style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // Adiciona o botão para abrir o menu (drawer)
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: DrawerCode(storeId: storeId),
      body: Column(
        children: [
          Expanded(child: navigationShell),
          _buildConnectivityBanner(),
        ],
      ),

      bottomNavigationBar: navHelper.shouldShowBottomBar(currentPath)
          ? navHelper.buildBottomNavigationBar(context, currentPath, GlobalKey<ScaffoldState>())
          : null,
    );
  }
  // ✅ Widget do banner foi extraído para ser reutilizado
  Widget _buildConnectivityBanner() {
    return BlocSelector<StoresManagerCubit, StoresManagerState, ConnectivityStatus>(
      selector: (state) {
        return state is StoresManagerLoaded
            ? state.connectivityStatus
            : ConnectivityStatus.connected;
      },
      builder: (context, status) {
        if (status == ConnectivityStatus.reconnecting) {
          return const ConnectivityBanner();
        }
        return const SizedBox.shrink(); // Não mostra nada se estiver conectado
      },
    );
  }
}
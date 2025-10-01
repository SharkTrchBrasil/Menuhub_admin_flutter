import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:totem_pro_admin/core/helpers/navigation.dart';

import 'package:totem_pro_admin/widgets/appbarcode.dart';
import 'package:totem_pro_admin/widgets/drawercode.dart';
import 'package:totem_pro_admin/widgets/persistent_notification_toast..dart';
import 'package:totem_pro_admin/widgets/subscription_blocked_view.dart';



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
    // ✅ 2. ENVOLVA TUDO EM UM BLOCBUILDER PARA VERIFICAR A ASSINATURA
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      // Otimização: só reconstrói se o objeto de assinatura mudar
      buildWhen: (previous, current) {
        final prevSub = (previous is StoresManagerLoaded) ? previous.activeStore?.relations.subscription : null;
        final currSub = (current is StoresManagerLoaded) ? current.activeStore?.relations.subscription : null;
        return prevSub != currSub;
      },
      builder: (context, state) {
        if (state is StoresManagerLoaded) {
          final subscription = state.activeStore?.relations.subscription;

          // ✅ 3. A LÓGICA PRINCIPAL: VERIFICA SE ESTÁ BLOQUEADO
          if (subscription != null && subscription.isBlocked) {
            return SubscriptionBlockedView(
              subscription: subscription,
              storeId: storeId,
            );
          }
        }

        // Se não estiver bloqueado ou se o estado ainda não estiver carregado, mostra o layout normal.
        return ResponsiveBuilder(
          mobileBuilder: (context, constraints) => _buildMobileLayout(context),
          desktopBuilder: (context, constraints) => _buildDesktopLayout(context),
        );
      },
    );
  }

  // Layout para telas grandes (Desktop/Web)
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      // ✅ 2. O CORPO AGORA É UMA STACK PARA PERMITIR A SOBREPOSIÇÃO
      body: Stack(
        children: [
          // O conteúdo principal (que você já tinha)
          Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    DrawerCode(storeId: storeId),
                    Expanded(
                      child: Column(
                        children: [
                          AppBarCode(),
                          Expanded(child: navigationShell),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildConnectivityBanner(),
            ],
          ),

          // ✅ 3. BANNER ADICIONADO AQUI, POSICIONADO SOBRE O CONTEÚDO
          const Positioned(
            bottom: 20,
            right: 20,
            child: PersistentNotificationToast(),
          ),
        ],
      ),
    );
  }

  // Layout para telas pequenas (Mobile/Tablet)
  Widget _buildMobileLayout(BuildContext context) {
    final navHelper = StoreNavigationHelper(storeId);
    final currentPath = GoRouterState.of(context).uri.toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          navHelper.getTitleForPath(currentPath),
          style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: DrawerCode(storeId: storeId),
      // ✅ 4. O CORPO DO MOBILE TAMBÉM VIRA UMA STACK
      body: Stack(
        children: [
          // O conteúdo principal (que você já tinha)
          Column(
            children: [
              Expanded(child: navigationShell),
              _buildConnectivityBanner(),
            ],
          ),

          // ✅ 5. BANNER ADICIONADO AQUI TAMBÉM
          const Positioned(
            bottom: 20,
            right: 20,
            child: PersistentNotificationToast(),
          ),
        ],
      ),

      bottomNavigationBar: navHelper.shouldShowBottomBar(currentPath)
          ? navHelper.buildBottomNavigationBar(context, currentPath, GlobalKey<ScaffoldState>())
          : null,
    );
  }

  Widget _buildConnectivityBanner() {
    return BlocSelector<StoresManagerCubit, StoresManagerState, ConnectivityStatus>(
      selector: (state) {
        return state is StoresManagerLoaded
            ? state.connectivityStatus
            : ConnectivityStatus.connected;
      },
      builder: (context, status) {

        if (status == ConnectivityStatus.connected) {
          return const SizedBox.shrink(); // Não mostra nada se estiver conectado
        }
        return const ConnectivityBanner(); // Mostra para 'disconnected' ou 'reconnecting'
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
import 'dot_loading.dart'; // Supondo que você tenha um widget de loading customizado

class AppScaffoldKey extends ChangeNotifier {
  final GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
}

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final int storeId;
  final AppScaffoldKey _scaffoldKey = AppScaffoldKey();

  AppShell({
    super.key,
    required this.navigationShell,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _scaffoldKey,
      // ✅ O BlocBuilder agora ouve todas as mudanças de estado para um fluxo correto.
      child: BlocBuilder<StoresManagerCubit, StoresManagerState>(
        // REMOVIDO: O `buildWhen` foi removido para garantir que a UI
        // reaja a todas as transições de estado (Loading -> Sync -> Loaded).
        builder: (context, state) {
          // ===================================================================
          // ETAPA 1: Tratar os estados de carregamento e sincronização.
          // ===================================================================
          if (state is StoresManagerLoading || state is StoresManagerSynchronizing) {
            return const Scaffold(
              body: Center(
                child: DotLoading(), // Ou CircularProgressIndicator()
              ),
            );
          }

          // ===================================================================
          // ETAPA 2: Tratar os estados de falha (erro ou sem lojas).
          // ===================================================================
          if (state is StoresManagerError) {
            return Scaffold(
              body: Center(child: Text("Erro ao carregar dados: ${state.message}")),
            );
          }

          if (state is StoresManagerEmpty) {
            // TODO: Criar uma tela mais elaborada para quando o usuário não tem lojas.
            return const Scaffold(
              body: Center(child: Text("Nenhuma loja encontrada para sua conta.")),
            );
          }

          // ===================================================================
          // ETAPA 3: Tratar o estado de sucesso (StoresManagerLoaded).
          // A partir daqui, temos certeza que os dados estão completos.
          // ===================================================================
          if (state is StoresManagerLoaded) {
            final subscription = state.activeStore?.relations.subscription;

            // A verificação de assinatura bloqueada agora é segura e não piscará.
            if (subscription != null && subscription.isBlocked) {
              return SubscriptionBlockedView(
                subscription: subscription,
                storeId: storeId,
              );
            }

            // Se tudo estiver OK, renderiza o layout principal da aplicação.
            return ResponsiveBuilder(
              mobileBuilder: (context, constraints) => _buildMobileLayout(context),
              desktopBuilder: (context, constraints) => _buildDesktopLayout(context),
            );
          }

          // Fallback de segurança, não deve ser alcançado.
          return const Scaffold(
            body: Center(
              child: Text("Ocorreu um estado inesperado. Por favor, reinicie."),
            ),
          );
        },
      ),
    );
  }

  // O restante dos seus métodos de build (_buildDesktopLayout, _buildMobileLayout, etc.)
  // permanecem exatamente os mesmos, pois a lógica deles já está correta.

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          const Positioned(
            bottom: 20,
            right: 20,
            child: PersistentNotificationToast(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final navHelper = StoreNavigationHelper(storeId);
    final currentPath = GoRouterState.of(context).uri.toString();
    final isOrdersRoute = currentPath.contains('/orders');

    return Scaffold(
      key: _scaffoldKey.key,
      appBar: isOrdersRoute ? null : AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          navHelper.getTitleForPath(currentPath),
          style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: DrawerCode(storeId: storeId),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: navigationShell),
              _buildConnectivityBanner(),
            ],
          ),
          const Positioned(
            bottom: 20,
            right: 20,
            child: PersistentNotificationToast(),
          ),
        ],
      ),
      bottomNavigationBar: isOrdersRoute ? null : (navHelper.shouldShowBottomBar(currentPath)
          ? navHelper.buildBottomNavigationBar(context, currentPath)
          : null),
    );
  }

  Widget _buildConnectivityBanner() {
    return BlocSelector<StoresManagerCubit, StoresManagerState, ConnectivityStatus>(
      selector: (state) {
        // Agora o banner de conectividade também funciona durante a sincronização.
        if (state is StoresManagerLoaded) {
          return state.connectivityStatus;
        }
        // Retorna 'conectado' por padrão se o estado ainda não estiver carregado.
        return ConnectivityStatus.connected;
      },
      builder: (context, status) {
        if (status == ConnectivityStatus.connected) {
          return const SizedBox.shrink();
        }
        return const ConnectivityBanner();
      },
    );
  }
}
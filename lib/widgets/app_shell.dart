// Em: widgets/app_shell.dart

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
import '../core/helpers/sidepanel.dart';
import '../core/responsive_builder.dart';
import '../cubits/store_manager_cubit.dart';
import '../cubits/store_manager_state.dart';

import '../pages/plans/plans_page.dart';
import '../pages/plans/subscription_side_panel.dart';
import 'connectivity_banner.dart';
import 'dot_loading.dart';

class AppScaffoldKey extends ChangeNotifier {
  final GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
}

class AppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final int storeId;

  const AppShell({
    super.key,
    required this.navigationShell,
    required this.storeId,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final AppScaffoldKey _scaffoldKey = AppScaffoldKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStoreSetup();
      _ensureStoreIsActive();
    });
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storeId != widget.storeId) {
      _ensureStoreIsActive();
    }
  }

  void _ensureStoreIsActive() {
    if (!mounted) return;

    final cubit = context.read<StoresManagerCubit>();
    final state = cubit.state;

    if (state is StoresManagerLoaded) {
      if (state.activeStoreId != widget.storeId) {
        print('🔄 URL mudou para storeId ${widget.storeId}, trocando loja ativa...');
        cubit.changeActiveStore(widget.storeId);
      }
    }
  }

  void _checkStoreSetup() {
    if (!mounted) return;

    final state = context.read<StoresManagerCubit>().state;
    if (state is StoresManagerLoaded) {
      final activeStore = state.activeStore;
      if (activeStore != null && !activeStore.core.isSetupComplete) {
        context.go('/stores/${activeStore.core.id}/wizard');
      }
    }
  }

// app_shell.dart

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _scaffoldKey,
      child: BlocBuilder<StoresManagerCubit, StoresManagerState>(
        builder: (context, state) {
          if (state is StoresManagerLoading || state is StoresManagerInitial) {
            return const Scaffold(body: Center(child: DotLoading()));
          }

          if (state is StoresManagerError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text("Erro ao carregar dados: ${state.message}"),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<StoresManagerCubit>().loadInitialData();
                      },
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is StoresManagerSynchronizing || state is StoresManagerLoaded) {
            final storeId = widget.storeId;
            final storeWithRole = state is StoresManagerSynchronizing
                ? state.stores[storeId]
                : (state as StoresManagerLoaded).stores[storeId];

            if (storeWithRole == null) {
              return const Scaffold(body: Center(child: DotLoading()));
            }

            final subscription = storeWithRole.store.relations.subscription;


            // ✅ MUDANÇA CRÍTICA: Abre painel ao invés de navegar
            if (subscription == null || subscription.isBlocked) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _openSubscriptionPanelIfNeeded(context, storeId, subscription);
              });
            }

            if (state is StoresManagerSynchronizing && storeId == state.activeStoreId) {
              return const Scaffold(body: Center(child: DotLoading()));
            }

            // CASO 3: Assinatura OK → Renderiza UI normal
            if (state is StoresManagerSynchronizing && storeId == state.activeStoreId) {
              return const Scaffold(body: Center(child: DotLoading()));
            }

            return ResponsiveBuilder(
              mobileBuilder: (context, constraints) => _buildMobileLayout(context, storeId),
              desktopBuilder: (context, constraints) => _buildDesktopLayout(context, storeId),
            );
          }

          return const Scaffold(body: Center(child: DotLoading()));
        },
      ),
    );
  }




  Widget _buildDesktopLayout(BuildContext context, int storeId) {
    return Scaffold(
      key: _scaffoldKey.key,
      body: Stack(
        children: [
          Row(
            children: [
              DrawerCode(storeId: storeId),
              Expanded(
                child: Column(
                  children: [
                    AppBarCode(),
                    _buildConnectivityBanner(),
                    Expanded(
                      child: widget.navigationShell,
                    ),
                  ],
                ),
              ),
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

  Widget _buildMobileLayout(BuildContext context, int storeId) {
    final navHelper = StoreNavigationHelper(storeId);
    final currentPath = GoRouterState.of(context).uri.toString();
    final isOrdersRoute = currentPath.contains('/orders');

    return Scaffold(
      key: _scaffoldKey.key,
      appBar: isOrdersRoute
          ? null
          : AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          navHelper.getTitleForPath(currentPath),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: DrawerCode(storeId: storeId),
      body: Stack(
        children: [
          Column(
            children: [
              _buildConnectivityBanner(),
              Expanded(
                child: widget.navigationShell,
              ),
            ],
          ),
          const Positioned(
            bottom: 20,
            right: 20,
            child: PersistentNotificationToast(),
          ),
        ],
      ),
      bottomNavigationBar: isOrdersRoute
          ? null
          : (navHelper.shouldShowBottomBar(currentPath)
          ? navHelper.buildBottomNavigationBar(context, currentPath)
          : null),
    );
  }

  Widget _buildConnectivityBanner() {
    return BlocSelector<StoresManagerCubit, StoresManagerState, ConnectivityStatus>(
      selector: (state) {
        if (state is StoresManagerLoaded) {
          return state.connectivityStatus;
        }
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


  // ✅ NOVA FUNÇÃO: Abre painel de assinatura
  Future<void> _openSubscriptionPanelIfNeeded(
      BuildContext context,
      int storeId,
      dynamic subscription,
      ) async {
    // ✅ Só abre se ainda não estiver aberto
    if (ModalRoute.of(context)?.isCurrent != true) return;

    await showResponsiveSidePanel(
      context,
      SubscriptionSidePanel(    storesManagerCubit: context.read<StoresManagerCubit>(),
          storeId: storeId),
   //   isDismissible: false, // ✅ Força resolver antes de continuar
    );


  }

}
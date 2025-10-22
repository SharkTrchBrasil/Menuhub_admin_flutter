import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/chatbot_conversation.dart';
import 'package:totem_pro_admin/models/order_details.dart';

import 'package:totem_pro_admin/pages/base/BasePage.dart';


import 'package:totem_pro_admin/widgets/dot_loading.dart';

import '../../services/chat_visibility_service.dart';

import '../chatpanel/widgets/chat_central_panel.dart';

import '../chatpanel/widgets/chat_pop/chat_heads_manager.dart';
import '../chatpanel/widgets/chat_pop/chat_popup_manager.dart';

import '../product_groups/helper/side_panel_helper.dart';

import 'cubit/order_page_cubit.dart';
import 'cubit/order_page_state.dart';

import 'layout/desktop/orders_page_desktop.dart';
import 'layout/mobile/mobile_order_layout.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {

  final TextEditingController _searchController = TextEditingController();


  int _currentTabIndex = 0;

  final List<ChatbotConversation> _activeConversations = [];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncActiveStoreWithRoute();
    });
  }

  void _syncActiveStoreWithRoute() {
    final storeIdString = GoRouterState.of(context).pathParameters['storeId'];
    final storeId = int.tryParse(storeIdString ?? '');
    if (storeId == null) return;

    final storeCubit = context.read<StoresManagerCubit>();
    final currentState = storeCubit.state;
    if (currentState is StoresManagerLoaded && currentState.activeStoreId != storeId) {
      storeCubit.changeActiveStore(storeId);
    }
  }



  void _onOrderSelected(OrderDetails order) {
    setState(() {
    });
  }

  void _onChatHeadTapped(ChatbotConversation conversation) {
    ChatPopupManager.of(context)?.openChat(
      storeId: conversation.storeId,
      chatId: conversation.chatId,
      customerName: conversation.customerName ?? 'Cliente',
    );
  }

  List<OrderDetails> _getDisplayOrders(List<OrderDetails> allOrders) {
    final tabFiltered = _currentTabIndex == 0
        ? allOrders.where((o) => o.scheduledFor == null).toList()
        : allOrders.where((o) => o.scheduledFor != null).toList();

    final searchText = _searchController.text.toLowerCase();
    if (searchText.isEmpty) return tabFiltered;

    return tabFiltered.where((order) =>
    order.customerName.toLowerCase().contains(searchText) ||
        order.publicId.toLowerCase().contains(searchText)
    ).toList();
  }

  @override
  void dispose() {

    _searchController.dispose();
    GetIt.I<ChatVisibilityService>().setPanelVisibility(false);
    super.dispose();
  }

  void showChatCentralPanel(BuildContext context) {
    GetIt.I<ChatVisibilityService>().setPanelVisibility(true);

    showResponsiveSidePanelGroup(
      context,
      panel: const ChatCentralPanel(),
    ).whenComplete(() {
      GetIt.I<ChatVisibilityService>().setPanelVisibility(false);
    });
  }




  @override
  Widget build(BuildContext context) {

    print('🚀 OrdersPage construída - Rota: ${GoRouterState.of(context).uri.path}');
    print('🏪 StoreId da rota: ${GoRouterState.of(context).pathParameters['storeId']}');

    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, storeState) {
        if (storeState is! StoresManagerLoaded) {
          return const Scaffold(body: Center(child: DotLoading()));
        }

        final activeStore = storeState.stores[storeState.activeStoreId]?.store;
        final warningMessage = storeState.subscriptionWarning;

        return BlocBuilder<OrderCubit, OrderState>(
          builder: (context, orderState) {
            List<OrderDetails> displayOrders = [];
            bool isLoading = orderState is! OrdersLoaded;

            if (orderState is OrdersLoaded) {
              displayOrders = _getDisplayOrders(orderState.orders);
            }


            return ChatHeadsManager(
              activeConversations: _activeConversations,
              onChatHeadTapped: _onChatHeadTapped,
              child: BasePage(
                mobileBuilder: (context) => MobileOrderLayout(
                  onOpenOrderDetailsPage: (ctx, order) {
                    context.go(
                      '/stores/${activeStore?.core.id}/orders/${order.id}',
                      extra: {'order': order, 'store': activeStore},
                    );
                  },
                  store: activeStore,
                  orderState: orderState,
                ),
                desktopBuilder: (context) => Scaffold(
                  body: OrdersDesktopLayout(
                    activeStore: activeStore,
                    warningMessage: warningMessage,
                    orders: orderState is OrdersLoaded ? orderState.orders : [],
                    isLoading: orderState is! OrdersLoaded,
                    onOrderSelected: _onOrderSelected,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
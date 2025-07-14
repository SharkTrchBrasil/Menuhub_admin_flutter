// lib/pages/orders/orders_page.dart

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/pages/base/BasePage.dart';
import 'package:totem_pro_admin/pages/orders/order_page_cubit.dart';
import 'package:totem_pro_admin/pages/orders/order_page_state.dart';
import 'package:totem_pro_admin/pages/orders/service/print.dart';
import 'package:totem_pro_admin/pages/orders/widgets/count_badge.dart';
import 'package:totem_pro_admin/pages/orders/widgets/mobile_order_layout.dart';

import 'package:totem_pro_admin/pages/orders/widgets/order_card_mobile.dart';
import 'package:totem_pro_admin/pages/orders/widgets/order_details_desktop.dart';
import 'package:totem_pro_admin/pages/orders/widgets/order_details_mobile.dart';

import 'package:totem_pro_admin/pages/orders/utils/order_helpers.dart';

import 'package:totem_pro_admin/pages/orders/widgets/order_list_item.dart';


import '../../ConstData/typography.dart';
import '../../constdata/colorfile.dart';
import '../../constdata/colorprovider.dart';
import '../../cubits/store_manager_cubit.dart';
import '../../cubits/store_manager_state.dart';

import '../../models/rating_summary.dart';
import '../../models/store_hour.dart';
import '../../models/store_settings.dart';
import '../../widgets/dot_loading.dart';

class OrdersPage extends StatefulWidget {
  // Remova o construtor 'storeId' daqui, ele será gerenciado pelo StoreManagerCubit
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {

  ColorNotifire notifire = ColorNotifire();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final storeIdString = GoRouterState
        .of(context)
        .pathParameters['storeId'];
    final storeId = int.tryParse(storeIdString ?? '');
    final storeCubit = context.read<StoresManagerCubit>();

    if (storeId != null && storeCubit.state is StoresManagerLoaded) {
      final loaded = storeCubit.state as StoresManagerLoaded;
      if (loaded.activeStoreId != storeId) {
        storeCubit.setActiveStore(storeId);
      }
    }
  }

  late TabController _tabController;
  int _currentTabIndex = 0; // Para as abas 'Agora' / 'Agendados' do desktop
  final TextEditingController _searchController = TextEditingController();
  String? _lastNotifiedOrderIdForSound;
  OrderDetails? _selectedOrderDetails; // Usado apenas na versão desktop


  @override
  void initState() {
    super.initState();
    // Desktop tem 2 abas (Agora/Agendados)
    // Mobile tem N abas (Pendentes, Preparando, etc.)
    // Vamos inicializar para o desktop e ajustar no mobile build
    _tabController = TabController(
        length: 2, vsync: this); // Para "Agora" e "Agendados" no desktop
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
          // Limpa a seleção de pedido ao trocar de aba (principalmente para desktop)
          _selectedOrderDetails = null;
        });
      }
    });

    // O carregamento inicial dos pedidos será feito no BlocListener do StoresManagerCubit
    // para garantir que uma loja ativa esteja selecionada.
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Apenas força a reconstrução para aplicar o filtro de busca
    setState(() {});
  }


  // Método para abrir a tela de detalhes do pedido (MOBILE)
  void _openOrderDetailsPage(BuildContext context, OrderDetails order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            OrderDetailsPage(order: order, onPrintOrder: printOrder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return BlocListener<StoresManagerCubit, StoresManagerState>(
      listener: (context, storeState) {
        if (storeState is StoresManagerLoaded &&
            storeState.activeStoreId != null) {
          // Quando a loja ativa muda, recarregue os pedidos para a nova loja
          //    context.read<OrderCubit>().loadInitialOrders(storeState.activeStoreId!);
          // Limpa o pedido selecionado se a loja mudar
          setState(() {
            _selectedOrderDetails = null;
          });
        }
      },
      child: BlocBuilder<StoresManagerCubit, StoresManagerState>(
        builder: (context, storeState) {
          // Se não houver lojas carregadas ou nenhuma ativa, mostre o loading
          if (storeState is! StoresManagerLoaded ||
              storeState.activeStoreId == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const DotLoading(color: Colors.red, size: 12),
                  const SizedBox(height: 16),
                  Text(
                    'Carregando loja...',
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium,
                  ),
                ],
              ),
            );
          }

          // Se chegarmos aqui, temos uma loja ativa e podemos construir a UI
          final activeStore = storeState.stores[storeState.activeStoreId!]
              ?.store;
          final String currentStoreName = activeStore?.name ??
              'Loja Desconhecida';


          return BasePage(

            mobileBuilder: (BuildContext context) {
              return MobileOrderLayout(
                storeName: currentStoreName,
                mobileTabController: _tabController,
                // Mesmo TabController
                searchController: _searchController,
                currentTabIndex: _currentTabIndex,
                onTabChanged: (index) {
                  setState(() {
                    _currentTabIndex = index;
                  });
                },
                onPrintOrder: printOrder,
                onOpenOrderDetailsPage: _openOrderDetailsPage,
              );
            },


            desktopBuilder: (BuildContext context) {
              return _buildDesktopLayout(context, currentStoreName);
            },
          );
        },
      ),
    );
  }


  // --- Layout para Desktop ---
  Widget _buildDesktopLayout(BuildContext context, String currentStoreName) {
    return Row(
      children: [

        Expanded(
          flex: 2,
          child: _buildOrderPanel(context),
        ),
        // Painel Direito: Detalhes do Pedido ou Resumo do Dia
        Expanded(
          flex: 4,
          child: _buildSummaryPanel(context),
        ),
      ],
    );
  }




  Widget _buildOrderPanel(BuildContext context) {
    // Acesso ao storeCubitState fora do BlocBuilder aninhado, para que storeId e settings
    // fiquem disponíveis para o ListTile.
    final storeCubitState = context
        .watch<StoresManagerCubit>()
        .state;
    int? activeStoreId;
    StoreSettings? storeSettings;

    if (storeCubitState is StoresManagerLoaded &&
        storeCubitState.activeStoreId != null) {
      activeStoreId = storeCubitState.activeStoreId!;
      storeSettings =
          storeCubitState.stores[activeStoreId]?.store.storeSettings;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // sombra leve
            offset: const Offset(0, 4), // deslocamento para baixo
            blurRadius: 12, // espalhamento
            spreadRadius: 1, // intensidade
          ),
        ],
      ),

      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                BlocBuilder<OrderCubit, OrderState>(
                  builder: (context, orderState) {
                    int nowPendingCount = 0;
                    int scheduledPendingCount = 0;

                    if (orderState is OrdersLoaded) {
                      final nowOrders = orderState.orders.where((o) =>
                      o.scheduledFor == null).toList();
                      final scheduledOrders = orderState.orders.where((o) =>
                      o.scheduledFor != null).toList();

                      nowPendingCount = nowOrders
                          .where((o) => o.orderStatus == 'pending')
                          .length;
                      scheduledPendingCount = scheduledOrders
                          .where((o) => o.orderStatus == 'pending')
                          .length;
                    }

                    return TabBar(
                      controller: _tabController,
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(width: 3.0, color: Colors.red),
                        insets: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      labelColor: Colors.red,
                      unselectedLabelColor: Colors.black,
                      overlayColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.red.withOpacity(0.1);
                          }
                          return null;
                        },
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Agora'),
                              if (nowPendingCount > 0)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: CountBadge(count: nowPendingCount),
                                ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Agendados'),
                              if (scheduledPendingCount > 0)
                                Padding(
                                  // AQUI ESTAVA UM ERRO: USANDO nowPendingCount AO INVÉS DE scheduledPendingCount
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: CountBadge(
                                      count: scheduledPendingCount), // CORRIGIDO AQUI
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Adicionado um null check para storeSettings e activeStoreId
                if (activeStoreId != null && storeSettings != null)
                  ListTile(
                    title: const Text('Aceitar pedidos automaticamente'),
                    trailing: Switch(
                      value: storeSettings.autoAcceptOrders,
                      onChanged: (newValue) =>
                          context
                              .read<StoresManagerCubit>()
                              .updateStoreSettings(activeStoreId!,
                              autoAcceptOrders: newValue), // Usando newValue diretamente
                    ),
                  ),

                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar pedido...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    // setState aqui pode não ser o ideal se você estiver usando Bloc para o filtro
                    // Considere mover a lógica de filtro para o OrderCubit
                    setState(() {
                      // Trigger rebuild to apply search filter
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<OrderCubit, OrderState>(
              builder: (context, state) {
                if (state is OrdersLoading || state is OrdersInitial) {
                  return const Center(
                      child: DotLoading(color: Colors.red, size: 12));
                }
                if (state is OrdersError) {
                  return Center(child: Text(
                      'Erro ao carregar pedidos: ${state.message}'));
                }
                if (state is OrdersLoaded) {
                  final orders = _currentTabIndex == 0
                      ? state.orders
                      .where((o) => o.scheduledFor == null)
                      .toList() // Pedidos "Agora"
                      : state.orders
                      .where((o) => o.scheduledFor != null)
                      .toList(); // Pedidos "Agendados"

                  // Aplica filtro de busca se houver texto
                  final filteredOrders = _searchController.text.isEmpty
                      ? orders
                      : orders.where((order) =>
                  order.customerName.toLowerCase().contains(
                      _searchController.text.toLowerCase()) ||
                      order.id.toString().contains(_searchController
                          .text) // Exemplo: buscar por ID do pedido
                  ).toList();


                  if (filteredOrders.isEmpty) { // Usar filteredOrders aqui
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: Colors
                              .grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum pedido encontrado ${ _searchController.text
                                .isNotEmpty
                                ? "para a busca"
                                : (_currentTabIndex == 0
                                ? "para agora"
                                : "agendado")}.',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildOrderListByStatus(
                      filteredOrders); // Passar filteredOrders
                }
                return const Center(
                    child: Text('Estado de pedidos desconhecido.'));
              },
            ),
          ),
        ],
      ),
    );
  }


// Dentro da classe _OrdersPageState
  Widget _buildSummaryPanel(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;

    return Container(

      padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedOrderDetails == null)
            BlocBuilder<OrderCubit, OrderState>(
              builder: (context, orderState) {
                final storeCubitState = context
                    .watch<StoresManagerCubit>()
                    .state;
                String storeName = "Loja";
                bool isStoreOpen = false;
                List<StoreHour> storeHours = [];

                if (storeCubitState is StoresManagerLoaded &&
                    storeCubitState.activeStoreId != null) {
                  final activeStoreData = storeCubitState.stores[storeCubitState
                      .activeStoreId!]?.store;
                  storeName = activeStoreData?.name ?? "Loja";
                  storeHours = activeStoreData?.hours ?? [];
                  isStoreOpen =
                      activeStoreData?.storeSettings?.isStoreOpen ?? false;
                }

                if (orderState is OrdersLoading ||
                    orderState is OrdersInitial) {
                  return const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DotLoading(color: Colors.red, size: 12),
                          SizedBox(height: 16),
                          Text('Carregando resumo...', style: TextStyle(
                              color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }
                if (orderState is OrdersError) {
                  return Expanded(
                    child: Center(child: Text(
                        'Erro ao carregar resumo: ${orderState.message}',
                        textAlign: TextAlign.center)),
                  );
                }
                if (orderState is OrdersLoaded) {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final tomorrow = today.add(const Duration(days: 1));

                  final firstDayOfCurrentMonth = DateTime(
                      now.year, now.month, 1);
                  final dayOfCurrentMonth = DateTime(
                      now.year, now.month, now.day);
                  final firstDayOfLastMonth = DateTime(
                      now.year, now.month - 1, 1);
                  final dayOfLastMonthSamePeriod = DateTime(
                      firstDayOfLastMonth.year, firstDayOfLastMonth.month,
                      now.day);

                  final currentMonthCompletedOrders = orderState.orders.where((
                      o) =>
                  o.orderStatus == 'delivered' &&
                      o.createdAt.isAfter(
                          firstDayOfCurrentMonth.subtract(const Duration(
                              days: 1))) &&
                      o.createdAt.isBefore(
                          dayOfCurrentMonth.add(const Duration(days: 1)))
                  ).toList();

                  final lastMonthSamePeriodCompletedOrders = orderState.orders
                      .where((o) =>
                  o.orderStatus == 'delivered' &&
                      o.createdAt.isAfter(
                          firstDayOfLastMonth.subtract(const Duration(
                              days: 1))) &&
                      o.createdAt.isBefore(
                          dayOfLastMonthSamePeriod.add(const Duration(days: 1)))
                  ).toList();

                  const int inactiveProductsCount = 15; // MOCK

                  final completedOrdersCurrentMonthCount = currentMonthCompletedOrders
                      .length;
                  final completedOrdersLastMonthSamePeriodCount = lastMonthSamePeriodCompletedOrders
                      .length;

                  final dateFormatter = DateFormat('dd/MM');

                  // Filtra os horários por dia da semana (0-Dom, 1-Seg... 6-Sáb)
                  // Converte DateTime.weekday (1-Seg, 7-Dom) para o formato do seu StoreHour
                  int getStoreHourWeekday(DateTime date) {
                    return date.weekday == DateTime.sunday ? 0 : date.weekday;
                  }

                  final todayHours = storeHours
                      .where((h) =>
                  h.dayOfWeek == getStoreHourWeekday(now) && h.isActive)
                      .toList();
                  final tomorrowHours = storeHours
                      .where((h) =>
                  h.dayOfWeek == getStoreHourWeekday(tomorrow) && h.isActive)
                      .toList();

                  String formatTimeOfDay(TimeOfDay? time) {
                    if (time == null) return 'N/A';
                    final hour = time.hour.toString().padLeft(2, '0');
                    final minute = time.minute.toString().padLeft(2, '0');
                    return '$hour:$minute';
                  }

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome da Loja e Toggle Fechar Loja
                        _buildSimpleMetricCard(
                          title: storeName,
                          value: '',
                          // Não usamos o valor principal aqui
                          padding: const EdgeInsets.all(24),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          // Estica para a largura total
                          customContent: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isStoreOpen
                                          ? "Loja Aberta"
                                          : "Loja Fechada",
                                      style: Typographyy.bodyMediumMedium
                                          .copyWith(
                                        color: isStoreOpen
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Switch(
                                      value: isStoreOpen,
                                      onChanged: (newValue) {
                                        if (storeCubitState is StoresManagerLoaded &&
                                            storeCubitState.activeStoreId !=
                                                null) {
                                          context
                                              .read<StoresManagerCubit>()
                                              .updateStoreSettings(
                                            storeCubitState.activeStoreId!,
                                            isStoreOpen: newValue,
                                          );
                                        }
                                      },
                                      activeColor: Colors.green,
                                      inactiveThumbColor: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Cards de Horário de Funcionamento e Produtos Inativos
                        Row(
                          children: [
                            Expanded(
                              child: _buildSimpleMetricCard(
                                title: "Horário de Funcionamento",
                                value: '', // Não usamos o valor aqui
                                padding: const EdgeInsets.all(24),
                                customContent: [
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Text(
                                        "Hoje: ${dateFormatter.format(today)}",
                                        style: Typographyy.bodyMediumMedium
                                            .copyWith(
                                            color: notifire.getTextColor),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "Amanhã: ${dateFormatter.format(
                                            tomorrow)}",
                                        style: Typographyy.bodyMediumMedium
                                            .copyWith(
                                            color: notifire.getTextColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: todayHours.isEmpty
                                              ? [
                                            Text('Fechado', style: Typographyy
                                                .bodySmallSemiBold.copyWith(
                                                color: Colors.red))
                                          ]
                                              : todayHours.map((hour) =>
                                              Text(
                                                '${formatTimeOfDay(hour
                                                    .openingTime)} - ${formatTimeOfDay(
                                                    hour.closingTime)}',
                                                style: Typographyy
                                                    .bodySmallSemiBold.copyWith(
                                                    color: notifire
                                                        .getGry600_500Color),
                                              )).toList(),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: tomorrowHours.isEmpty
                                              ? [
                                            Text('Fechado', style: Typographyy
                                                .bodySmallSemiBold.copyWith(
                                                color: Colors.red))
                                          ]
                                              : tomorrowHours.map((hour) =>
                                              Text(
                                                '${formatTimeOfDay(hour
                                                    .openingTime)} - ${formatTimeOfDay(
                                                    hour.closingTime)}',
                                                style: Typographyy
                                                    .bodySmallSemiBold.copyWith(
                                                    color: notifire
                                                        .getGry600_500Color),
                                              )).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildSimpleMetricCard(
                                title: "Produtos Inativos",
                                value: inactiveProductsCount.toString(),
                                subtitle: "Verifique o cardápio",
                                icon: Icons.hide_source,
                                valueColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Card Full Width para Pedidos Concluídos
                        Expanded(
                          child: _buildSimpleMetricCard(
                            title: "Métricas de Pedidos",
                            value: '',
                            // Não usamos o valor principal aqui
                            padding: const EdgeInsets.all(24),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            customContent: [
                              const SizedBox(height: 16),
                              _buildSimpleMetricCard(
                                title: "Concluídos Mês Atual",
                                value: completedOrdersCurrentMonthCount
                                    .toString(),
                                subtitle: "Até ${dateFormatter.format(now)}",
                                icon: Icons.check_circle_outline,
                                valueColor: Colors.green,
                                padding: const EdgeInsets.all(
                                    16), // Padding interno para o sub-card
                              ),
                              const SizedBox(height: 15),
                              _buildSimpleMetricCard(
                                title: "Mês Anterior (Mesmo Período)",
                                value: completedOrdersLastMonthSamePeriodCount
                                    .toString(),
                                subtitle: "Até ${dateFormatter.format(
                                    dayOfLastMonthSamePeriod)}",
                                icon: Icons.history,
                                valueColor: Colors.grey,
                                padding: const EdgeInsets.all(
                                    16), // Padding interno para o sub-card
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const Expanded(child: Center(
                    child: Text('Estado de resumo desconhecido.')));
              },
            )
          else
            Expanded(
              child: OrderDetailsPanelDestop(
                selectedOrder: _selectedOrderDetails,
                onPrintOrder: printOrder,),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }




  Widget _buildSimpleMetricCard({
    required String title,
    required String value,
    String? subtitle,
    Color? valueColor,
    IconData? icon,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    bool isFullWidth = false, // Para controlar se ele usa Expanded ou não
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    // Para horários, podemos passar uma lista de widgets ou String formatada
    List<Widget>? customContent,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: notifire.getGry50_800Color,
        // Usando a cor de fundo do seu container principal
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, size: 20,
                  color: notifire.getTextColor.withOpacity(0.7)),
              if (icon != null) const SizedBox(width: 8),
              Text(title, style: Typographyy.bodyLargeExtraBold.copyWith(
                  color: notifire.getGry500_600Color)),
            ],
          ),
          const SizedBox(height: 8),
          if (customContent !=
              null) // Para conteúdo personalizado como horários
            ...customContent
          else
            Text(
              value,
              style: Typographyy.heading4.copyWith(letterSpacing: 1.5,
                  color: valueColor ?? notifire.getTextColor),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: Typographyy.bodyMediumMedium.copyWith(
                color: notifire.getGry600_500Color)),
          ],
        ],
      ),
    );
  }

  // Método para construir a lista de pedidos agrupados por status (desktop)
  Widget _buildOrderListByStatus(List<OrderDetails> orders) {
    final filteredOrders = _searchController.text.isEmpty
        ? orders
        : orders.where((order) =>
    order.publicId.toLowerCase().contains(
        _searchController.text.toLowerCase()) ||
        order.customerName.toLowerCase().contains(
            _searchController.text.toLowerCase())
    ).toList();

    filteredOrders.sort((a, b) {
      if (a.orderStatus == 'pending' && b.orderStatus != 'pending') return -1;
      if (a.orderStatus != 'pending' && b.orderStatus == 'pending') return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    final ordersByStatus = groupBy(
        filteredOrders, (order) => order.orderStatus);

    final List<String> desktopDisplayStatusesInternal = [
      'pending',
      'preparing',
      'ready',
      'on_route',
      'delivered',
      'canceled'
    ];

    return ListView(
      children: desktopDisplayStatusesInternal.map((internalStatus) {
        final statusDisplayName = internalStatusToDisplayName[internalStatus] ??
            'Status Desconhecido';
        final statusOrders = ordersByStatus[internalStatus] ?? [];

        if (statusOrders.isEmpty) return const SizedBox();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8.0),
          // Ajuste o padding horizontal aqui
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  initiallyExpanded: internalStatus == 'pending',
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      '$statusDisplayName (${statusOrders.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  children: statusOrders.map((order) {
                    // Obter o nome da loja para o OrderListItem
                    final storeManagerState = context
                        .watch<StoresManagerCubit>()
                        .state;
                    String currentStoreName = 'Loja Desconhecida';
                    if (storeManagerState is StoresManagerLoaded &&
                        storeManagerState.stores.containsKey(order.storeId)) {
                      currentStoreName =
                          storeManagerState.stores[order.storeId]!.store.name;
                    }

                    return OrderListItem(
                      order: order,
                      onPrintOrder: printOrder,
                      onTap: () {
                        setState(() {
                          _selectedOrderDetails = order;
                        });
                      },
                      // storeName: currentStoreName, // Passa o nome da loja
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }


  void _printAllPendingOrders(List<OrderDetails> orders) {
    final pendingOrders = orders.where((o) => o.orderStatus == 'pending');
    for (final order in pendingOrders) {
      printOrder(order);
    }
  }


}
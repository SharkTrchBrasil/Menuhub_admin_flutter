import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';

import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/pages/orders/order_page_cubit.dart';
import 'package:totem_pro_admin/pages/orders/order_page_state.dart';
import 'package:totem_pro_admin/pages/orders/widgets/desktop_order_view.dart';
import 'package:totem_pro_admin/pages/orders/widgets/mobileorderlist.dart';


import '../../core/responsive_builder.dart';

import '../../cubits/store_manager_cubit.dart';
import '../../cubits/store_manager_state.dart';
import '../../widgets/mobileappbar.dart';
import '../base/BasePage.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});


  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  int _currentTabIndex = 0;
  late TabController _tabController;
  final List<String> _statusTabs = [
    'Pendente',
    'Em produção',
    'Prontos para entrega',
  ];

  final Map<String, String> _statusInternalMap = {
    'Pendente': 'pendent',
    'Em produção': 'preparing',
    'Prontos para entrega': 'ready',
  };

  final Map<String, IconData> _deliveryTypeIcons = {
    'delivery': Icons.delivery_dining,
    'takeout': Icons.store,
    'table': Icons.table_restaurant,
  };

  // Colors for each status tab
  final List<Color> _statusColors = [
    const Color(0xFFF27535), // Pendente - orange
    const Color(0xFFF4AC36), // Em produção - yellow
    const Color(0xFF5FBF53), // Prontos para entrega - green
  ];

  // Format date to Brazilian format
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeState = context.watch<StoresManagerCubit>().state;

    if (storeState is! StoresManagerLoaded || storeState.activeStoreId == null) {
      print('Estado da loja não está carregado ainda');
      return const Center(child: CircularProgressIndicator());
    }

    final activeStoreId = storeState.activeStoreId!;
    final storeName = storeState.stores[activeStoreId]?.store.name ?? 'Sem nome';
    print('Loja ativa ID: $activeStoreId');
    print('Loja ativa nome: $storeName');



    return BlocBuilder<OrderCubit, OrderState>(

      builder: (BuildContext context, state) {







        if (state.status == OrderStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == OrderStatus.failure) {
          return Center(child: Text('Error: ${state.error}'));
        }

        return BasePage(
          mobileAppBar:
              ResponsiveBuilder.isMobile(context)
                  ? AppBarCustom(title: '')
                  : null,
          mobileBuilder: (BuildContext context) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey[600],
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: _statusColors[_currentTabIndex],
                        ),
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        tabs:
                            _statusTabs
                                .map(
                                  (tab) => Tab(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(tab),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return MobileOrderList(
                            orders: state.orders,
                            currentTabIndex: _currentTabIndex,
                            statusTabs: _statusTabs,
                            onOrderTap: _showOrderDetailsDialog,
                            buildOrderCard: _buildOrderCard,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
          desktopBuilder: (BuildContext context) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return DesktopOrderView(
                  orders: state.orders,
                  buildStatusHeader: _buildStatusHeader,
                  getOrdersByStatusIndex: _getOrdersByStatusIndex,
                  buildStatusColumn: _buildStatusColumn,
                  onRemovePressed: () {
                    // sua lógica para retirar
                  },
                  onAddPressed: () {
                    // sua lógica para adicionar
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatusHeader(int statusIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: _statusColors[statusIndex],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          _statusTabs[statusIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  List<OrderDetails> _getOrdersByStatusIndex(
    List<OrderDetails> orders,
    int statusIndex,
  ) {
    final label = _statusTabs[statusIndex];
    final internal = _statusInternalMap[label];
    return orders.where((order) => order.orderStatus == internal).toList();
  }

  Widget _buildStatusColumn(List<OrderDetails> orders, int? statusIndex) {
    String status =
        statusIndex != null
            ? _statusTabs[statusIndex]
            : _statusTabs[_currentTabIndex];
    Color statusColor =
        statusIndex != null
            ? _statusColors[statusIndex]
            : _statusColors[_currentTabIndex];

    return SingleChildScrollView(
      // Keep SingleChildScrollView here to allow scrolling within each column
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (statusIndex == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                status,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          const SizedBox(height: 8),
          orders.isEmpty
              ? Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Nenhum pedido $status',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
              : Column(
                children:
                    orders.map((order) {
                      return GestureDetector(
                        onTap: () => _showOrderDetailsDialog(context, order),
                        child: _buildOrderCard(
                          order,
                          statusIndex ?? _currentTabIndex,
                        ),
                      );
                    }).toList(),
              ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderDetails order, int currentStatusIndex) {
    final statusColor = _statusColors[currentStatusIndex];
    final IconData deliveryIcon =
        _deliveryTypeIcons[order.deliveryType] ?? Icons.help_outline;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Delivery Icon, Order ID, Date & Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Icon(deliveryIcon, size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Pedido #${order.id}',
                        style: const TextStyle(
                          fontSize: 18,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _formatDate(order.createdAt),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer Info & Total/Payment
            if (order.customerName != null || order.customerPhone != null)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          order.customerName ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        order.totalPrice.toPrice(), // Total
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          order.customerPhone ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          order.paymentMethodName ?? 'N/A', // Payment Method
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 12),

            // Address or Takeout Info
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.deliveryType == 'takeout'
                        ? 'Retirada na loja'
                        : (order.street ?? '') +
                            (order.number == null ? '' : ', ${order.number}') +
                            (order.neighborhood != null
                                ? ', ${order.neighborhood}'
                                : '') +
                            (order.city != null ? ', ${order.city}' : ''),
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Button
            if (currentStatusIndex < _statusTabs.length)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (currentStatusIndex < _statusTabs.length - 1) {
                      final label = _statusTabs[currentStatusIndex + 1];
                      final nextStatus = _statusInternalMap[label]!;
                      context.read<OrderCubit>().updateOrderStatus(
                        order.id,
                        nextStatus,
                      );
                    } else if (order.orderStatus == 'ready') {
                      context.read<OrderCubit>().updateOrderStatus(
                        order.id,
                        'finished',
                      );
                    }
                  },
                  child: Text(
                    _getButtonTextForStatus(
                      currentStatusIndex,
                      order.orderStatus,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getButtonTextForStatus(int currentStatusIndex, String orderStatus) {
    if (orderStatus == 'ready') {
      return 'Finalizar pedido';
    }
    switch (currentStatusIndex) {
      case 0:
        return 'Aceitar pedido';
      case 1:
        return 'Avançar pedido';
      case 2:
        return 'Pronto para entrega';
      default:
        return 'Atualizar Status';
    }
  }

  void _showOrderDetailsDialog(BuildContext context, OrderDetails order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final IconData deliveryIcon =
            _deliveryTypeIcons[order.deliveryType] ?? Icons.help_outline;
        final statusColor =
            _statusColors[_statusTabs.indexOf(
              _statusTabs.firstWhere(
                (element) => _statusInternalMap[element] == order.orderStatus,
              ),
            )];

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dialog Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(deliveryIcon, size: 28, color: Colors.grey[700]),
                          const SizedBox(width: 12),
                          Text(
                            'Pedido #${order.id}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              _statusTabs[_statusInternalMap.values
                                  .toList()
                                  .indexOf(order.orderStatus!)],
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () {
                              // TODO: Implement edit functionality
                              Navigator.of(context).pop();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.print, color: Colors.grey),
                            onPressed: () {
                              // TODO: Implement print functionality
                              Navigator.of(context).pop();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // TODO: Implement delete functionality
                              Navigator.of(context).pop();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Customer Info
                  _buildDetailRow(
                    Icons.person,
                    'Cliente:',
                    order.customerName ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.phone,
                    'Telefone:',
                    order.customerPhone ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.payment,
                    'Pagamento:',
                    order.paymentMethodName ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.delivery_dining,
                    'Entrega:',
                    _getDeliveryTypeName(order.deliveryType),
                  ),
                  _buildDetailRow(
                    Icons.source,
                    'Origem:',
                    order.deliveryType ?? 'N/A',
                  ),
                  const SizedBox(height: 16),

                  // Products
                  const Text(
                    'Itens do Pedido:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children:
                        order.products.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.quantity}x ${item.name}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Text(
                                      item.price.toPrice(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (item.variants.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      top: 4,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          item.variants.map((variant) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (variant.options.isNotEmpty)
                                                  Column(
                                                    children:
                                                        variant.options.map((
                                                          option,
                                                        ) {
                                                          return Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                '${option.quantity}x ${option.name}',
                                                                style: const TextStyle(
                                                                  fontSize: 14,
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        }).toList(),
                                                  ),
                                              ],
                                            );
                                          }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),

                  const Divider(height: 24),

                  // Totals
                  _buildTotalRow(
                    'Subtotal:',
                    order.discountedTotalPrice.toPrice(),
                  ),
                  _buildTotalRow(
                    'Taxa de Entrega:',
                    (order.deliveryFee ?? 0).toPrice(),
                  ),
                  _buildTotalRow(
                    'Total:',
                    ((order.discountedTotalPrice) + (order.deliveryFee ?? 0))
                        .toPrice(),
                    isTotal: true,
                  ),
                  const SizedBox(height: 16),

                  // Status update buttons in dialogiconbut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (order.orderStatus != 'pendent')
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              final currentStatusIndex = _statusInternalMap
                                  .values
                                  .toList()
                                  .indexOf(order.orderStatus!);
                              if (currentStatusIndex > 0) {
                                final prevLabel =
                                    _statusTabs[currentStatusIndex - 1];
                                final prevStatus =
                                    _statusInternalMap[prevLabel]!;
                                context.read<OrderCubit>().updateOrderStatus(
                                  order.id,
                                  prevStatus,
                                );
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text(
                              'Voltar Status',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      if (order.orderStatus != 'pendent' &&
                          order.orderStatus != 'finished')
                        const SizedBox(width: 12),
                      if (order.orderStatus != 'finished')
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: statusColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              final currentStatusIndex = _statusInternalMap
                                  .values
                                  .toList()
                                  .indexOf(order.orderStatus!);
                              if (currentStatusIndex < _statusTabs.length - 1) {
                                final nextLabel =
                                    _statusTabs[currentStatusIndex + 1];
                                final nextStatus =
                                    _statusInternalMap[nextLabel]!;
                                context.read<OrderCubit>().updateOrderStatus(
                                  order.id,
                                  nextStatus,
                                );
                              } else if (order.orderStatus == 'ready') {
                                context.read<OrderCubit>().updateOrderStatus(
                                  order.id,
                                  'finished',
                                );
                              }
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              _getButtonTextForStatus(
                                _statusInternalMap.values.toList().indexOf(
                                  order.orderStatus!,
                                ),
                                order.orderStatus!,
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    String formattedValue, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.black : Colors.grey,
            ),
          ),
          Text(
            formattedValue,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _getDeliveryTypeName(String? deliveryType) {
    switch (deliveryType) {
      case 'delivery':
        return 'Entrega';
      case 'takeout':
        return 'Retirada na Loja';
      case 'table':
        return 'Mesa';
      default:
        return 'Não Informado';
    }
  }
}

// lib/pages/orders/widgets/order_details_mobile.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/pages/orders/order_page_cubit.dart';
import 'package:totem_pro_admin/pages/orders/utils/order_helpers.dart';
import 'package:totem_pro_admin/pages/orders/widgets/store_header.dart';

import '../../../cubits/store_manager_cubit.dart';
import '../../../models/order_product.dart';
import '../../../models/store.dart';
import '../../../services/print/print.dart';
import '../../../widgets/order_printing_actions_widget.dart';
// Para statusColors, deliveryTypeIcons, formatOrderDate, statusInternalMap

class OrderDetailsPageMobile extends StatefulWidget {
  final OrderDetails order;

  // AJUSTADO: A página agora recebe o objeto Store completo.
  final Store store;

  const OrderDetailsPageMobile({
    super.key,
    required this.order,

    required this.store,
  });

  @override
  State<OrderDetailsPageMobile> createState() => _OrderDetailsPageMobileState();
}

class _OrderDetailsPageMobileState extends State<OrderDetailsPageMobile> {

  final ScrollController _scrollController = ScrollController();
  bool _collapsed = false;
  final printerService = GetIt.I<PrinterService>();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_scrollController.offset > 60 && !_collapsed) {
      setState(() => _collapsed = true);
    } else if (_scrollController.offset <= 60 && _collapsed) {
      setState(() => _collapsed = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }
















  @override
  Widget build(BuildContext context) {
    final Color statusColor = statusColors[widget.order.orderStatus] ?? Colors.grey;
    final String deliveryType = widget.order.deliveryType;
    // Pega o tipo de entrega
    final theme = Theme.of(context);

    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );


    return  Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
            expandedHeight: 80,
            collapsedHeight: kToolbarHeight,
            centerTitle: true,
            title: _collapsed
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.order.customerName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8,),
                Text(
                  'Pedido ${widget.order.sequentialId}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
                : const Text(
              'Detalhes do pedido',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              // ✅ WIDGET DE IMPRESSÃO ADICIONADO AQUI
              OrderPrintingActionsWidget(
                order: widget.order, // Passe o objeto do pedido
                store: widget.store, // Passe o objeto da loja
                printerService: printerService, // Passe a instância do serviço
              ),


            ],
          ),


          // Agora todo o conteúdo vira um SliverToBoxAdapter
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                _collapsed ? SizedBox.shrink(): Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pedido ${widget.order.sequentialId}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),



                if (widget.order.customerOrderCount != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          widget.order.customerOrderCount == 1
                              ? 'Cliente novo na sua loja!'
                              : '${_ordinal(widget.order.customerOrderCount!)} pedido na loja',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
                _buildStatusBar(widget.order.orderStatus),
                Divider(color: Colors.grey[300], thickness: 0.4, height: 35),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: StoreHeader(store: widget.store),
                ),

                Divider(color: Colors.grey[300], thickness: 0.4, height: 24),
                _buildItemsList(theme, currencyFormat),
                Divider(color: Colors.grey[300], thickness: 0.4, height: 24),
                _buildPaymentSummary(theme, currencyFormat),
                Divider(color: Colors.grey[300], thickness: 0.4, height: 24),

                if (widget.order.deliveryType == 'delivery') _buildAddressCard(theme),
                if (widget.order.deliveryType != 'delivery') const SizedBox(height: 24),

                Divider(color: Colors.grey[300], thickness: 0.4, height: 14),
                _buildPaymentMethodCard(theme, currencyFormat),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 10.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (canStoreCancelOrder(widget.order.orderStatus))
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => showCancelConfirmationDialog(context, widget.order),
                    child: const Text(
                      'Cancelar Pedido',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    _changeOrderStatus(context);
                  },
                  child: Text(
                    getButtonTextForStatus(widget.order.orderStatus, deliveryType),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );




  }

  String _ordinal(int number) {
    switch (number) {
      case 2:
        return 'Segundo';
      case 3:
        return 'Terceiro';
      case 4:
        return 'Quarto';
      case 5:
        return 'Quinto';
      case 6:
        return 'Sexto';
      case 7:
        return 'Sétimo';
      case 8:
        return 'Oitavo';
      case 9:
        return 'Nono';
      case 10:
        return 'Décimo';
      default:
        return '${number}º';
    }
  }

  Widget _buildItemsList(ThemeData theme, NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.receipt),
                        SizedBox(width: 6),
                        Text(
                          'Itens do Pedido',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              ...widget.order.products
                  .map(
                    (product) =>
                        _buildProductItem(product, theme, currencyFormat),
                  )
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(
    OrderProduct product,
    ThemeData theme,
    NumberFormat currencyFormat,
  ) {
    final variantsTotal = product.variants.fold<double>(0.0, (sum, variant) {
      return sum +
          variant.options.fold<double>(0.0, (optionSum, option) {
            return optionSum + (option.price * option.quantity);
          });
    });

    final itemTotal = ((product.price + variantsTotal) * product.quantity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha principal: imagem + nome + valor
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[850], // fundo escuro
                        borderRadius: BorderRadius.circular(6), // borda suave
                      ),
                      child: Center(
                        child: Text(
                          '${product.quantity}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white, // texto branco
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 6,),

                    Expanded(
                      child: Text(
                        product.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      currencyFormat.format(product.price / 100),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          ...product.variants.map(
            (variant) => Padding(
              padding: const EdgeInsets.only(left: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      variant.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  ...variant.options.map(
                    (option) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            '${option.quantity}x',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              option.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Text(
                            currencyFormat.format(option.price / 100),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Adicione APÓS o map de variantes (fora do loop)
          if (product.variants.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total do item com complementos:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w200,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    currencyFormat.format(
                      calculateProductTotalWithComplements(product) / 100,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),

          // Observação do produto (nota)
          if (product.note.isNotEmpty) ...[
         const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange[800]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.note,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

       //   if (product != order.products.last) const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAddressCard(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Endereço cliente',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Card(
            elevation: 0,
            color: Colors.white,
            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.zero,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Alinha os itens no topo
              children: [
                // Coluna com os detalhes do endereço
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Primeira linha (Rua/Número)
                      Text(
                        '${widget.order.street}, ${widget.order.number}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Segunda linha (Bairro/Cidade/Complemento)
                      Text(
                        [
                              widget.order.neighborhood,
                              widget.order.city,
                              if (widget.order.complement?.isNotEmpty ?? false)
                                'Comp: ${widget.order.complement}',
                            ]
                            .where((part) => part != null && part.isNotEmpty)
                            .join(' • '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Forma de entrega (alinhada com a primeira linha)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getDeliveryTypeColor(
                      widget.order.deliveryType,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.order.deliveryType == 'delivery'
                            ? Icons.delivery_dining
                            : Icons.store,
                        size: 14,
                        color: _getDeliveryTypeColor(widget.order.deliveryType),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getDeliveryTypeText(widget.order.deliveryType),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getDeliveryTypeColor(widget.order.deliveryType),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- NOVO WIDGET DE PAGAMENTO ---
  Widget _buildPaymentMethodCard(ThemeData theme, NumberFormat currencyFormat) {
    final total = (widget.order.discountedTotalPrice + (widget.order.deliveryFee ?? 0)) / 100;

    final isDinheiro = widget.order.paymentMethodName.toLowerCase().contains('dinheiro');
    final isCartao = widget.order.paymentMethodName.toLowerCase().contains('cartão') ||
        widget.order.paymentMethodName.toLowerCase().contains('credito') ||
        widget.order.paymentMethodName.toLowerCase().contains('débito') ||
        widget.order.paymentMethodName.toLowerCase().contains('debito');
    final troco = (widget.order.changeAmount ?? 0) / 100;

    String title;
    String description;
    IconData icon;
    Color iconColor = theme.primaryColor;

    if (isDinheiro) {
      icon = Icons.payments;
      title = 'Pagamento em Dinheiro';
      if (troco > 0) {
        description = 'Troco necessário: ${currencyFormat.format(troco)}';
      } else {
        description = 'Pagamento em dinheiro, troco não necessário.';
      }
    } else if (isCartao) {
      icon = Icons.credit_card;
      title = 'Pagamento com Cartão';
      description = 'O pagamento será feito na entrega. Não se esqueça de levar sua maquininha!';
      iconColor = Colors.orange; // Exemplo de cor diferente para cartão
    } else {
      // Outros métodos de pagamento
      icon = Icons.account_balance_wallet;
      title = widget.order.paymentMethodName; // Usa o nome do método como título
      description = 'O pagamento será processado conforme o método selecionado.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: Text(
              'Pagamento',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Card(
            elevation: 0,
            color: Colors.white,
            margin: EdgeInsets.zero,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Centraliza verticalmente
              children: [
                Icon(
                  icon,
                  size: 32, // Ícone maior
                  color: iconColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Cobrar do cliente',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      currencyFormat.format(total),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDeliveryTypeText(String type) {
    switch (type) {
      case 'delivery':
        return 'Delivery';
      case 'takeout':
        return 'Retirada no Local';
      case 'dine_in':
        return 'Consumo no Local';
      default:
        return type;
    }
  }

  Color _getDeliveryTypeColor(String type) {
    switch (type) {
      case 'delivery':
        return Colors.purple;
      case 'takeout':
        return Colors.blue;
      case 'dine_in':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPaymentSummary(ThemeData theme, NumberFormat currencyFormat) {
    final deliveryFee = (widget.order.deliveryFee ?? 0) / 100;
    final subtotal = widget.order.totalPrice / 100;
    final discountAmount = (widget.order.discountAmount ?? 0) / 100;
    final total = (widget.order.discountedTotalPrice + (widget.order.deliveryFee ?? 0)) / 100;

    final hasDiscount = discountAmount > 0;
    final hasCoupon = widget.order.couponCode != null && widget.order.couponCode!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        //  padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIconRow(
              label: 'Subtotal',
              value: currencyFormat.format(subtotal),
              theme: theme,
            ),

            _buildIconRow(
              label: 'Taxa de entrega',
              value: currencyFormat.format(deliveryFee),
              theme: theme,
            ),

            if (hasDiscount)
              _buildIconRow(
                label: 'Desconto aplicado',
                value: '-${currencyFormat.format(discountAmount)}',
                theme: theme,
                valueColor: Colors.green,
              ),

            if (hasCoupon)
              Padding(
                padding: const EdgeInsets.only(),
                child: Row(
                  children: [
                    Text(
                      'Cupom: ${widget.order.couponCode}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (widget.order.discountPercentage != null)
                      Text(
                        ' (${widget.order.discountPercentage!.round()}% off)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),

            _buildIconRow(
              label: 'Total',
              value: currencyFormat.format(total),
              theme: theme,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildIconRow({
    required String label,
    required String value,
    required ThemeData theme,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Text(label, style: theme.textTheme.bodyMedium)]),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(

            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(String currentStatus) {
    const displayStatuses = ['pending', 'preparing', 'ready', 'on_route', 'delivered'];
    final currentStatusIndex = displayStatuses.indexOf(currentStatus);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Status do Pedido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(displayStatuses.length, (index) {
              final isActive = index <= currentStatusIndex;
              final status = displayStatuses[index];
              final color = isActive ? (statusColors[status] ?? Colors.grey) : Colors.grey[300]!;

              return Expanded(
                child: Column(
                  children: [
                    Container(height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 4),
                    Text(
                      // CORRIGIDO: Usa o mapa internalStatusToDisplayName
                      internalStatusToDisplayName[status] ?? status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive ? Colors.black : Colors.grey,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).expand((widget) => [widget, const SizedBox(width: 4)]).toList()..removeLast(),
          ),
        ],
      ),
    );
  }


  void _changeOrderStatus(BuildContext context) {
    String? nextStatus;

    switch (widget.order.orderStatus) {
      case 'pending':
        nextStatus = 'preparing';

        // ✅ CORREÇÃO APLICADA AQUI
        // 1. Verifica se a impressão automática está DESLIGADA.
        if (widget.store.storeSettings?.autoPrintOrders == false) {
          print('Impressão automática desligada. Imprimindo via da cozinha ao aceitar...');

          // 2. Obtém a instância do PrinterService via GetIt (melhor prática).
          final printerService = GetIt.I<PrinterService>();

          // 3. Chama a impressão com o destino específico.
          printerService.printOrder(
            widget.order,
            widget.store,
            destination: 'cozinha',
          );
        }
        break;

      case 'preparing':
        nextStatus = 'ready';
        break;
      case 'ready':
        nextStatus = 'on_route';
        break;
      case 'on_route':
        nextStatus = 'delivered';
        break;
      default:
        nextStatus = null;
    }

    if (nextStatus != null) {
      context.read<OrderCubit>().updateOrderStatus(widget.order.id, nextStatus);
    }
  }

}

int calculateProductTotalWithComplements(OrderProduct product) {
  // O cálculo da variantsTotal aqui deve ser o mesmo que em _buildProductItem
  final variantsTotal = product.variants.fold<int>(0, (sum, variant) {
    return sum +
        variant.options.fold<int>(0, (optionSum, option) {
          return optionSum +
              (option.price *
                  option.quantity); // Multiplica pela quantidade da opção
        });
  });

  return (product.price + variantsTotal) * product.quantity;
}

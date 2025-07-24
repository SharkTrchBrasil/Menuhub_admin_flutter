import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/services/print.dart';

import '../../../cubits/store_manager_cubit.dart';
import '../../../models/order_details.dart';
import '../../../models/order_product.dart';
import '../../../models/store.dart';
import '../../../widgets/order_printing_actions_widget.dart';
import '../utils/order_helpers.dart';

// O nome foi alterado para refletir sua nova função como painel
class OrderDetailsPanel extends StatelessWidget {
  final OrderDetails order;
  final Store? store;
  final VoidCallback onClose; // ✅ Callback para notificar o pai que deve fechar
  final printerService = GetIt.I<PrinterService>();

  OrderDetailsPanel({
    super.key,
    required this.order,
    required this.store,
    required this.onClose, // ✅ Adicionado ao construtor
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    // ✅ O Scaffold foi removido. A raiz agora é um Column.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ NOVO CABEÇALHO DO PAINEL
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detalhes do Pedido #${order.publicId}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose, // Chama o callback para fechar
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // ✅ Conteúdo original agora dentro de um Expanded + SingleChildScrollView
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header original (agora sub-header)
                _buildHeader(theme, dateFormat, timeFormat, context),
                const SizedBox(height: 24),
                // Status Card

                    _buildStatusCard(theme, context),

                const SizedBox(height: 24),
                // Delivery Address
                if (order.deliveryType == 'delivery') _buildAddressCard(theme),
                if (order.deliveryType != 'delivery') const SizedBox(height: 24),
                // Items List
                _buildItemsList(theme, currencyFormat),
                const SizedBox(height: 24),
                // Payment Summary
                _buildPaymentSummary(theme, currencyFormat),
                const SizedBox(height: 24),
                // Actions
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildHeader(
    ThemeData theme,
    DateFormat dateFormat,
    DateFormat timeFormat,
    BuildContext context,
  ) {


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Código do pedido + Nome do cliente
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400, width: 1.2),
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                '${order.sequentialId}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              order.customerName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Loja + horário + localizador + botão de ajuda + badge via iFood
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          spacing: 8,
          children: [
            if (store?.image?.url != null)
              CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(store!.image!.url!),
              ),

            if (store != null)
              Text(
                store!.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

            Text(
              '• Feito às ${timeFormat.format(order.createdAt)} • Localizador do pedido ${order.publicId ?? "XXXX XXXX"}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsList(ThemeData theme, NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
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
                      horizontal: 10,
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

              ...order.products
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

  Widget _buildPaymentSummary(ThemeData theme, NumberFormat currencyFormat) {
    final deliveryFee = (order.deliveryFee ?? 0) / 100;
    final subtotal = order.totalPrice / 100;
    final discountAmount = (order.discountAmount ?? 0) / 100;
    final total = (order.discountedTotalPrice + (order.deliveryFee ?? 0)) / 100;

    final hasDiscount = discountAmount > 0;
    final hasCoupon = order.couponCode != null && order.couponCode!.isNotEmpty;
    final isDinheiro = order.paymentMethodName.toLowerCase().contains(
      'dinheiro',
    );
    final isCartao =
        order.paymentMethodName.toLowerCase().contains('cartão') ||
        order.paymentMethodName.toLowerCase().contains('credito') ||
        order.paymentMethodName.toLowerCase().contains('débito') ||
        order.paymentMethodName.toLowerCase().contains('debito');
    final troco = (order.changeAmount ?? 0) / 100;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (deliveryFee > 0)
            _buildIconRow(
              icon: Icons.local_shipping,
              label: 'Taxa de entrega',
              value: currencyFormat.format(deliveryFee),
              theme: theme,
            ),

          _buildIconRow(
            icon: Icons.attach_money,
            label: 'Subtotal',
            value: currencyFormat.format(subtotal),
            theme: theme,
          ),

          if (hasDiscount)
            _buildIconRow(
              icon: Icons.discount,
              label: 'Desconto aplicado',
              value: '-${currencyFormat.format(discountAmount)}',
              theme: theme,
              valueColor: Colors.green,
            ),

          if (hasCoupon)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 30),
              child: Row(
                children: [
                  Text(
                    'Cupom: ${order.couponCode}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (order.discountPercentage != null)
                    Text(
                      ' (${order.discountPercentage!.round()}% off)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isDinheiro
                    ? Icons.payments
                    : isCartao
                    ? Icons.credit_card
                    : Icons.account_balance_wallet,
                size: 24,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      isDinheiro
                          ? 'Dinheiro (troco: ${currencyFormat.format(troco)})'
                          : isCartao
                          ? '${order.paymentMethodName} (maquininha necessária)'
                          : order.paymentMethodName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isCartao)
                      Text(
                        'Entregador deve levar maquininha',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
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
        ],
      ),
    );
  }

  Widget _buildIconRow({
    required IconData icon,
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
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(label, style: theme.textTheme.bodyMedium),
            ],
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildActionButtons(BuildContext context) {

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => showCancelConfirmationDialog(context, order),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey[400]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancelar Pedido'),
          ),
        ),
        const SizedBox(width: 16),


// Simplesmente adicione o widget!
    Expanded(
      child: OrderPrintingActionsWidget(
      order: order,
      store: store!,
      printerService: printerService,
      ),
    )



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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha principal: imagem + nome + valor
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      image: DecorationImage(
                        image: NetworkImage(product.image!.url!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        '${product.quantity}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
            (variant) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 72, bottom: 4),
                  child: Text(
                    variant.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                ...variant.options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(left: 72, bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${option.quantity}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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

          if (product != order.products.last) const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme, BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getStatusText(order.orderStatus),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getStatusColor(order.orderStatus),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusTimeline(theme, context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(ThemeData theme, BuildContext context) {
    final statusSteps = [
      _StatusStep(
        status: 'pending',
        title: 'Recebido',
        icon: Icons.access_time,
        active: order.orderStatus == 'pending',
        // Apenas 'pending' é ativo para 'pending'
        completed: !['pending', 'canceled'].contains(order.orderStatus),
      ),
      _StatusStep(
        status: 'preparing',
        title: 'Preparação',
        icon: Icons.restaurant,
        active: order.orderStatus == 'preparing',
        completed: [
          'ready',
          'on_route',
          'delivered',
        ].contains(order.orderStatus),
      ),
      _StatusStep(
        status: 'ready',
        title: 'Pronto',
        icon: Icons.local_shipping,
        active: order.orderStatus == 'ready',
        completed: ['on_route', 'delivered'].contains(order.orderStatus),
      ),
      _StatusStep(
        status: 'on_route',
        title: 'Em Rota',
        icon: Icons.delivery_dining,
        active: order.orderStatus == 'on_route',
        completed: order.orderStatus == 'delivered',
      ),
      _StatusStep(
        status: 'delivered',
        title: 'Entregue',
        icon: Icons.check_circle,
        active: order.orderStatus == 'delivered',
        completed: order.orderStatus == 'delivered',
      ),
    ];
    final currentIndex = statusSteps.indexWhere((step) => step.status == order.orderStatus);
    final primaryColor = _getStatusColor('on_route'); // Roxo
    final greyLineColor = Colors.grey[300]!;

    return Column(
      children: [
        // ✅ O `width: double.infinity` foi REMOVIDO daqui.
        // O SizedBox agora apenas define a altura e permite que seu filho determine a largura.
        SizedBox(
          height: 85,
          child: Stack(
            alignment: Alignment.center, // Alinha a linha no centro vertical do Stack
            children: [
              // Linha cinza completa
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(height: 2, color: greyLineColor),
              ),

              // Linha colorida de progresso
              if (currentIndex >= 0) // Usar >= 0 para segurança
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalWidth = constraints.maxWidth;
                      // Calcula a largura do progresso. Se não houver passos, a largura é 0.
                      final progressWidth = statusSteps.length > 1
                          ? (totalWidth / (statusSteps.length - 1)) * currentIndex
                          : 0;

                      return Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: progressWidth.toDouble(),
                            height: 2,
                            color: primaryColor,
                          ),
                        ],
                      );
                    },
                  ),
                ),

              // Bolinhas + títulos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: statusSteps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isCurrent = index == currentIndex;
                  final isPast = index < currentIndex;

                  Widget dot;
                  // Lógica para criar os dots (bolinhas)
                  if (isCurrent) {
                    dot = Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      child: Icon(step.icon, size: 16, color: Colors.white),
                    );
                  } else if (isPast) {
                    dot = Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                    );
                  } else {
                    dot = Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: greyLineColor, width: 2)),
                    );
                  }

                  // ✅ CADA PASSO AGORA É ENVOLVIDO POR UM EXPANDED
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // O Center não é mais necessário dentro de um SizedBox
                        // pois a Column pai já está centralizando.
                        dot,
                        const SizedBox(height: 8),
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isCurrent ? Colors.grey[800] : isPast ? Colors.grey[600] : Colors.grey[400],
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }


  // Método auxiliar para cores de status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'on_route':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAddressCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Alinha os itens no topo
          children: [
            // Ícone de localização
            Padding(
              padding: const EdgeInsets.only(top: 2),
              // Pequeno ajuste de alinhamento
              child: Icon(
                Icons.location_on,
                color: theme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Coluna com os detalhes do endereço
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Primeira linha (Rua/Número)
                  Text(
                    '${order.street}, ${order.number}',
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
                          order.neighborhood,
                          order.city,
                          if (order.complement?.isNotEmpty ?? false)
                            'Comp: ${order.complement}',
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getDeliveryTypeColor(
                  order.deliveryType,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    order.deliveryType == 'delivery'
                        ? Icons.delivery_dining
                        : Icons.store,
                    size: 14,
                    color: _getDeliveryTypeColor(order.deliveryType),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getDeliveryTypeText(order.deliveryType),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getDeliveryTypeColor(order.deliveryType),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pedido Recebido';
      case 'preparing':
        return 'Em Preparação';
      case 'ready':
        return 'Pronto para Entrega';
      case 'delivered':
        return 'Entregue';
      case 'canceled':
        return 'Cancelado';
      case 'on_route':
        return 'Saiu para entrega';
      default:
        return status;
    }
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




}

class _StatusStep {
  final String status;
  final String title;
  final IconData icon;
  final bool active;
  final bool completed;

  _StatusStep({
    required this.status,
    required this.title,
    required this.icon,
    required this.active,
    required this.completed,
  });
}

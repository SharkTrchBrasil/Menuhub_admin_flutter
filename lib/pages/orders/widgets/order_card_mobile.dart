// lib/pages/orders/widgets/order_card_mobile.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/pages/orders/utils/order_helpers.dart'; // Importar o helpers atualizado
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/orders/order_page_cubit.dart';

class OrderCardMobile extends StatefulWidget {
  final OrderDetails order;
  final VoidCallback onTap;
  final Function(OrderDetails order) onPrintOrder;

  const OrderCardMobile({
    super.key,
    required this.order,
    required this.onTap,
    required this.onPrintOrder,
  });

  @override
  State<OrderCardMobile> createState() => _OrderCardMobileState();
}

class _OrderCardMobileState extends State<OrderCardMobile> {
  late Duration _timeRemaining;
  late DateTime _acceptDeadline;
  int _countdownSeconds = 120; // 2 minutos para aceitar

  @override
  void initState() {
    super.initState();
    _updateTimer();
  }

  @override
  void didUpdateWidget(covariant OrderCardMobile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.id != widget.order.id || oldWidget.order.orderStatus != widget.order.orderStatus) {
      _updateTimer();
    }
  }

  void _updateTimer() {
    if (widget.order.orderStatus == 'pending') {
      _acceptDeadline = widget.order.createdAt.add(Duration(seconds: _countdownSeconds));
      _timeRemaining = _acceptDeadline.difference(DateTime.now());

      if (_timeRemaining.isNegative) {
        _timeRemaining = Duration.zero;
        // Opcional: auto-cancelar o pedido se o tempo acabar
        // if (mounted && widget.order.orderStatus == 'pending') {
        //   context.read<OrderCubit>().updateOrderStatus(widget.order.id, 'canceled');
        // }
      }

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && widget.order.orderStatus == 'pending' && _timeRemaining > Duration.zero) {
          setState(() {
            _timeRemaining = _acceptDeadline.difference(DateTime.now());
          });
          _updateTimer();
        }
      });
    } else {
      _timeRemaining = Duration.zero; // Limpa o temporizador para outros status
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final String currentStatus = widget.order.orderStatus;
    final String deliveryType = widget.order.deliveryType; // Pega o tipo de entrega
    final bool canCancel = currentStatus != 'delivered' && currentStatus != 'canceled'; // Pode cancelar se não foi entregue/cancelado
    final bool hasActionButton = getNextStatusInternal(currentStatus, deliveryType) != null; // Tem botão se houver próximo status

    // Obtém o nome de exibição do status (ex: 'pending' -> 'Pendente')
    final String displayName = internalStatusToDisplayName[currentStatus] ?? 'Desconhecido';
    final Color statusColor = statusColors[currentStatus] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${widget.order.publicId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  // Exibe temporizador apenas para pedidos 'pending'
                  if (currentStatus == 'pending')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _timeRemaining > Duration.zero ? 'Aceitar em ${_formatDuration(_timeRemaining)}' : 'Tempo Esgotado',
                        style: TextStyle(
                          color: _timeRemaining > Duration.zero ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  // Exibe o nome do status para todos os outros casos
                  if (currentStatus != 'pending' && statusColors.containsKey(currentStatus))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        displayName, // Usa o nome de exibição completo
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.order.customerName,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.order.products.length} itens • R\$${(widget.order.totalPrice / 100).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // Botões de ação visíveis apenas se houver uma ação disponível (não 'delivered' ou 'canceled')
              if (canCancel || hasActionButton)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (canCancel) // Botão Cancelar
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            _showCancelConfirmationDialog(context);
                          },
                          child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    if (canCancel && hasActionButton) // Espaçamento condicional
                      const SizedBox(width: 8),
                    if (hasActionButton) // Botão de Ação Principal
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: statusColors[currentStatus], // Usa a cor do status para o botão de ação
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            _changeOrderStatus(context);
                          },
                          child: Text(
                            getButtonTextForStatus(currentStatus, deliveryType),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                )
              else // Se não há botões de ação, mostra uma mensagem de status final
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      displayName, // Exibe o status final completo (Concluído/Cancelado)
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeOrderStatus(BuildContext context) {
    // Usa a nova função para obter o próximo status
    final String? nextStatus = getNextStatusInternal(widget.order.orderStatus, widget.order.deliveryType);

    if (nextStatus != null) {
      context.read<OrderCubit>().updateOrderStatus(widget.order.id, nextStatus);
      // Lógica de impressão se o pedido for aceito (pending -> preparing)
      if (widget.order.orderStatus == 'pending' && nextStatus == 'preparing') {
        widget.onPrintOrder(widget.order);
      }
    } else {
      // Opcional: mostrar uma mensagem ou log se não houver próximo status
      debugPrint('Não há transição de status definida para ${widget.order.orderStatus}');
    }
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Cancelamento'),
          content: Text('Tem certeza que deseja cancelar o pedido #${widget.order.publicId}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sim', style: TextStyle(color: Colors.white)),
              onPressed: () {
                context.read<OrderCubit>().updateOrderStatus(widget.order.id, 'canceled'); // Use 'canceled'
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
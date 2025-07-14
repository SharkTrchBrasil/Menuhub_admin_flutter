import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Mantido caso seja usado em outro lugar, mas não diretamente neste trecho
import 'package:totem_pro_admin/core/extensions/extensions.dart';

import '../../../models/order_details.dart';
import '../utils/order_helpers.dart'; // Importe seu modelo OrderDetails

class OrderCard extends StatefulWidget {
  final OrderDetails order;
  final int currentStatusIndex;
  final List<Color> statusColors;
  final List<String> statusTabs;

  final Map<String, String> statusInternalMap;
  final Map<String, IconData> deliveryTypeIcons;
  final String Function(int, String) getButtonTextForStatus;

  final void Function(int orderId, String nextStatus) onUpdateOrderStatus;
  final String Function(DateTime) formatDate;
  final bool isNewOrder;

  const OrderCard({
    super.key,
    required this.order,
    required this.currentStatusIndex,
    required this.statusColors,
    required this.statusTabs,
    required this.statusInternalMap,
    required this.deliveryTypeIcons,
    required this.getButtonTextForStatus,
    required this.onUpdateOrderStatus,
    required this.formatDate,
    required this.isNewOrder,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _borderAnimationController;
  Animation<Color?>? _borderColorAnimation;

  late String _relativeTime;
  Timer? _timer;

  // Lista de cores para o efeito de "borda correndo"
  // Adicione mais cores ou mude a sequência conforme desejar
  static const List<Color> _borderPulseColors = [
    Colors.deepOrange, // Cor inicial mais vibrante
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.blue,
    Colors.cyan,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();

    _relativeTime = timeAgoFromDate(widget.order.createdAt);
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateRelativeTime(),
    );

    if (widget.isNewOrder) {
      _borderAnimationController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: _borderPulseColors.length * 500,
        ), // Duração total baseada no número de cores
      )..repeat(reverse: false); // Não inverte, apenas repete o ciclo

      // Cria uma sequência de tweens para animar entre as cores
      final List<TweenSequenceItem<Color?>> items = [];
      for (int i = 0; i < _borderPulseColors.length; i++) {
        final beginColor = _borderPulseColors[i];
        final endColor =
            _borderPulseColors[(i + 1) %
                _borderPulseColors.length]; // Cicla para a próxima cor
        items.add(
          TweenSequenceItem(
            tween: ColorTween(begin: beginColor, end: endColor),
            weight: 1.0, // Cada cor tem o mesmo peso/duração na sequência
          ),
        );
      }

      _borderColorAnimation = TweenSequence<Color?>(
        items,
      ).animate(_borderAnimationController!);
    }
  }

  void _updateRelativeTime() {
    setState(() {
      _relativeTime = timeAgoFromDate(widget.order.createdAt);
    });
  }

  @override
  void dispose() {
    _borderAnimationController?.dispose(); // Dispõe o controlador da borda
    _timer?.cancel(); // cancelamento importante
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.statusColors[widget.currentStatusIndex];
    final deliveryIcon =
        widget.deliveryTypeIcons[widget.order.deliveryType] ??
        Icons.help_outline;

    // Obter largura da tela para responsividade
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen =
        screenWidth < 600; // Define um breakpoint para tela pequena

    // Padding e fontes ajustáveis
    final double cardPadding = isSmallScreen ? 12 : 16;
    final double titleFontSize = isSmallScreen ? 16 : 18;
    final double textFontSize = isSmallScreen ? 13 : 15;
    final double iconSize = isSmallScreen ? 18 : 20;

    final cardContent = Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 4 : 8,
        vertical: isSmallScreen ? 4 : 8,
      ),
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
        border:
            widget.isNewOrder
                ? Border.all(
                  color:
                      _borderColorAnimation?.value ??
                      Colors.deepOrange, // Usar a cor animada
                  width: 1.0, // Borda um pouco mais grossa para destacar
                )
                : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding), // Padding responsivo
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com ícone + número do pedido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize:
                        MainAxisSize
                            .min, // Ocupar o mínimo de espaço necessário
                    children: [
                      Icon(
                        deliveryIcon,
                        size: iconSize,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 8),
                      Expanded(
                        // Usar Expanded para que o texto quebre ou use ellipsis
                        child: Text(
                          'Pedido #${widget.order.sequentialId}',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isSmallScreen ? 4 : 8),
                Row(
                  children: [
                    Text(
                      widget.formatDate(widget.order.createdAt),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: textFontSize,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(_relativeTime),
                  ],
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 8 : 12),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        widget.order.customerName ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: textFontSize),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 8),
                    Text(
                      widget.order.totalPrice.toPrice(),
                      style: TextStyle(
                        fontSize: textFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        widget.order.customerPhone ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: textFontSize,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 8),
                    Flexible(
                      child: Text(
                        widget.order.paymentMethodName ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: textFontSize,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 8 : 12),

            // Endereço
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alinhar ícone e texto ao topo
              children: [
                Icon(Icons.location_on, size: iconSize, color: Colors.grey),
                SizedBox(width: isSmallScreen ? 4 : 8),
                Expanded(
                  child: Text(
                    widget.order.deliveryType == 'takeout'
                        ? 'Retirada na loja'
                        : (widget.order.street ?? '') +
                            (widget.order.number == null
                                ? ''
                                : ', ${widget.order.number}') +
                            (widget.order.neighborhood != null
                                ? ', ${widget.order.neighborhood}'
                                : '') +
                            (widget.order.city != null
                                ? ', ${widget.order.city}'
                                : ''),
                    style: TextStyle(
                      fontSize: textFontSize,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2, // Permite que o endereço ocupe até duas linhas
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 12 : 16),

            // Botão de status
            if (widget.currentStatusIndex < widget.statusTabs.length)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    final currentInternalStatus = widget.order.orderStatus;
                    final statusValues =
                        widget.statusInternalMap.values.toList();
                    final currentIndex = statusValues.indexOf(
                      currentInternalStatus,
                    );
                    final isLast = currentIndex == statusValues.length - 2;

                    if (currentIndex != -1 && !isLast) {
                      final nextStatus = statusValues[currentIndex + 1];
                      widget.onUpdateOrderStatus(widget.order.id, nextStatus);
                    } else {
                      final finishedStatus =
                          widget.statusInternalMap['Finalizado'] ?? 'finished';
                      widget.onUpdateOrderStatus(
                        widget.order.id,
                        finishedStatus,
                      );
                    }
                  },
                  child: Text(
                    widget.getButtonTextForStatus(
                      widget.currentStatusIndex,
                      widget.order.orderStatus,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ), // Tamanho da fonte do botão
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    // Retorna com animação da borda se for novo pedido
    if (widget.isNewOrder && _borderAnimationController != null) {
      return AnimatedBuilder(
        animation: _borderAnimationController!,
        builder: (context, _) {
          return cardContent; // O cardContent já tem a borda animada
        },
      );
    }

    return cardContent;
  }
}

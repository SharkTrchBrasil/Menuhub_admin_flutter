import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/models/order.dart';

import '../../../core/router.dart';

import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';
import '../../../models/order_details.dart';
import '../../../models/order_product.dart';
import '../../../utils/sounds/sound_util.dart';
import 'package:bot_toast/bot_toast.dart';

import '../order_page_cubit.dart';
import '../service/print.dart';

String formatOrderDate(DateTime date) {
  return DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
}

String getDeliveryTypeName(String? deliveryType) {
  switch (deliveryType) {
    case 'delivery':
      return 'Entrega';
    case 'takeout':
      return 'Retirada na Loja';
    case 'table':
      return 'Mesa';
    default:
      return 'Não Definido';
  }
}

void handleNewOrderArrival({
  required BuildContext context,
  required List<OrderDetails> currentOrders,
  required String? lastNotifiedOrderId,
  required void Function(String id) setLastNotifiedOrderId,
  required void Function(OrderDetails order) printOrder,
}) {
  final now = DateTime.now().toUtc();

  final recentNewOrders =
      currentOrders
          .where(
            (order) =>
                (order.orderStatus == 'pending' ||
                    order.orderStatus == 'preparing') &&
                order.id.toString() != lastNotifiedOrderId &&
                now.difference(order.createdAt).inSeconds < 180,
          )
          .toList();

  if (recentNewOrders.isEmpty) return;

  final newOrder = recentNewOrders.reduce(
    (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
  );

  setLastNotifiedOrderId(newOrder.id.toString());

  if (newOrder.orderStatus == 'pending') {
    SoundAlertUtil.playNewOrderSound();
    print('Som de novo pedido acionado para o Pedido #${newOrder.id}');
  }

  final storeState = context.read<StoresManagerCubit>().state;
  if (storeState is StoresManagerLoaded) {
    final store = storeState.stores[storeState.activeStoreId!]?.store;
    if (store?.storeSettings?.autoPrintOrders == true) {
      printOrder(newOrder);
    }
  }
}

extension IterableExtensions<T> on Iterable<T> {
  T? reduceOrNull(T Function(T, T) combine) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    var value = iterator.current;
    while (iterator.moveNext()) {
      value = combine(value, iterator.current);
    }
    return value;
  }
}

OrderDetails? findLatestPendingNewOrder(
  List<OrderDetails> orders,
  String? lastNotifiedId,
) {
  return orders
      .where(
        (order) =>
            order.orderStatus == 'pending' &&
            order.id.toString() != lastNotifiedId &&
            DateTime.now().toUtc().difference(order.createdAt).inSeconds < 180,
      )
      .reduceOrNull((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
}

String timeAgoFromDate(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) return 'há poucos segundos';
  if (difference.inMinutes < 60) return 'há ${difference.inMinutes} min';
  if (difference.inHours < 24) return 'há ${difference.inHours}h';
  return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
}

void showNewOrderNotification(String orderCode, int storeId) {
  // Garante que está no contexto correto
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      BotToast.showNotification(
        title:
            (_) => const Text(
              '🛎️ Novo Pedido!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
        subtitle:
            (_) => const Text(
              'Pedido recebido',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
        backgroundColor: Colors.green[600] ?? Colors.green,
        duration: const Duration(seconds: 5),
        animationDuration: const Duration(milliseconds: 300),
        align: Alignment.topRight,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        onlyOne: false,
        enableSlideOff: true,
        crossPage: true,
        trailing:
            (cancelFunc) => TextButton(
              onPressed: () {
                cancelFunc();
                globalNavigatorKey.currentState?.pushNamed(
                  '/stores/$storeId/orders',
                  arguments: {'orderCode': orderCode},
                );
              },
              child: const Text('Ver', style: TextStyle(color: Colors.white)),
            ),
      );
    } catch (e) {
      debugPrint('Erro ao mostrar notificação: $e');
      // Fallback com contexto garantido
      _showFallbackNotification(orderCode, storeId);
    }
  });
}

void _showFallbackNotification(String orderCode, int storeId) {
  final context = globalNavigatorKey.currentContext;
  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Novo pedido $orderCode'),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () {
            globalNavigatorKey.currentState?.pushNamed(
              '/stores/$storeId/orders',
            );
          },
        ),
      ),
    );
  }
}

// --- Definições de Status e Mapeamentos ---

// Nomes de status para exibição nas ABAS DO MOBILE (Apenas os que precisam de interação ou foco)
const List<String> mobileStatusTabs = [
  'Pendentes',
  'Em Preparo',
  'Em Entrega',
  'Prontos',
];

// Mapeamento de nomes de ABAS/UI para nomes internos do backend
const Map<String, String> mobileStatusInternalMap = {
  'Pendentes': 'pending',
  'Em Preparo': 'preparing',
  'Em Entrega': 'on_route',
  'Prontos': 'ready',
};

// Mapeamento de TODOS os status internos do backend para seus nomes de exibição completos na UI
const Map<String, String> internalStatusToDisplayName = {
  'pending': 'Acetar pedidos',
  'preparing': 'Em Preparo',
  'ready': 'Pronto',
  'on_route': 'Em Entrega',
  'delivered': 'Concluído',
  'canceled': 'Cancelado',
};

// Cores associadas a CADA status interno
const Map<String, Color> statusColors = {
  'pending': Colors.orange,
  'preparing': Colors.blue,
  'ready': Colors.purple,
  'on_route': Colors.green,
  'delivered': Colors.grey,
  'canceled': Colors.red,
};

// Ícones dos tipos de entrega
const Map<String, IconData> deliveryTypeIcons = {
  'delivery': Icons.delivery_dining,
  'takeout': Icons.store,
  'table': Icons.restaurant,
};

// Lógica para o texto do botão de ação, baseado no status atual do pedido.
String getButtonTextForStatus(String currentOrderStatus, String deliveryType) {
  switch (currentOrderStatus) {
    case 'pending':
      return 'Aceitar Pedido';
    case 'preparing':
      if (deliveryType == 'takeout') {
        return 'Pronto';
      }
      return 'Despachar pedido';
    case 'ready':
      if (deliveryType == 'takeout') {
        return 'Finalizar Retirada';
      }
      return 'Iniciar Entrega';
    case 'on_route':
      return 'Marcar como Entregue';
    default:
      return 'Sem Ação';
  }
}

// Lógica para o PRÓXIMO status interno do pedido (backend)
String? getNextStatusInternal(String currentOrderStatus, String deliveryType) {
  switch (currentOrderStatus) {
    case 'pending':
      return 'preparing';
    case 'preparing':
      return 'ready';
    case 'ready':
      if (deliveryType == 'takeout') {
        return 'delivered';
      }
      return 'on_route';
    case 'on_route':
      return 'delivered';
    default:
      return null;
  }
}

void printOrder(OrderDetails order) {
  print('🖨️ Imprimindo pedido #${order.id}...');
  printOrderReceipt(order);
}

void printOrderReceipt(OrderDetails order) async {
  try {
    final printerService = PrinterService();

    // Formatar datas
    final createdAt = DateFormat('dd/MM/yyyy HH:mm:ss').format(order.createdAt);
    final deliveryAt =
        order.scheduledFor != null
            ? DateFormat('dd/MM/yyyy HH:mm:ss').format(order.scheduledFor!)
            : DateFormat(
              'dd/MM/yyyy HH:mm:ss',
            ).format(order.createdAt.add(Duration(minutes: 30)));

    // Determinar tipo de entrega
    final deliveryType = _getDeliveryType(order.deliveryType);

    // Converter valores monetários
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    // Preparar itens para impressão
    final items = _prepareReceiptItems(order.products, currencyFormat);

    // Calcular totais
    final total = order.discountedTotalPrice / 100;
    final subtotal = order.totalPrice / 100;
    final deliveryFee =
        order.deliveryFee != null ? order.deliveryFee! / 100 : 0;
    final discount = (order.totalPrice - order.discountedTotalPrice) / 100;

    // Construir footer com todas as informações adicionais
    final footer = '''
${deliveryType.toUpperCase()}

${_getStoreName(order)}
Data do Pedido: $createdAt
${order.scheduledFor != null ? 'Data de Entrega: $deliveryAt' : 'Data de Entrega Estimada: $deliveryAt'}
Cliente: ${order.customerName.isNotEmpty ? order.customerName : 'Consumidor'}
Telefone: ${_formatPhone(order.customerPhone)}
---
TOTAL
Valor dos itens: ${currencyFormat.format(subtotal)}
${deliveryFee > 0 ? 'Taxa de Entrega: ${currencyFormat.format(deliveryFee)}' : ''}
${discount > 0 ? 'Desconto: ${currencyFormat.format(discount)}' : ''}
VALOR TOTAL: ${currencyFormat.format(total)}
......
FORMA DE PAGAMENTO
${order.paymentMethodName.toUpperCase()}
${order.changeAmount != null && order.changeAmount! > 0 ? 'Troco para: ${currencyFormat.format(order.changeAmount! / 100)}' : ''}
......
${order.observation != null && order.observation!.isNotEmpty ? 'Obs: ${order.observation}' : ''}
......
${order.deliveryType == 'delivery' ? _buildDeliveryAddressSection(order) : ''}
......
Impresso em: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}
''';

    await printerService.printReceipt(
      title: 'PEDIDO #${order.publicId}',
      items: items,
      total: total,
      footer: footer,
      is58mm: true,
    );
  } catch (e) {
    print('Erro ao imprimir: $e');
    // Adicione aqui tratamento de erro adequado
    rethrow; // Opcional: propagar o erro para tratamento superior
  }
}

List<Map<String, String>> _prepareReceiptItems(
  List<OrderProduct> products,
  NumberFormat currencyFormat,
) {
  return products.expand((product) {
    final items = <Map<String, String>>[];

    // Item principal
    items.add({
      'name': '${product.quantity}x ${product.name.toUpperCase()}',
      'value': currencyFormat.format((product.price * product.quantity) / 100),
    });

    // Variantes/adicionais
    for (final variant in product.variants) {
      items.add({'name': '  ${variant.name}'});
    }

    // Observações
    if (product.note.isNotEmpty) {
      items.add({'name': '  Obs: ${product.note}', 'value': ''});
    }

    // Separador
    items.add({'name': '......', 'value': ''});

    return items;
  }).toList();
}

// Funções auxiliares melhoradas
String _getDeliveryType(String deliveryType) {
  switch (deliveryType.toLowerCase()) {
    case 'delivery':
      return 'Delivery';
    case 'takeout':
      return 'Pra Retirar';
    case 'dine_in':
      return 'Na Mesa';
    default:
      return deliveryType;
  }
}

String _getStoreName(OrderDetails order) {
  return order.storeId.toString() ?? 'NOME DO ESTABELECIMENTO';
}

String _formatPhone(String phone) {
  if (phone.isEmpty) return '';
  // Formatação básica de telefone: (XX) XXXX-XXXX
  return phone.replaceAllMapped(
    RegExp(r'^(\d{2})(\d{4,5})(\d{4})$'),
    (Match m) => '(${m[1]}) ${m[2]}-${m[3]}',
  );
}

String _buildItemsSection(
  List<OrderProduct> products,
  NumberFormat currencyFormat,
) {
  final buffer = StringBuffer();
  double itemsTotal = 0;

  for (final product in products) {
    final itemTotal = (product.price * product.quantity) / 100;
    itemsTotal += itemTotal;

    buffer.writeln('${product.quantity} UN');
    buffer.writeln(
      '${product.name.toUpperCase()}${' ' * (30 - product.name.length)}${currencyFormat.format(product.price / 100)}',
    );

    if (product.variants.isNotEmpty) {
      for (final variant in product.variants) {
        //   final variantPrice = variant.name > 0 ? '${currencyFormat.format(variant.price / 100)}' : '';
        //  buffer.writeln('  ${variant.quantity} UN ${variant.name}${' ' * (25 - variant.name.length)}$variantPrice');
      }
    }

    if (product.note.isNotEmpty) {
      buffer.writeln('Obs: ${product.note}');
    }

    buffer.writeln(
      'Total do item${' ' * (20)}${currencyFormat.format(itemTotal)}',
    );
    buffer.writeln('......');
  }

  return buffer.toString();
}

// Método para verificar se o lojista pode cancelar
bool canStoreCancelOrder(String currentOrderStatus) {
  return ['pending', 'preparing', 'ready'].contains(currentOrderStatus);
}

String _buildPaymentSection(OrderDetails order, NumberFormat currencyFormat) {
  final buffer = StringBuffer();

  final paymentMethod = order.paymentMethodName.toUpperCase();
  final totalPaid = order.discountedTotalPrice / 100;

  if (paymentMethod.contains('ONLINE')) {
    buffer.writeln(
      'Pagamento Online ($paymentMethod)${' ' * (10)}${currencyFormat.format(totalPaid)}',
    );
  } else {
    buffer.writeln(
      '$paymentMethod${' ' * (25 - paymentMethod.length)}${currencyFormat.format(totalPaid)}',
    );
  }

  if (order.changeAmount != null && order.changeAmount! > 0) {
    buffer.writeln(
      'Troco para${' ' * (20)}${currencyFormat.format(order.changeAmount! / 100)}',
    );
  }

  return buffer.toString();
}

String _buildDeliveryAddressSection(OrderDetails order) {
  return '''
    ENTREGA PEDIDO #${order.publicId}

Horário da Entrega: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(order.scheduledFor ?? order.createdAt.add(Duration(minutes: 30)))}
Cliente: ${order.customerName}
Endereço: ${order.street}, ${order.number}
${order.complement?.isNotEmpty ?? false ? 'Comp: ${order.complement}' : ''}

Bairro: ${order.neighborhood}
Cidade: ${order.city} -  'UF'}

''';
}

String _formatCEP(String? cep) {
  if (cep == null || cep.isEmpty) return 'NÃO INFORMADO';
  final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleanCep.length == 8) {
    return '${cleanCep.substring(0, 2)}.${cleanCep.substring(2, 5)}-${cleanCep.substring(5)}';
  }
  return cep;
}

void showCancelConfirmationDialog(BuildContext context, OrderDetails order) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Confirmar Cancelamento'),
        content: Text('Tem certeza que deseja cancelar o pedido #${order.publicId}?'),
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
              context.read<OrderCubit>().updateOrderStatus(order.id, 'cancelled');
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(); // Fechar a tela de detalhes após cancelar
            },
          ),
        ],
      );
    },
  );
}
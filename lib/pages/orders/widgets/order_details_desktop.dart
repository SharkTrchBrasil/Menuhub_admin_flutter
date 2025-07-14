// lib/pages/orders/widgets/_order_details_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Necessário para acessar Cubits
import 'package:intl/intl.dart'; // Para formatação de data e hora
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/pages/orders/utils/order_helpers.dart'; // For deliveryTypeIcons, formatOrderDate, statusColors, internalStatusToDisplayName
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart'; // Para acessar o nome/logo da loja
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import 'order_status_button.dart'; // Para acessar o estado do Cubit da loja


class OrderDetailsPanelDestop extends StatelessWidget {
  final OrderDetails? selectedOrder;
  final Function(OrderDetails order) onPrintOrder; // Adiciona a função de impressão

  const OrderDetailsPanelDestop({
    super.key,
    required this.selectedOrder,
    required this.onPrintOrder, // Requer a função de impressão
  });

  @override
  Widget build(BuildContext context) {
    if (selectedOrder == null) {
      return const Center(
        child: Text(
          'Selecione um pedido para ver os detalhes.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final order = selectedOrder!;
    final DateFormat timeFormatter = DateFormat('HH:mm'); // Formato da hora (ex: 10:48)

    // Acessar o StoresManagerCubit para obter detalhes da loja
    final storeManagerState = context.watch<StoresManagerCubit>().state;
    String storeName = 'Loja Desconhecida';
    // String? storeLogoUrl; // Descomente se seu modelo Store tiver 'logoUrl'

    if (storeManagerState is StoresManagerLoaded && storeManagerState.stores.containsKey(order.storeId)) {
      final store = storeManagerState.stores[order.storeId]!.store;
      storeName = store.name;
      // storeLogoUrl = store.logoUrl;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABEÇALHO: Numero do Pedido _ Nome do Cliente
          Text(
            '#${order.publicId} _ ${order.customerName}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Logo da Loja e Nome - Feito as HH:MM
          Row(
            children: [
              // if (storeLogoUrl != null && storeLogoUrl.isNotEmpty) // Se tiver logo
              //   Image.network(storeLogoUrl, height: 30, width: 30),
              // else
              const Icon(Icons.store, size: 24), // Ícone de placeholder
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  storeName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Feito às ${timeFormatter.format(order.createdAt)}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),

          // Detalhes do Cliente
          const Text(
            'Detalhes do Cliente',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Nome:',
            order.customerName,
            Icons.person,
          ),
          _buildDetailRow(
            'Telefone:',
            order.customerPhone,
            Icons.phone,
          ),
          // Endereço só se não for agendado e tiver dados
          if (!order.isScheduled && order.street != null && order.street!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  'Endereço:',
                  '${order.street}, ${order.number}',
                  Icons.location_on,
                ),
                if (order.complement != null && order.complement!.isNotEmpty)
                  _buildDetailRow(
                    'Complemento:',
                    order.complement!,
                    Icons.info_outline,
                  ),
                _buildDetailRow(
                  'Bairro:',
                  order.neighborhood ?? 'Não informado',
                  Icons.area_chart,
                ),
                _buildDetailRow(
                  'Cidade:',
                  order.city ?? 'Não informado',
                  Icons.location_city,
                ),
              ],
            )
          else if (order.isScheduled)
            _buildDetailRow(
              'Observação:',
              'Pedido agendado - Detalhes de endereço não aplicáveis neste painel.',
              Icons.calendar_today,
              textColor: Colors.orange,
            ),

          // Tipo de Pedido (Delivery, Retirada, Mesa)
          _buildDetailRow(
            'Tipo de Pedido:',
            internalStatusToDisplayName[order.deliveryType] ?? order.deliveryType, // Usa display name se houver
            deliveryTypeIcons[order.deliveryType] ?? Icons.receipt,
          ),
          const SizedBox(height: 24),

          // Itens do Pedido
          const Text(
            'Itens do Pedido',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...order.products.map((product) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    // Inclui variantes se existirem
                    '${product.quantity}x ${product.name}' +
                        (product.variants.isNotEmpty
                            ? ' (${product.variants.map((v) => v.options.map((o) => o.name).join(', ')).join('; ')})'
                            : ''),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Text(
                  'R\$ ${(product.price / 100).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )).toList(),
          const Divider(height: 32, thickness: 1),

          // Resumo de Preços
          _buildPriceRow('Subtotal:', order.products.fold(0.0, (sum, p) => sum + (p.price / 100)).toStringAsFixed(2)),
          // Certifique-se que deliveryFee está sendo lido como int/double do backend e pode ser nulo
          _buildPriceRow('Taxa de Entrega:', ((order.deliveryFee ?? 0) / 100).toStringAsFixed(2)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'R\$ ${(order.totalPrice / 100).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Botões de Ação (Status e Cancelar)
          OrderStatusButton(
            order: order,
            onPrintOrder: onPrintOrder, // Passa a função de impressão
          ),
          const SizedBox(height: 8), // Espaçamento entre o botão de status e o de imprimir
          ElevatedButton.icon(
            onPressed: () => onPrintOrder(order), // Usa a função passada via construtor
            icon: const Icon(Icons.print, color: Colors.white),
            label: const Text('Imprimir Comprovante', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Cor diferente para o botão de imprimir
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method para _buildDetailRow
  Widget _buildDetailRow(String label, String value, IconData icon, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method para _buildPriceRow
  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'R\$ $value',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
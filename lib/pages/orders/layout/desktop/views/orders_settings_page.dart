import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/store/store_operation_config.dart';

import 'package:totem_pro_admin/widgets/fixed_header.dart';

import '../../../../operation_configuration/cubit/operation_config_cubit.dart';

class OrdersSettingsPage extends StatelessWidget {
  const OrdersSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          return _buildLoadingState();
        }

        // ✅ CORREÇÃO: Tratamento robusto de null
        final settings = state.activeStore?.relations.storeOperationConfig;

        if (settings == null) {
          return _buildErrorState(
              context,
              'Configurações não carregadas.\nPor favor, recarregue a página.'
          );
        }

        final store = state.activeStore;
        if (store == null) {
          return _buildErrorState(context, 'Nenhuma loja selecionada');
        }


        return Container(
color: Colors.white,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildSettingsContent(context, settings, store.core.id!),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,

      ),
      child: const FixedHeader(
        title: 'Configurações de Pedidos',
        subtitle: 'Gerencie como sua loja recebe e processa pedidos',
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CONTEÚDO
  // ═══════════════════════════════════════════════════════════
  Widget _buildSettingsContent(
      BuildContext context,
      StoreOperationConfig settings,
      int storeId,
      ) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Status da Loja
        _buildStatusCard(context, settings, storeId),
        const SizedBox(height: 24),

        // Modalidades de Pedido
        _buildSectionCard(
          context: context,
          title: 'Modalidades de Pedido',
          subtitle: 'Controle quais formas de pedido estão disponíveis',
          icon: Icons.shopping_bag_outlined,
          iconColor: Colors.blue,
          children: [
            _buildSettingTile(
              context: context,
              title: 'Delivery',
              description: 'Entregas no endereço do cliente',
              icon: Icons.delivery_dining_outlined,
              value: settings.deliveryEnabled,
              onChanged: (_) => _updateSettings(
                context,
                storeId,
                settings,
                deliveryEnabled: !settings.deliveryEnabled,
              ),
            ),

            _buildSettingTile(
              context: context,
              title: 'Retirada',
              description: 'Cliente busca no local',
              icon: Icons.storefront_outlined,
              value: settings.pickupEnabled,
              onChanged: (_) => _updateSettings(
                context,
                storeId,
                settings,
                pickupEnabled: !settings.pickupEnabled,
              ),
            ),

            _buildSettingTile(
              context: context,
              title: 'Serviço de Mesa',
              description: 'Pedidos feitos nas mesas do estabelecimento',
              icon: Icons.restaurant_menu_outlined,
              value: settings.tableEnabled,
              onChanged: (_) => _updateSettings(
                context,
                storeId,
                settings,
                tableEnabled: !settings.tableEnabled,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Automação
        _buildSectionCard(
          context: context,
          title: 'Automação de Pedidos',
          subtitle: 'Configure o comportamento automático do sistema',
          icon: Icons.auto_awesome_outlined,
          iconColor: Colors.purple,
          children: [
            _buildSettingTile(
              context: context,
              title: 'Aceitar pedidos automaticamente',
              description: 'Novos pedidos são aceitos e vão direto para preparo',
              icon: Icons.check_circle_outline,
              value: settings.autoAcceptOrders,
              onChanged: (_) => _updateSettings(
                context,
                storeId,
                settings,
                autoAcceptOrders: !settings.autoAcceptOrders,
              ),
            ),

            _buildSettingTile(
              context: context,
              title: 'Imprimir automaticamente',
              description: 'Envia pedidos para impressora assim que chegam',
              icon: Icons.print_outlined,
              value: settings.autoPrintOrders,
              onChanged: (_) => _updateSettings(
                context,
                storeId,
                settings,
                autoPrintOrders: !settings.autoPrintOrders,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Informações adicionais
  //      _buildInfoCard(context, settings),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CARD DE STATUS DA LOJA
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatusCard(
      BuildContext context,
      StoreOperationConfig settings,
      int storeId,
      ) {
    final isOpen = settings.isStoreOpen;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOpen
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isOpen ? Icons.store : Icons.store_mall_directory_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status da Loja',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOpen ? 'Aberta' : 'Fechada Temporariamente',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOpen,
                onChanged: (_) => _updateSettings(
                  context,
                  storeId,
                  settings,
                  isStoreOpen: !settings.isStoreOpen,
                ),

              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isOpen ? Icons.info_outline : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isOpen
                        ? 'Sua loja está recebendo pedidos normalmente'
                        : 'Clientes não conseguem fazer novos pedidos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CARD DE SEÇÃO
  // ═══════════════════════════════════════════════════════════
  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0XFFF5F5F5),
        borderRadius: BorderRadius.circular(16),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da seção
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
        //  Divider(height: 1, color: Colors.grey[200]),

          // Conteúdo
          ...children,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TILE DE CONFIGURAÇÃO
  // ═══════════════════════════════════════════════════════════
  Widget _buildSettingTile({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(

        decoration: BoxDecoration(
            color: value ? Colors.white : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),

        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: value ? Colors.green : Colors.grey[600],
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
          ),
          trailing: Switch(
            value: value,
            onChanged: onChanged,

          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CARD DE INFORMAÇÕES
  // ═══════════════════════════════════════════════════════════
  Widget _buildInfoCard(BuildContext context, StoreOperationConfig settings) {
    final activeModalities = [
      if (settings.deliveryEnabled) 'Delivery',
      if (settings.pickupEnabled) 'Retirada',
      if (settings.tableEnabled) 'Mesa',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              Text(
                'Resumo das Configurações',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.store,
            label: 'Status da Loja',
            value: settings.isStoreOpen ? 'Aberta' : 'Fechada',
            valueColor: settings.isStoreOpen ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.shopping_cart_outlined,
            label: 'Modalidades Ativas',
            value: activeModalities.isEmpty ? 'Nenhuma' : activeModalities.join(', '),
            valueColor: activeModalities.isEmpty ? Colors.red : Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.auto_awesome,
            label: 'Aceitação Automática',
            value: settings.autoAcceptOrders ? 'Ativada' : 'Desativada',
            valueColor: settings.autoAcceptOrders ? Colors.green : Colors.grey,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.print,
            label: 'Impressão Automática',
            value: settings.autoPrintOrders ? 'Ativada' : 'Desativada',
            valueColor: settings.autoPrintOrders ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════
  void _updateSettings(
      BuildContext context,
      int storeId,
      StoreOperationConfig settings, {
        bool? isStoreOpen,
        bool? deliveryEnabled,
        bool? pickupEnabled,
        bool? tableEnabled,
        bool? autoAcceptOrders,
        bool? autoPrintOrders,
      }) {
    context.read<OperationConfigCubit>().updatePartialSettings(
      storeId,
      settings,
      isStoreOpen: isStoreOpen,
      deliveryEnabled: deliveryEnabled,
      pickupEnabled: pickupEnabled,
      tableEnabled: tableEnabled,
      autoAcceptOrders: autoAcceptOrders,
      autoPrintOrders: autoPrintOrders,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando configurações...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
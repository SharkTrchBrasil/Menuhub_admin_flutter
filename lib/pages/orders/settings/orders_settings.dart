// Em: widgets/store_settings_side_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import 'package:totem_pro_admin/models/store/store_operation_config.dart';

import '../../operation_configuration/cubit/operation_config_cubit.dart';

class StoreSettingsSidePanel extends StatelessWidget {
  final int storeId;

  const StoreSettingsSidePanel({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is StoresManagerLoaded) {
          final storeWithRole = state.stores[storeId];
          final store = storeWithRole?.store;
          final settings = store?.relations.storeOperationConfig;

          if (store == null || settings == null) {
            return _buildErrorState(context);
          }

          return _buildSettingsList(context, settings, storeId);
        }
        return _buildLoadingState();
      },
    );
  }

  Widget _buildSettingsList(
      BuildContext context,
      StoreOperationConfig settings, // ✅ Tipagem correta
      int storeId,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader('Operações da Loja', context),

          // ✅ CORREÇÃO: Passa os parâmetros corretos
          _buildSettingItem(
            context: context,
            title: 'Fechar temporariamente',
            description: 'Interrompe completamente o funcionamento da loja',
            icon: Icons.store_mall_directory_outlined,
            value: !settings.isStoreOpen,
            onChanged: (_) => context.read<OperationConfigCubit>().updatePartialSettings(
              storeId,
              settings, // ✅ Passa a configuração atual
              isStoreOpen: !settings.isStoreOpen, // ✅ Inverte apenas este campo
            ),
            isCritical: true,
          ),

          _buildSectionHeader('Modalidades de Pedido', context),
          _buildSettingItem(
            context: context,
            title: 'Pausar Delivery',
            description: 'Desativa a opção de entrega para novos pedidos',
            icon: Icons.delivery_dining_outlined,
            value: !settings.deliveryEnabled,
            onChanged: (_) => context.read<OperationConfigCubit>().updatePartialSettings(
              storeId,
              settings,
              deliveryEnabled: !settings.deliveryEnabled,
            ),
          ),
          _buildSettingItem(
            context: context,
            title: 'Pausar Retirada',
            description: 'Desativa a opção de retirada no local',
            icon: Icons.shopping_bag_outlined,
            value: !settings.pickupEnabled,
            onChanged: (_) => context.read<OperationConfigCubit>().updatePartialSettings(
              storeId,
              settings,
              pickupEnabled: !settings.pickupEnabled,
            ),
          ),
          _buildSettingItem(
            context: context,
            title: 'Pausar Serviço de Mesa',
            description: 'Desativa o recebimento de pedidos feitos na mesa',
            icon: Icons.restaurant_menu_outlined,
            value: !settings.tableEnabled,
            onChanged: (_) => context.read<OperationConfigCubit>().updatePartialSettings(
              storeId,
              settings,
              tableEnabled: !settings.tableEnabled,
            ),
          ),

          _buildSectionHeader('Automação', context),
          _buildSettingItem(
            context: context,
            title: 'Aceitar pedidos automaticamente',
            description: "Novos pedidos mudam para 'Em preparo' sem ação manual",
            icon: Icons.auto_awesome_motion_outlined,
            value: settings.autoAcceptOrders,
            onChanged: (_) => context.read<OperationConfigCubit>().updatePartialSettings(
              storeId,
              settings,
              autoAcceptOrders: !settings.autoAcceptOrders,
            ),
          ),
          _buildSettingItem(
            context: context,
            title: 'Imprimir pedidos automaticamente',
            description: 'Envia novos pedidos para a impressora principal',
            icon: Icons.print_outlined,
            value: settings.autoPrintOrders,
            onChanged: (_) => context.read<OperationConfigCubit>().updatePartialSettings(
              storeId,
              settings,
              autoPrintOrders: !settings.autoPrintOrders,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context)
              .textTheme
              .titleSmall
              ?.color
              ?.withOpacity(0.8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
    bool isCritical = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCritical
                ? colors.error.withOpacity(0.1)
                : colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isCritical ? colors.error : colors.primary,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.4,
            ),
          ),
        ),
        trailing: Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
          ),
        ),
        minLeadingWidth: 0,
        visualDensity: VisualDensity.compact,
      ),
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

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Loja não encontrada',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
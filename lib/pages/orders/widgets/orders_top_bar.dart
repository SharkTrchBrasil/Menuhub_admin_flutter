// lib/pages/orders/widgets/orders_top_bar.dart

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/pages/orders/widgets/order_type_tab.dart';
import 'package:totem_pro_admin/services/print/printer_settings.dart';

import '../../../core/helpers/sidepanel.dart';
import '../../chatpanel/widgets/chat_central_panel.dart';
import '../../table/widgets/create_table_dialog.dart';
import 'desktoptoolbar.dart';

class OrdersTopBar extends StatelessWidget {
  final String? selectedTabKey;
  final ValueChanged<String?> onTabSelected;

  const OrdersTopBar({
    super.key,
    required this.selectedTabKey,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, storeState) {
        if (storeState is! StoresManagerLoaded) {
          return const SizedBox.shrink();
        }

        final activeStoreId = storeState.activeStoreId;
        final options = storeState.activeStore?.relations.storeOperationConfig;

        // ✅ CONSTRUIR A LISTA DE ABAS DISPONÍVEIS NA ORDEM DESEJADA
        final availableTabsConfig = <Map<String, dynamic>>[];

        if (options?.deliveryEnabled ?? false) {
          availableTabsConfig.add({
            'key': 'delivery',
            'label': 'Delivery',
            'icon': Icons.delivery_dining,
          });
        }

        if (options?.pickupEnabled ?? false) {
          availableTabsConfig.add({
            'key': 'balcao',
            'label': 'Balcão',
            'icon': Icons.storefront,
          });
        }

        if (options?.tableEnabled ?? false) {
          availableTabsConfig.add({
            'key': 'mesa',
            'label': 'Mesas',
            'icon': Icons.table_restaurant,
          });

          // ✅ NOVA TAB: COMANDAS (só aparece se mesas estiver habilitado)
          availableTabsConfig.add({
            'key': 'comandas',
            'label': 'Comandas',
            'icon': Icons.receipt_long,
          });
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              // Renderizar as abas dinamicamente
              ...availableTabsConfig.map((tabConfig) {
                return OrderTypeTab(
                  icon: tabConfig['icon'],
                  label: tabConfig['label'],
                  count: 0, // TODO: Adicionar lógica de contagem se necessário
                  isSelected: selectedTabKey == tabConfig['key'],
                  onTap: () => onTabSelected(tabConfig['key']),
                );
              }).toList(),

              const Spacer(),

              DesktopToolbar(activeStore: storeState.activeStore),
            ],
          ),
        );
      },
    );
  }
}
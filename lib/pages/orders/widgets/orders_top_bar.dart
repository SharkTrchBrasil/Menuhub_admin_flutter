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
    // A barra de topo reage às mudanças do estado da loja
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, storeState) {
        if (storeState is! StoresManagerLoaded) {
          return const SizedBox.shrink();
        }

        final activeStoreId = storeState.activeStoreId;
        final options = storeState.activeStore?.relations.storeOperationConfig;

        // Construir a lista de abas disponíveis na ordem desejada
        final availableTabsConfig = <Map<String, dynamic>>[];
        if (options?.deliveryEnabled ?? false) {
          availableTabsConfig.add({'key': 'delivery', 'label': 'Delivery', 'icon': Icons.delivery_dining});
        }
        if (options?.pickupEnabled ?? false) {
          availableTabsConfig.add({'key': 'balcao', 'label': 'Balcão', 'icon': Icons.storefront});
        }
        if (options?.tableEnabled ?? false) {
          availableTabsConfig.add({'key': 'mesa', 'label': 'Mesas', 'icon': Icons.table_restaurant});
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

              DesktopToolbar(activeStore: storeState.activeStore,),

              // Botões de Ação (Impressora, etc.)
            //  _buildPrinterButton(context, storeState, activeStoreId),

            //  const SizedBox(width: 16),
              // ✅ BOTÃO AGORA É DINÂMICO
             // _buildPrimaryActionButton(context, selectedTabKey),
            ],
          ),
        );
      },
    );
  }

  // ✅ NOVO MÉTODO PARA ESCOLHER O BOTÃO DE AÇÃO CORRETO
  Widget _buildPrimaryActionButton(BuildContext context, String? tabKey) {
    final bool isTableTab = tabKey == 'mesa';

    return ElevatedButton.icon(
      icon: Icon(isTableTab ? Icons.add_rounded : Icons.add_shopping_cart_rounded),
      label: Text(isTableTab ? 'Criar mesa' : 'Novo pedido'),
      onPressed: () {
        if (isTableTab) {
          // Ação para a aba de Mesas
          showDialog(
            context: context,
            builder: (ctx) => const CreateTableDialog(),
          );
        } else {
          ChatCentralPanel();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isTableTab ? Colors.green[700] : Colors.blue[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }


  Widget _buildPrinterButton(BuildContext context, StoresManagerLoaded state, int activeStoreId) {
    final settings = state.activeStore?.relations.storeOperationConfig;
    final bool needsConfiguration = settings == null || (settings.mainPrinterDestination == null && settings.kitchenPrinterDestination == null);

    final iconButton = IconButton(
      icon: Icon(
        Icons.print_outlined,
        color: needsConfiguration ? Colors.amber : null,
      ),
      tooltip: 'Configurações de Impressão',
      onPressed: () {
        if (activeStoreId != -1) {
          showResponsiveSidePanel(
            context,
            PrinterSettingsSidePanel(storeId: activeStoreId),
          );
        }
      },
    );

    Widget finalIconWidget = needsConfiguration
        ? AvatarGlow(
      animate: true,
      glowColor: Colors.amber,
      duration: const Duration(milliseconds: 2000),
      repeat: true,
      child: iconButton,
    )
        : iconButton;

    return finalIconWidget;
  }
}
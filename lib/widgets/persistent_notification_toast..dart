// Em: widgets/persistent_notification_toast.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

class PersistentNotificationToast extends StatelessWidget {
  const PersistentNotificationToast({super.key});

  // ✨ NOVO: Função para mostrar o diálogo de seleção de loja ✨
  void _showStoreSelectionDialog(BuildContext context, Map<int, int> notificationCounts) {
    final storesManagerCubit = context.read<StoresManagerCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final storeEntries = notificationCounts.entries.toList();

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Novos Pedidos'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: storeEntries.length,
              itemBuilder: (context, index) {
                final entry = storeEntries[index];
                final storeId = entry.key;
                final count = entry.value;
                final storeName = storesManagerCubit.getStoreNameById(storeId) ?? 'Loja Desconhecida';

                return ListTile(
                  title: Text(storeName),
                  trailing: CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      count.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  onTap: () {
                    // Fecha o diálogo
                    Navigator.of(dialogContext).pop();
                    // Chama a lógica para trocar de loja
                    storesManagerCubit.changeActiveStore(storeId);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      buildWhen: (previous, current) {
        if (previous is StoresManagerLoaded && current is StoresManagerLoaded) {
          return previous.notificationCounts != current.notificationCounts;
        }
        return true;
      },
      builder: (context, state) {
        if (state is! StoresManagerLoaded || state.notificationCounts.isEmpty) {
          return const SizedBox.shrink();
        }

        final notificationCounts = state.notificationCounts;
        final totalOrders = notificationCounts.values.reduce((sum, item) => sum + item);
        final numberOfStores = notificationCounts.length;

        String message;
        final pedidoText = 'Novo${totalOrders > 1 ? 's' : ''} Pedido${totalOrders > 1 ? 's' : ''}';

        if (numberOfStores == 1) {
          final storeId = notificationCounts.keys.first;
          final storeName = context.read<StoresManagerCubit>().getStoreNameById(storeId) ?? 'outra loja';
          message = '$totalOrders $pedidoText em $storeName';
        } else {
          final lojaText = 'loja${numberOfStores > 1 ? 's' : ''}';
          message = '$totalOrders $pedidoText em $numberOfStores $lojaText';
        }

        final hasNotifications = totalOrders > 0;

        return AnimatedOpacity(
          opacity: hasNotifications ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            ignoring: !hasNotifications,
            // ✨ NOVO: Envolvemos o Card com InkWell para dar efeito de clique ✨
            child: Material(
              type: MaterialType.transparency,
              child: AnimatedOpacity(

                opacity: hasNotifications ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !hasNotifications,
                  child: InkWell(
                    onTap: () {
                      // ✅ LÓGICA DO CLIQUE ✅
                      final cubit = context.read<StoresManagerCubit>();
                      final currentState = cubit.state as StoresManagerLoaded;
                      final counts = currentState.notificationCounts;
                  
                      if (counts.length == 1) {
                        // Caso 1: Apenas uma loja, vai direto para ela.
                        final storeId = counts.keys.first;
                        cubit.changeActiveStore(storeId);
                      } else if (counts.length > 1) {
                        // Caso 2: Múltiplas lojas, abre o diálogo de seleção.
                        _showStoreSelectionDialog(context, counts);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Card(
                      elevation: 8.0,
                      color: Colors.deepOrangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.storefront, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(
                              message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
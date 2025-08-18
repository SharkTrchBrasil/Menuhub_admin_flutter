import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

class StoreSelectorPanel extends StatelessWidget {
  final Function(int storeId) onStoreSelected;
  final VoidCallback? onClose;

  const StoreSelectorPanel({
    super.key,
    required this.onStoreSelected,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          // Trata todos os estados não-carregados (Initial, Loading, Error, Empty)
          return const Center(child: CircularProgressIndicator());
        }

        if (state.stores.isEmpty) {
          return const Center(child: Text('Nenhuma loja disponível.'));
        }

        // 1. Pega os dados diretamente do estado para consistência.
        final consolidatedIds = state.consolidatedStores;
        final notificationCounts = state.notificationCounts;

        return Column(
          children: [
            if (onClose != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Selecionar Loja', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: onClose),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: state.stores.length,
                itemBuilder: (context, index) {
                  final storeWithRole = state.stores.values.elementAt(index);
                  final store = storeWithRole.store;
                  final isActive = state.activeStoreId == store.core.id;
                  final isConsolidated = consolidatedIds.contains(store.core.id);

                  // 2. Pega a contagem de notificações para a loja atual.
                  final notificationCount = notificationCounts[store.core.id] ?? 0;

                  return ListTile(
                    leading: Icon(
                      isActive ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isActive ? Colors.green : Colors.grey,
                    ),
                    title: Row(
                      children: [
                        Flexible(child: Text(store.core.name, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        // 3. Exibe o badge se houver notificações!
                        if (notificationCount > 0)
                          Badge(
                            label: Text('$notificationCount'),
                            backgroundColor: Colors.red,
                          ),
                      ],
                    ),
                    trailing: Icon(
                      isConsolidated ? Icons.star : Icons.star_border,
                      color: isConsolidated ? Colors.amber : Colors.grey,
                    ),
                    onTap: () {
                      onStoreSelected(store.core.id!);
                      // Fecha o painel após a seleção
                      if (onClose != null) {
                        onClose!();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
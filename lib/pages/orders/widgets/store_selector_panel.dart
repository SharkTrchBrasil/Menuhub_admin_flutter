// lib/widgets/store_selector_panel.dart (Exemplo adaptado)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import '../../../cubits/store_manager_cubit.dart';

class StoreSelectorPanel extends StatelessWidget {
  final Function(int storeId) onStoreSelected;
  final VoidCallback? onClose; // Callback opcional para fechar o pop-up

  const StoreSelectorPanel({
    super.key,
    required this.onStoreSelected,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is StoresManagerLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StoresManagerLoaded) {
          if (state.stores.isEmpty) {
            return const Center(child: Text('Nenhuma loja disponível.'));
          }

          final List<int> consolidatedIds = context.read<StoresManagerCubit>().currentConsolidatedStoreIds;

          return Column(
            children: [
              // Cabeçalho opcional para fechar o painel
              if (onClose != null)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.stores.length,
                  itemBuilder: (context, index) {
                    final storeWithRole = state.stores.values.elementAt(index);
                    final store = storeWithRole.store;
                    final isActive = state.activeStoreId == store.id;
                    final isConsolidated = consolidatedIds.contains(store.id);

                    return ListTile(
                      title: Text(store.name ?? 'Loja Desconhecida'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        //  Text('Online: ${storeWithRole.isOnline ? 'Sim' : 'Não'}'),
                          Text('Consolidada: ${isConsolidated ? 'Sim' : 'Não'}'),
                        ],
                      ),
                      leading: Icon(
                        isActive ? Icons.check_circle : Icons.circle_outlined,
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                      trailing: Icon(
                        isConsolidated ? Icons.star : Icons.star_border,
                        color: isConsolidated ? Colors.amber : Colors.grey,
                      ),
                      onTap: () {
                        // Ao clicar, aciona o callback para selecionar a loja
                        onStoreSelected(store.id!);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        } else if (state is StoresManagerError) {
          return Center(child: Text('Erro ao carregar lojas: ${state.message}'));
        }
        return const Center(child: Text('Carregando...')); // Caso seja StoresManagerInitial
      },
    );
  }
}
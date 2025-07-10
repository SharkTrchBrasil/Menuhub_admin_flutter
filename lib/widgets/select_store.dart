import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/store_manager_cubit.dart';
import '../cubits/store_manager_state.dart';
import '../models/store_with_role.dart';

class StoreSelectorWidget extends StatelessWidget {
  const StoreSelectorWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        final List<StoreWithRole> stores = (state is StoresManagerLoaded)
            ? List<StoreWithRole>.from(state.stores.values)
            : [];

        final selectedStoreId = (state is StoresManagerLoaded) ? state.activeStoreId : null;

        if (stores.isEmpty || selectedStoreId == null) {
          return const SizedBox.shrink();
        }

        return StorePopupMenu(
          stores: stores,
          selectedStoreId: selectedStoreId,
          // ✅ Este onStoreSelected é o que o StorePopupMenu vai chamar.
          // Coloque a lógica do GoRouter AQUI.
          onStoreSelected: (id) {
            // Primeiro, chame o setActiveStore no Cubit
            context.read<StoresManagerCubit>().setActiveStore(id);

            // Depois, navegue com o GoRouter
            GoRouter.of(context).go('/stores/$id/orders');
            print('[GoRouter Navigation] Navegando para /stores/$id/orders');
          },
          onAddStore: () {
            // Navegar para tela de adicionar loja
            // Você pode adicionar a navegação do GoRouter aqui também, se necessário
            GoRouter.of(context).go('/stores/new');
            print('[GoRouter Navigation] Navegando para /stores/new');
          },
        );
      },
    );
  }
}

class StorePopupMenu extends StatelessWidget {
  final List<StoreWithRole> stores;
  final int? selectedStoreId;
  final ValueChanged<int> onStoreSelected;
  final VoidCallback onAddStore;

  const StorePopupMenu({
    super.key,
    required this.stores,
    required this.selectedStoreId,
    required this.onStoreSelected,
    required this.onAddStore,
  });

  @override
  Widget build(BuildContext context) {
    final selectedStore = stores.firstWhere(
          (s) => s.store.id == selectedStoreId,
      orElse: () => stores.first,
    );

    return PopupMenuButton<int>(
      color: Theme.of(context).scaffoldBackgroundColor,
      tooltip: '',
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundImage: (selectedStore.store.image?.url != null && selectedStore.store.image!.url!.isNotEmpty)
                ? NetworkImage(selectedStore.store.image!.url!)
                : const AssetImage('assets/images/avatar.png') as ImageProvider,
          ),
          const SizedBox(width: 10),
          Text(
            selectedStore.store.name,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Icon(Icons.arrow_drop_down, size: 15, color: Theme.of(context).iconTheme.color),
          const SizedBox(width: 10),
        ],
      ),
      onSelected: (int storeId) {
        if (storeId == -1) {
          onAddStore();
        } else {
          onStoreSelected(storeId);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        for (final s in stores)
          PopupMenuItem<int>(
            value: s.store.id,
            child: ListTile(
              leading: CircleAvatar(
                radius: 12,
                backgroundImage: (s.store.image?.url != null && s.store.image!.url!.isNotEmpty)
                    ? NetworkImage(s.store.image!.url!)
                    : const AssetImage('assets/images/avatar.png') as ImageProvider,
              ),
              title: Text(
                s.store.name,
                style: Theme.of(context).textTheme.labelLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<int>(
          value: -1,
          child: Row(
            children: [
              Icon(Icons.add, size: 18, color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 8),
              Text('Adicionar loja', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ],
    );
  }
}
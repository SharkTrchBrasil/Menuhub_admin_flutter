// Em: widgets/StoreSelectorWidget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/widgets/access_wrapper.dart';

import '../cubits/store_manager_cubit.dart';
import '../cubits/store_manager_state.dart';
import '../models/store.dart';
import '../models/store_with_role.dart';

// ✨ Transformado em StatelessWidget, muito mais simples! ✨
class StoreSelectorWidget extends StatelessWidget {
  const StoreSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          // Mostra um estado de carregamento ou vazio se não houver dados carregados
          return const SizedBox(
            width: 40,
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
          );
        }

        final List<StoreWithRole> stores = List.from(state.stores.values);
        final int selectedStoreId = state.activeStoreId;

        if (stores.isEmpty) {
          return AccessWrapper(
            featureKey: 'extra_store_location',
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.go('/stores/new'),
              tooltip: 'Adicionar loja',
            ),
          );
        }

        return StorePopupMenu(
          stores: stores,
          selectedStoreId: selectedStoreId,
          // A mágica acontece aqui: onStoreSelected agora só chama o Cubit!
          onStoreSelected: (id) {
            context.read<StoresManagerCubit>().changeActiveStore(id);
          },
          onAddStore: () {
            context.go('/stores/new');
          },
        );
      },
    );
  }
}

// O resto do arquivo (StorePopupMenu, _StoreAvatar) continua igual,
// apenas removi a propriedade `isChanging` que não é mais necessária.

class StorePopupMenu extends StatelessWidget {
  final List<StoreWithRole> stores;
  final int selectedStoreId;
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
      tooltip: 'Selecionar loja',
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StoreAvatar(store: selectedStore.store),
          const SizedBox(width: 8),
          Text(
            selectedStore.store.name,
            style: Theme.of(context).textTheme.labelLarge,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            size: 20,
            color: Theme.of(context).iconTheme.color,
          ),
        ],
      ),
      onSelected: (int storeId) {
        if (storeId == -1) {
          onAddStore();
        } else {
          onStoreSelected(storeId);
        }
      },
      itemBuilder: (BuildContext context) => [
        ...stores.map(
              (s) => PopupMenuItem<int>(
            value: s.store.id,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _StoreAvatar(store: s.store),
              title: Text(
                s.store.name,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: s.store.id == selectedStoreId
                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                  : null,
            ),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<int>(
          // 1. Desabilitamos a ação de clique padrão do PopupMenuItem
          //    para que o AccessWrapper possa controlar o toque.
          enabled: false,

          // 2. Removemos o padding para que o nosso widget ocupe todo o espaço.
          padding: EdgeInsets.zero,

          // 3. Envolvemos o conteúdo com o AccessWrapper.
          child: AccessWrapper(
            featureKey: 'extra_store_location',
            child: ListTile( // Usamos um ListTile para um visual e alinhamento consistentes
              leading: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Adicionar loja',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              // O onTap do ListTile só será chamado se houver permissão.
              onTap: onAddStore,
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreAvatar extends StatelessWidget {
  final Store store;
  const _StoreAvatar({required this.store});

  @override
  Widget build(BuildContext context) {
    // ... (seu widget _StoreAvatar fica exatamente igual)
    return CircleAvatar(
      radius: 16,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      backgroundImage: (store.image?.url != null && store.image!.url!.isNotEmpty)
          ? NetworkImage(store.image!.url!)
          : const AssetImage('assets/images/avatar.png')
      as ImageProvider,
      child: (store.image?.url == null || store.image!.url!.isEmpty)
          ? Icon(
        Icons.store,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      )
          : null,
    );
  }
}
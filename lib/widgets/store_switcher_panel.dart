import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/store/store.dart';

import 'ds_primary_button.dart';

/// Um painel que exibe a lista de lojas do usuário e permite a troca.
class StoreSwitcherPanel extends StatelessWidget {
  const StoreSwitcherPanel({super.key});

  void _navigateToStore(BuildContext context, Store store) {
    // 1. Troca a loja ativa no cubit
    context.read<StoresManagerCubit>().changeActiveStore(store.core.id!);
    // 2. Navega para o novo hub da loja selecionada
    context.go('/stores/hub');
    // 3. Fecha o painel lateral
    Navigator.of(context).pop();
  }

  void _createNewStore(BuildContext context) {
    Navigator.of(context).pop(); // Fecha o painel
    context.go('/stores/new'); // Vai para a tela de nova loja
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Trocar de Loja',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        automaticallyImplyLeading: false,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<StoresManagerCubit, StoresManagerState>(
              builder: (context, state) {
                if (state is! StoresManagerLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stores = state.stores.values.toList();
                final activeStoreId = state.activeStore?.core.id;

                if (stores.isEmpty) {
                  return _buildEmptyState(context);
                }

                return _buildStoresList(
                  context,
                  stores: stores,
                  activeStoreId: activeStoreId,
                  isMobile: isMobile,
                );
              },
            ),
          ),

          // Botão de criar nova loja - responsivo
          _buildCreateStoreButton(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma loja encontrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comece criando sua primeira loja',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoresList(
      BuildContext context, {
        required List<dynamic> stores,
        required int? activeStoreId,
        required bool isMobile,
      }) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, isMobile ? 80 : 16),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        final bool isActive = store.store.core.id == activeStoreId;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToStore(context, store.store),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color:
                  Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade200,
                    width: isActive ? 1.5 : 1,
                  ),

                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar da loja
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: store.store.media?.image?.url != null
                            ? CachedNetworkImage(
                          imageUrl: store.store.media!.image!.url!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              Icon(
                                Icons.storefront,
                                size: 24,
                                color: Theme.of(context).primaryColor,
                              ),
                        )
                            : Icon(
                          Icons.storefront,
                          size: 24,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Informações da loja
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.store.core.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            store.store.address?.city ?? 'Sem cidade',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: store.store.core.isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              store.store.core.isActive ? 'Ativa' : 'Inativa',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: store.store.core.isActive
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Indicador de loja ativa ou seta
                    isActive
                        ? Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                        : Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateStoreButton(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,


      ),
      child: SizedBox(
        height: isMobile ? 48 : 52,
        child: DsButton(
          onPressed: () => _createNewStore(context),
          label:'Criar Nova Loja',


        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

class StoreSettingsSidePanel extends StatelessWidget {
  final int storeId;

  const StoreSettingsSidePanel({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final panelWidth = isMobile
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width * 0.3;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 12,
        child: Container(
          width: panelWidth,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Configurações da Loja',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              Expanded(
                child: BlocBuilder<StoresManagerCubit, StoresManagerState>(
                  builder: (context, state) {
                    if (state is StoresManagerLoaded) {
                      final storeWithRole = state.stores[storeId];
                      final store = storeWithRole?.store;
                      final settings = store?.storeSettings;

                      if (store == null || settings == null) {
                        return const Center(child: Text('Loja não encontrada'));
                      }

                      return ListView(
                        children: [
                          ListTile(
                            title: const Text('Loja Aberta'),
                            trailing: Switch(
                              value: settings.isStoreOpen,
                              onChanged: (_) => context
                                  .read<StoresManagerCubit>()
                                  .updateStoreSettings(storeId, isStoreOpen: !settings.isStoreOpen),
                            ),
                          ),
                          ListTile(
                            title: const Text('Delivery Ativo'),
                            trailing: Switch(
                              value: settings.isDeliveryActive,
                              onChanged: (_) => context
                                  .read<StoresManagerCubit>()
                                  .updateStoreSettings(storeId, isDeliveryActive: !settings.isDeliveryActive),
                            ),
                          ),
                          ListTile(
                            title: const Text('Retirada Ativa'),
                            trailing: Switch(
                              value: settings.isTakeoutActive,
                              onChanged: (_) => context
                                  .read<StoresManagerCubit>()
                                  .updateStoreSettings(storeId, isTakeoutActive: !settings.isTakeoutActive),
                            ),
                          ),

                          ListTile(
                            title: const Text('Aceitar pedidos automaticamente'),
                            trailing: Switch(
                              value: settings.autoAcceptOrders,
                              onChanged: (_) => context
                                  .read<StoresManagerCubit>()
                                  .updateStoreSettings(storeId, autoAcceptOrders: !settings.autoAcceptOrders),
                            ),
                          ),
                          ListTile(
                            title: const Text('Imprimir pedidos automaticamente'),
                            trailing: Switch(
                              value: settings.autoPrintOrders,
                              onChanged: (_) => context
                                  .read<StoresManagerCubit>()
                                  .updateStoreSettings(storeId, autoPrintOrders: !settings.autoPrintOrders),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Exibir pedidos das lojas vinculadas:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Adicione outras opções aqui
                        ],
                      );
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

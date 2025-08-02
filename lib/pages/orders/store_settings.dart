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

    // Estilo para os subtítulos para manter o código limpo
    final subtitleStyle = TextStyle(
      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
      fontSize: 12,
    );

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

              const Divider(), // A linha divisória fica melhor aqui

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
                            title: const Text('Fechar temporariamente'),
                            // ✅ DESCRIÇÃO ADICIONADA
                            subtitle: Text(
                              'Interrompe completamente o funcionamento da loja.',
                              style: subtitleStyle,
                            ),
                            trailing: Switch(
                              value: !settings.isStoreOpen, // Lógica invertida para "Fechar"
                              onChanged: (_) => context
                                  .read<StoresManagerCubit>()
                                  .updateStoreSettings(storeId, isStoreOpen: !settings.isStoreOpen),
                            ),
                          ),
                          ListTile(
                            title: const Text('Pausar Delivery'),
                            // ✅ DESCRIÇÃO ADICIONADA
                            subtitle: Text(
                              'Desativa a opção de entrega para novos pedidos.',
                              style: subtitleStyle,
                            ),
                            trailing: Switch(
                              value: !settings.isDeliveryActive, // Lógica invertida para "Pausar"
                              onChanged: (_) => context
                                  .read<StoresManagerCubit>()
                                  .updateStoreSettings(storeId, isDeliveryActive: !settings.isDeliveryActive),
                            ),
                          ),
                          ListTile(
                            title: const Text('Pausar Retirada'),
                            // ✅ DESCRIÇÃO ADICIONADA
                            subtitle: Text(
                              'Desativa a opção de retirada no local.',
                              style: subtitleStyle,
                            ),
                            trailing: Switch(
                              value: !settings.isTakeoutActive, // Lógica invertida para "Pausar"
                              onChanged: (_) => context
                                  .read<StoresManagerCubit>()
                                  .updateStoreSettings(storeId, isTakeoutActive: !settings.isTakeoutActive),
                            ),
                          ),
                          ListTile(
                            title: const Text('Aceitar pedidos automaticamente'),
                            // ✅ DESCRIÇÃO ADICIONADA
                            subtitle: Text(
                              "Novos pedidos mudam para 'Em preparo' sem ação manual.",
                              style: subtitleStyle,
                            ),
                            trailing: Switch(
                              value: settings.autoAcceptOrders,
                              onChanged: (_) => context
                                  .read<StoresManagerCubit>()
                                  .updateStoreSettings(storeId, autoAcceptOrders: !settings.autoAcceptOrders),
                            ),
                          ),
                          // ListTile(
                          //   title: const Text('Imprimir pedidos automaticamente'),
                          //   // ✅ DESCRIÇÃO ADICIONADA
                          //   subtitle: Text(
                          //     'Envia novos pedidos para a impressora configurada.',
                          //     style: subtitleStyle,
                          //   ),
                          //   trailing: Switch(
                          //     value: settings.autoPrintOrders,
                          //     onChanged: (_) => context
                          //         .read<StoresManagerCubit>()
                          //         .updateStoreSettings(storeId, autoPrintOrders: !settings.autoPrintOrders),
                          //   ),
                          // ),
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
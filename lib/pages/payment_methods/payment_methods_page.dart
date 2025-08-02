import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/repositories/payment_method_repository.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/core/di.dart';

// ✅ 1. A página agora é um StatelessWidget, muito mais simples!
class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key, required this.storeId});

  final int storeId;

  @override
  Widget build(BuildContext context) {
    // Acessa o repositório que usaremos para as atualizações
    final paymentRepository = getIt<PaymentMethodRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Formas de Pagamento')),
      body:
      // ✅ 2. Usamos BlocBuilder para ouvir o estado central da loja
      BlocBuilder<StoresManagerCubit, StoresManagerState>(
        builder: (context, state) {
          if (state is! StoresManagerLoaded) {
            return const Center(child: DotLoading());
          }

          final paymentGroups = state.activeStore?.paymentMethodGroups ?? [];

          if (paymentGroups.isEmpty) {
            return const Center(child: Text('Nenhuma forma de pagamento configurada na plataforma.'));
          }

          // ✅ 3. Construímos a UI hierárquica com ListView.builder
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: paymentGroups.length,
            itemBuilder: (context, groupIndex) {
              final group = paymentGroups[groupIndex];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  initiallyExpanded: true, // Começa expandido
                  children: group.categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          ),
                          ...category.methods.map((method) {
                            // A configuração específica da loja para este método
                            final activation = method.activation;
                            final bool isEnabled = activation?.isActive ?? false;

                            return ListTile(
                              leading: const Icon(Icons.payment), // TODO: Usar o icon_key
                              title: Text(method.name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ✅ 4. O controle principal agora é um Switch para ativar/desativar
                                  Switch(
                                    value: isEnabled,
                                    onChanged: (newValue) {
                                      // Cria uma cópia da ativação atual ou uma nova se não existir
                                      final updatedActivation = activation?.copyWith(isActive: newValue) ??
                                          StorePaymentMethodActivation(
                                            id: 0, // ID não é necessário para a atualização
                                            isActive: newValue,
                                            feePercentage: 0,
                                            isForDelivery: true,
                                            isForPickup: true,
                                            isForInStore: true,
                                          );

                                      // Chama o novo método do repositório
                                      paymentRepository.updateActivation(
                                        storeId: storeId,
                                        platformMethodId: method.id,
                                        activation: updatedActivation,
                                      );
                                    },
                                  ),
                                  // Botão para configurar detalhes (taxas, chave pix, etc)
                                  IconButton(
                                    icon: const Icon(Icons.settings_outlined),
                                    onPressed: () {
                                      // TODO: Criar um DialogService.showPaymentActivationDialog
                                      // para editar taxas e a chave pix.
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Tela de configuração a ser implementada.')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
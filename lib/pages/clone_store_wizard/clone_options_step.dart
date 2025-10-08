import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/store/store_with_role.dart';

import 'cubit/new_store_cubit.dart';
import 'cubit/new_store_state.dart';


class CloneOptionsStep extends StatelessWidget {
  const CloneOptionsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewStoreCubit, NewStoreState>(
      builder: (context, state) {
        final cubit = context.read<NewStoreCubit>();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clonar de Loja Existente',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione a loja de origem e o que você deseja clonar para a nova loja.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              _buildSourceStoreSelector(context, state),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                'O que você quer clonar?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              // ✅ LÓGICA ATUALIZADA AQUI
              _buildCloneOptionTile(
                context: context,
                title: 'Produtos, Categorias e Cardápio',
                subtitle: 'Clona todos os produtos, categorias, variantes e a estrutura do seu cardápio.',
                value: state.cloneOptions.cloneProducts,
                onChanged: (value) {
                  // Ao marcar/desmarcar produtos, as categorias vão junto.
                  final newOptions = state.cloneOptions.copyWith(cloneProducts: value, cloneCategories: value);
                  cubit.updateCloneOptions(newOptions);
                },
              ),
              _buildCloneOptionTile(
                context: context,
                title: 'Configurações de Operação',
                subtitle: 'Horários de funcionamento, áreas e taxas de entrega, impressoras, etc.',
                value: state.cloneOptions.cloneOperationConfig,
                onChanged: (value) => cubit.updateCloneOptions(state.cloneOptions.copyWith(cloneOperationConfig: value)),
              ),
              _buildCloneOptionTile(
                context: context,
                title: 'Formas de Pagamento',
                subtitle: 'Clona as formas de pagamento ativas na loja de origem.',
                value: state.cloneOptions.clonePaymentMethods,
                onChanged: (value) => cubit.updateCloneOptions(state.cloneOptions.copyWith(clonePaymentMethods: value)),
              ),
              _buildCloneOptionTile(
                context: context,
                title: 'Tema e Aparência',
                subtitle: 'Copia as cores, fontes e o tema visual da loja de origem.',
                value: state.cloneOptions.cloneTheme,
                onChanged: (value) => cubit.updateCloneOptions(state.cloneOptions.copyWith(cloneTheme: value)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceStoreSelector(BuildContext context, NewStoreState state) {
    if (state.userStores.isEmpty) {
      return const Text('Nenhuma loja encontrada para clonar.');
    }

    return DropdownButtonFormField<StoreWithRole>(
      value: state.sourceStore,
      onChanged: (StoreWithRole? newValue) {
        if (newValue != null) {
          context.read<NewStoreCubit>().setSourceStore(newValue);
        }
      },
      items: state.userStores.map<DropdownMenuItem<StoreWithRole>>((store) {
        return DropdownMenuItem<StoreWithRole>(
          value: store,
          child: Text(store.store.core.name),
        );
      }).toList(),
      decoration: const InputDecoration(
        labelText: 'Loja de Origem',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCloneOptionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}
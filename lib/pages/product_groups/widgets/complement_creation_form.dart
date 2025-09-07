import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/catalog_product.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/widgets/app_image_form_field.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

// Importe o novo Cubit
import '../cubit/complement_form_cubit.dart';


typedef OnOptionCreated = void Function(VariantOption option);

class ComplementCreationForm extends StatelessWidget {
  final VoidCallback onCancel;
  final OnOptionCreated onOptionCreated;

  const ComplementCreationForm({
    super.key,
    required this.onCancel,
    required this.onOptionCreated,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Fornecemos uma instância do Cubit para este widget e seus filhos
    return BlocProvider(
      create: (_) => ComplementFormCubit(),
      // 2. Ouve mudanças no estado para executar ações (como chamar o callback)
      child: BlocListener<ComplementFormCubit, ComplementFormState>(
        listener: (context, state) {
          if (state.createdOption != null) {
            onOptionCreated(state.createdOption!);
          }
        },
        // 3. Constrói a UI com base no estado atual
        child: BlocBuilder<ComplementFormCubit, ComplementFormState>(
          builder: (context, state) {
            final cubit = context.read<ComplementFormCubit>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [








                const SizedBox(height: 24),
                const Text("Tipo de produto", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(value: true, label: Text("Preparado")),
                    ButtonSegment<bool>(value: false, label: Text("Industrializado")),
                  ],
                  selected: {state.isPrepared},
                  onSelectionChanged: (selection) => cubit.toggleProductType(selection.first),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: state.isPrepared
                      ? _PreparedFormView(key: const ValueKey('prepared'))
                      : _IndustrializedFlowView(key: const ValueKey('industrialized')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// --- WIDGETS DE UI "BURROS" ---

// Widget para o formulário "Preparado"
class _PreparedFormView extends StatelessWidget {
  const _PreparedFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ComplementFormCubit>();
    final state = context.watch<ComplementFormCubit>().state;

    return Column(
      children: [
        TextFormField(
          initialValue: state.name,
          onChanged: cubit.nameChanged,
          decoration: const InputDecoration(labelText: "Nome do Complemento*"),
          validator: (v) => (v == null || v.isEmpty) ? "Campo obrigatório" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: state.description,
          onChanged: cubit.descriptionChanged,
          decoration: const InputDecoration(labelText: "Descrição"),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        AppProductImageFormField(
          title: 'Imagem',
          initialValue: state.image,
          onChanged: cubit.imageChanged, validator: (ImageModel ) {  },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Estoque", style: TextStyle(fontSize: 16)),
            Switch(
              value: state.trackInventory,
              onChanged: cubit.trackInventoryChanged,
            ),
          ],
        ),
        if (state.trackInventory) ...[
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.stockQuantity,
            onChanged: cubit.stockQuantityChanged,
            decoration: const InputDecoration(labelText: 'Quantidade em estoque'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
        const SizedBox(height: 26),
        TextFormField(
          initialValue: state.price,
          onChanged: cubit.priceChanged,
          decoration: const InputDecoration(labelText: "Preço Adicional (R\$)", prefixText: "R\$ "),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            onPressed: cubit.submit,
            label: const Text("Adicionar ao grupo"),
          ),
        ),
      ],
    );
  }
}

// Widget para o fluxo "Industrializado"
class _IndustrializedFlowView extends StatelessWidget {
  const _IndustrializedFlowView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ComplementFormCubit>().state;
    return state.selectedCatalogProduct != null
        ? _IndustrializedFormView()
        : _SearchInterfaceView();
  }
}

class _SearchInterfaceView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ComplementFormCubit>();
    final state = context.watch<ComplementFormCubit>().state;

    return Column(
      children: [
        TextField(
          onChanged: cubit.onSearchChanged,
          decoration: const InputDecoration(labelText: "Buscar no catálogo por nome ou EAN", prefixIcon: Icon(Icons.search)),
        ),
        const SizedBox(height: 16),
        if (state.isLoadingSearch) const Center(child: CircularProgressIndicator()),
        if (!state.isLoadingSearch && state.searchResults.isNotEmpty)
          ...state.searchResults.map((product) => ListTile(
            leading: product.imagePath != null ? Image.network(product.imagePath!.url!, width: 40) : const Icon(Icons.image),
            title: Text(product.name),
            subtitle: Text(product.brand ?? ''),
            trailing: ElevatedButton(
              child: const Text('Adicionar'),
              onPressed: () => cubit.selectCatalogProduct(product),
            ),
          )),
      ],
    );
  }
}

class _IndustrializedFormView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ComplementFormCubit>();
    final state = context.watch<ComplementFormCubit>().state;

    return Column(
      children: [
        TextFormField(
          key: ValueKey(state.selectedCatalogProduct!.id), // Garante que o campo reconstrua com o novo valor
          initialValue: state.name,
          readOnly: true,
          decoration: InputDecoration(
            labelText: "Nome do Produto",
            fillColor: Colors.grey.shade200,
            filled: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: cubit.resetIndustrializedFlow,
              tooltip: "Buscar outro",
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: state.description,
          readOnly: true,
          maxLines: 3,
          decoration: InputDecoration(labelText: "Descrição", fillColor: Colors.grey.shade200, filled: true),
        ),
        const SizedBox(height: 16),
        if (state.image.url != null) Image.network(state.image.url!, height: 100),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: state.price,
          onChanged: cubit.priceChanged,
          decoration: const InputDecoration(labelText: "Preço Adicional (R\$)", prefixText: "R\$ "),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        DsButton(
          label: 'Adicionar ao grupo',
          onPressed: cubit.submit,
        ),
      ],
    );
  }
}
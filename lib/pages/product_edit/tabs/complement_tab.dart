import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/product_variant_link.dart';
import 'package:totem_pro_admin/pages/product_edit/cubit/edit_product_cubit.dart';
import 'package:totem_pro_admin/pages/product_edit/widgets/variant_link_card.dart';

// ✨ AGORA É UM STATELESSWIDGET
class ComplementGroupsTab extends StatelessWidget {
  const ComplementGroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // O widget agora ouve o EditProductCubit
    return BlocBuilder<EditProductCubit, EditProductState>(
      // buildWhen otimiza a reconstrução, opcional mas recomendado
      buildWhen: (prev, current) => prev.editedProduct.variantLinks != current.editedProduct.variantLinks,
      builder: (context, state) {
        final cubit = context.read<EditProductCubit>();
        final links = state.editedProduct.variantLinks ?? [];

        // O conteúdo principal é um SingleChildScrollView para evitar overflow
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context), // O cabeçalho com o botão de adicionar
              const SizedBox(height: 24),
              if (links.isEmpty)
                _buildEmptyState(context)
              else
                _buildPopulatedState(context, cubit, links),
            ],
          ),
        );
      },
    );
  }

  // Cabeçalho da aba
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Grupos de Complementos", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          // O botão agora simplesmente chama o método do CUBIT
          onPressed: () => context.read<EditProductCubit>().addNewComplementGroup(context),
          icon: const Icon(Icons.add),
          label: const Text("Adicionar grupo"),
        ),
      ],
    );
  }

  // Estado para quando a lista de complementos está populada
  Widget _buildPopulatedState(BuildContext context, EditProductCubit cubit, List<ProductVariantLink> links) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final link = links[index];

        return VariantLinkCard(
          key: ValueKey(link.variant.id ?? index),
          link: link,
          onRemoveLink: () => cubit.removeVariantLink(link),
          onLinkRulesChanged: (updatedLink) => cubit.updateVariantLink(updatedLink),
          onToggleAvailability: () {
            final updatedLink = link.copyWith(available: !link.available);
            cubit.updateVariantLink(updatedLink);
          },

          // ✅ CONECTANDO OS NOVOS MÉTODOS
          onLinkNameChanged: (newName) => cubit.updateVariantLinkName(link, newName),

          // A ação de adicionar uma opção vai abrir um painel e depois chamar o cubit
          onAddOption: () async {
            // final newOption = await showAddOptionToGroupPanel(context);
            // if (newOption != null) {
            //   cubit.addOptionToLink(link, newOption);
            // }
          },

          onOptionUpdated: (updatedOption) => cubit.updateOptionInLink(link, updatedOption),

          onOptionRemoved: (optionToRemove) => cubit.removeOptionFromLink(link, optionToRemove),
        );




      },
      onReorder: cubit.reorderVariantLinks,
    );
  }

  // Estado para quando não há complementos
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Este produto ainda não possui grupos de complementos.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<EditProductCubit>().addNewComplementGroup(context),
              icon: const Icon(Icons.add),
              label: const Text("Adicionar Primeiro Grupo"),
            ),
          ],
        ),
      ),
    );
  }
}
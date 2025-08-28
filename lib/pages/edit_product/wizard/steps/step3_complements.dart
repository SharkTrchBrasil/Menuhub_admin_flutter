import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/product_variant_link.dart';


import '../../../../widgets/mobile_mockup.dart';
import '../../cubit/product_wizard_cubit.dart';

import '../../groups/helper/show_create_group_panel.dart';
import '../../helper/sidepanel.dart';
import '../../widgets/variant_link_card.dart';

class Step3Complements extends StatelessWidget {
  const Step3Complements({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      builder: (context, state) {
        final mainContent = _buildMainContent(context, state);

        return ResponsiveBuilder(
          mobileBuilder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: mainContent,
          ),
          desktopBuilder: (context, constraints) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: mainContent,
                ),
              ),
              Spacer(),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(top: 32.0, right: 32.0),
                  // O mockup agora precisa receber a lista de links do estado
                  child: ProductPhoneMockup(
                    product: state.productInCreation.copyWith(
                      variantLinks: () => state.variantLinks,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, ProductWizardState state) {
    final bool hasNoLinks = state.variantLinks.isEmpty;

    return hasNoLinks
        ? _buildEmptyState(context)
        : _buildComplementsList(context, state);
  }

  // ✅ A chamada agora é uma função async que usa o novo helper
  Future<void> _openPanel(BuildContext context) async {
    final cubit = context.read<ProductWizardCubit>();

    final newLink = await showCreateGroupPanel(
      context,
      productId: cubit.state.productInCreation.id,
    );

    // Se o painel retornou um link, adiciona ao estado do wizard
    if (newLink != null && context.mounted) {
      cubit.addVariantLink(newLink);
    }
  }


  Widget _buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Image.asset('assets/images/complements.png', height: 150), // Adicione uma imagem legal
        const SizedBox(height: 24),
        Text(
          "Clientes amam personalizar!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Crie grupos como 'Escolha sua bebida', 'Adicionais' ou 'Ponto da carne' para aumentar o valor do seu pedido.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => _openPanel(context),
          icon: const Icon(Icons.add),
          label: const Text("Adicionar Primeiro Grupo"),
        ),
      ],
    );
  }

  Widget _buildComplementsList(BuildContext context, ProductWizardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Grupos de Complementos", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _openPanel(context),
              icon: const Icon(Icons.add),
              label: const Text("Adicionar grupo"),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.variantLinks.length,
          itemBuilder: (context, index) {
            final link = state.variantLinks[index];
            return VariantLinkCard(
              key: ValueKey(link.variant.id ?? index),
              link: link,
               onRemove: () => context.read<ProductWizardCubit>().removeVariantLink(link),
            );
          },
          onReorder: (oldIndex, newIndex) {
            context.read<ProductWizardCubit>().reorderVariantLinks(oldIndex, newIndex);
          },
        ),
      ],
    );
  }
}
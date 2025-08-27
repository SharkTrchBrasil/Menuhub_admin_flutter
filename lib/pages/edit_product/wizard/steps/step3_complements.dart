import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/product_variant_link.dart';
// Importe o painel que você já criou
import 'package:totem_pro_admin/pages/edit_product/widgets/groups/multi_step_panel.dart';
import 'package:totem_pro_admin/pages/edit_product/helper/sidepanel.dart';

// Você precisará de um card para mostrar o link, pode reusar o que já tem
import 'package:totem_pro_admin/pages/edit_product/widgets/variant_link_card.dart';

import '../../../../widgets/mobile_mockup.dart';
import '../../cubit/product_wizard_cubit.dart';
import '../../cubit/product_wizard_state.dart';

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
              Expanded(
                flex: 4,
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

  Future<void> _openCreateGroupPanel(BuildContext context) async {
    final cubit = context.read<ProductWizardCubit>();

    // // O painel agora retorna o novo grupo criado (em memória)
    // final newLink = showResponsiveSidePanelComplement<ProductVariantLink>(
    //   context,
    //   // O productId pode ser nulo, pois estamos criando um novo produto
    //   productId: cubit.state.productInCreation.id, panel: null,
    // );
    //
    // if (newLink != null && context.mounted) {
    //   context.read<ProductWizardCubit>().addVariantLink(newLink);
    // }
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
          onPressed: () => _openCreateGroupPanel(context),
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
              onPressed: () => _openCreateGroupPanel(context),
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
            //  onRemove: () => context.read<ProductWizardCubit>().removeVariantLink(link),
            );
          },
          onReorder: (oldIndex, newIndex) {
         //   context.read<ProductWizardCubit>().reorderVariantLinks(oldIndex, newIndex);
          },
        ),
      ],
    );
  }
}